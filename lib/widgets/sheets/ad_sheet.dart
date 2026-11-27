import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../providers/providers.dart';
import '../../services/ad_service.dart';
import '../../theme/theme.dart';
import 'sheet_scaffold.dart';

/// Sahte ödüllü reklam sheet'i.
///
/// Gerçek bir reklam ağı yok (oyun çevrimdışı). Bu sheet reklamın
/// "oynadığı" süreyi gösterir, oyuncuya iptal imkânı verir ve sonucu
/// döner. Mağaza sürümünde yalnızca [AdService] uygulaması değişecek;
/// bu ekran aynı kalabilir.
class AdSheet extends ConsumerStatefulWidget {
  const AdSheet({super.key});

  @override
  ConsumerState<AdSheet> createState() => _AdSheetState();
}

class _AdSheetState extends ConsumerState<AdSheet> {
  /// Oyuncu iptal ettiğinde tamamlanır; servis bunu izliyor.
  final _cancelled = Completer<void>();

  AdOutcome? _outcome;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Sheet açılır açılmaz reklamı başlat: oyuncu zaten "reklam izle"ye
    // basarak buraya geldi, bir kez daha onaylatmak gereksiz sürtünme.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (_started) return;
    _started = true;

    final outcome = await ref
        .read(gameControllerProvider.notifier)
        .watchAdForHint(onCancelled: _cancelled.future);

    if (!mounted) return;
    setState(() => _outcome = outcome);

    // Ödül verildiyse kısa bir onay gösterip kendiliğinden kapan.
    if (outcome == AdOutcome.rewarded) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop(outcome);
    }
  }

  void _cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
    Navigator.of(context).pop(AdOutcome.cancelled);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;
    final outcome = _outcome;

    return SheetScaffold(
      title: strings[StringKey.adSheetTitle],
      icon: AppIcons.ad,
      accentColor: AppColors.info,
      footer: outcome == null
          ? TextButton(
              onPressed: _cancel,
              child: Text(strings[StringKey.adCancel]),
            )
          : FilledButton(
              onPressed: () => Navigator.of(context).pop(outcome),
              child: Text(strings[StringKey.commonOk]),
            ),
      children: [
        const SizedBox(height: AppDimens.gapMd),
        if (outcome == null) ...[
          const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          const SizedBox(height: AppDimens.gapLg),
          Text(
            strings[StringKey.adLoading],
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ] else
          Row(
            children: [
              Icon(
                outcome == AdOutcome.rewarded
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: outcome == AdOutcome.rewarded
                    ? AppColors.good
                    : AppColors.warning,
                size: AppDimens.iconMd,
              ),
              const SizedBox(width: AppDimens.gapMd),
              Expanded(
                child: Text(
                  outcome == AdOutcome.rewarded
                      ? strings[StringKey.adRewardGranted]
                      : strings[StringKey.adFailed],
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        const SizedBox(height: AppDimens.gapMd),
      ],
    );
  }
}

/// Reklam sheet'ini açar ve sonucu döner.
Future<AdOutcome?> showAdSheet(BuildContext context) {
  return showAppSheet<AdOutcome>(
    context: context,
    // Reklam oynarken kazara kapatılmasın; iptal butonu var.
    dismissible: false,
    builder: (context) => const AdSheet(),
  );
}
