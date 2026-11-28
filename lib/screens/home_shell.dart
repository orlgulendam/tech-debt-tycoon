import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'glossary_screen.dart';
import 'help_screen.dart';
import 'log_screen.dart';
import 'office_screen.dart';
import 'team_screen.dart';

/// Alt navigasyonlu ana kabuk.
///
/// Dört sekme [IndexedStack] içinde tutuluyor: sekme değiştirince ekranlar
/// yeniden kurulmuyor, böylece sözlükteki arama metni ya da liste kaydırma
/// konumu korunuyor.
///
/// Kabuk aynı zamanda karar bekleyen olay kartını açmaktan sorumlu: kart
/// durumda duruyor ve oyuncu hangi sekmede olursa olsun (hatta uygulamayı
/// kapatıp açsa bile) kararı vermesi gerekiyor.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  /// Aynı kart için sheet'in iki kez açılmasını engeller.
  bool _eventSheetOpen = false;

  @override
  void initState() {
    super.initState();
    // Uygulama kayıtlı bir olay kartıyla açıldıysa onu hemen göster.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPendingEvent());
  }

  /// Karar bekleyen olay kartı varsa sheet'i açar.
  Future<void> _showPendingEvent() async {
    if (_eventSheetOpen) return;
    final card = ref.read(gameControllerProvider.notifier).pendingEvent;
    if (card == null) return;

    _eventSheetOpen = true;
    await showEventSheet(context, card);
    if (mounted) _eventSheetOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    // Durum dışarıdan değişip (ör. ekip ekranından işe alım) olay kartı
    // çıktıysa onu da yakala.
    ref.listen(gameControllerProvider, (previous, next) {
      if (next.hasPendingEvent &&
          previous?.pendingEventId != next.pendingEventId) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showPendingEvent(),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(strings[StringKey.appTitle]),
        actions: [
          IconButton(
            tooltip: strings[StringKey.helpTitle],
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ref.read(hapticsProvider).selection();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: strings[StringKey.commonNewGame],
            icon: const Icon(AppIcons.newGame),
            onPressed: () => _confirmNewGame(strings),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          OfficeScreen(),
          TeamScreen(),
          GlossaryScreen(),
          LogScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          if (index == _index) return;
          ref.read(hapticsProvider).selection();
          setState(() => _index = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(AppIcons.navOffice),
            label: strings[StringKey.navOffice],
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.navTeam),
            label: strings[StringKey.navTeam],
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.navGlossary),
            label: strings[StringKey.navGlossary],
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.navLog),
            label: strings[StringKey.navLog],
          ),
        ],
      ),
    );
  }

  /// Yeni oyun onayı.
  ///
  /// Devam eden oyun silineceği için onay şart; yanlışlıkla dokunmak
  /// haftaların emeğini siler.
  Future<void> _confirmNewGame(AppStrings strings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(strings[StringKey.commonNewGameConfirmTitle]),
        content: Text(strings[StringKey.commonNewGameConfirmBody]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings[StringKey.commonCancel]),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings[StringKey.commonNewGame]),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      ref.read(gameControllerProvider.notifier).startNewGame();
      if (mounted) setState(() => _index = 0);
    }
  }
}
