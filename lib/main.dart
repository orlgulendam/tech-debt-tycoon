import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/l10n.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'services/game_engine.dart';
import 'services/hive_storage_service.dart';
import 'services/storage_service.dart';

/// Uygulamanın giriş noktası.
///
/// Kalıcı kayıt burada **bir kez** hazırlanır ve provider'a enjekte edilir.
/// Bunun nedeni: depolamayı açmak asenkron, ama oyun açıldığında kaydın
/// hazır olması gerekiyor. Böylece `GameController` kayıtlı oyunu senkron
/// okuyabiliyor ve UI "yükleniyor" durumu göstermek zorunda kalmıyor.
Future<void> main() async {
  final storage = await _openStorage();

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
      child: const TechDebtTycoonApp(),
    ),
  );
}

/// Kalıcı kaydı açar; açılamazsa belleğe yazan yedeğe düşer.
///
/// Hive bozuk bir dosya ya da izin sorunu yüzünden açılamazsa oyunun hiç
/// başlamaması en kötü sonuç olur. Bu durumda oyun oynanabilir kalır,
/// yalnızca kayıt tutulmaz.
Future<StorageService> _openStorage() async {
  final hive = HiveStorageService();
  try {
    await hive.init();
    return hive;
  } on Object {
    final fallback = InMemoryStorageService();
    await fallback.init();
    return fallback;
  }
}

/// Kök uygulama widget'ı.
class TechDebtTycoonApp extends ConsumerWidget {
  const TechDebtTycoonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return MaterialApp(
      title: strings[StringKey.appTitle],
      debugShowCheckedModeBanner: false,
      // Gerçek tema Aşama 3'te `lib/theme/` altından gelecek.
      theme: ThemeData.dark(useMaterial3: true),
      home: const _EngineSmokeScreen(),
    );
  }
}

/// Aşama 2'nin geçici doğrulama ekranı.
///
/// Aşama 3'te gerçek ekranlar (Ofis, Ekip, Sözlük, Log) buranın yerini
/// alacak. Şimdilik motorun, kaydın ve ipucu algoritmasının gerçekten
/// çalıştığını gözle görmeye yarıyor: bir sprint oynatır, metrikleri ve
/// ipucunu gösterir.
class _EngineSmokeScreen extends ConsumerWidget {
  const _EngineSmokeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final state = ref.watch(gameControllerProvider);
    final hint = ref.watch(currentHintProvider);
    final remainingHints = ref.watch(remainingHintsProvider);
    final actions = ref.watch(contentProvider).actions;
    final controller = ref.read(gameControllerProvider.notifier);
    final pendingEvent = controller.pendingEvent;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings[StringKey.appTitle]),
        actions: [
          IconButton(
            tooltip: strings[StringKey.commonNewGame],
            icon: const Icon(Icons.refresh),
            onPressed: controller.startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              strings.format(StringKey.officeWeekLabel, {
                'week': '${state.week}',
              }),
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: strings[StringKey.metricBudget],
              value: '${state.budget}\$',
            ),
            _MetricRow(
              label: strings[StringKey.metricValuation],
              value: '${state.valuation}\$',
            ),
            _MetricRow(
              label: strings[StringKey.metricWeeklyRevenue],
              value: '${state.weeklyRevenue}\$',
            ),
            _MetricRow(
              label: strings[StringKey.metricTechDebt],
              value: '%${state.techDebt}',
            ),
            _MetricRow(
              label: strings[StringKey.metricTeamMorale],
              value: '%${state.teamMorale}',
            ),
            _MetricRow(
              label: strings[StringKey.metricTeamSize],
              value: '${state.team.length}',
            ),
            const Divider(height: 32),
            Text(
              strings[StringKey.officeAdvisorSectionTitle],
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(hint.advice, style: textTheme.bodyLarge),
            Text(hint.reasoning, style: textTheme.bodySmall),
            Text(
              strings.format(StringKey.hintFreeRemaining, {
                'count': '$remainingHints',
              }),
              style: textTheme.bodySmall,
            ),
            const Divider(height: 32),
            if (!state.isPlaying)
              Text(
                state.status == GameStatus.won
                    ? strings[StringKey.gameOverWonTitle]
                    : strings[StringKey.gameOverLostTitle],
                style: textTheme.headlineSmall,
              )
            else if (pendingEvent != null)
              _PendingEventCard(card: pendingEvent, controller: controller)
            else
              ...actions.map(
                (action) => ListTile(
                  title: Text(action.name),
                  subtitle: Text(action.description),
                  enabled: _canAfford(ref, action),
                  onTap: () => _onActionTapped(ref, action),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// İşe alım aksiyonunda geçici olarak ilk adayı seçer.
  ///
  /// Gerçek aday seçimi Aşama 3'teki bottom sheet ile gelecek.
  void _onActionTapped(WidgetRef ref, GameAction action) {
    final controller = ref.read(gameControllerProvider.notifier);
    if (action.requiresHireSelection) {
      final candidate = ref.read(contentProvider).hireOptions.first;
      controller.playSprint(action, hire: candidate);
      return;
    }
    controller.playSprint(action);
  }
}

/// Bütçenin aksiyona yetip yetmediğini sorar.
bool _canAfford(WidgetRef ref, GameAction action) {
  final state = ref.read(gameControllerProvider);
  final hire = action.requiresHireSelection
      ? ref.read(contentProvider).hireOptions.first
      : null;
  return GameEngine.canAfford(state, action, hire: hire);
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}

class _PendingEventCard extends StatelessWidget {
  const _PendingEventCard({required this.card, required this.controller});

  final EventCard card;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(card.narration),
            const SizedBox(height: 12),
            ...card.choices.map(
              (choice) => OutlinedButton(
                onPressed: () => controller.resolveEvent(choice),
                child: Text(choice.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
