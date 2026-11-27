import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/main.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/providers/providers.dart';
import 'package:tech_debt_tycoon/services/storage_service.dart';

/// Uygulamanın gerçekten ayağa kalktığını doğrulayan duman testi.
///
/// `flutter analyze` tip hatalarını yakalıyor ama provider'ların widget
/// ağacında doğru bağlandığını yakalamıyor. Bu test onu yakalar: gerçek
/// `TechDebtTycoonApp` pompalanır, metinler okunur ve bir sprint UI
/// üzerinden oynanır.
///
/// Flutter bağlamı gerektirdiği için `test/widget/` altında duruyor ve
/// yalnızca `flutter test` ile koşuyor (bkz. `dart_test.yaml`).
void main() {
  /// Olay kartı çıkmasın: sprint sonucu deterministik olsun.
  final noEvents = _ScriptedRandom();

  /// Testi uzun bir telefon ekranına ayarlar.
  ///
  /// Varsayılan 800x600 test yüzeyinde `ListView` alt öğeleri çizmiyor ve
  /// `find.text` onları bulamıyor. Oyun zaten dikey modda oynandığı için
  /// gerçekçi bir dikey yüzey kuruyoruz.
  void useTallPhone(WidgetTester tester) {
    // devicePixelRatio 1: fiziksel boyut doğrudan mantıksal boyut olur,
    // böylece gerçekten uzun bir yüzey elde ederiz (dpr 3 verilse
    // 2400 fiziksel piksel yine 800 mantıksal piksele inerdi).
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget app(InMemoryStorageService storage) => ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      randomProvider.overrideWithValue(noEvents),
    ],
    child: const TechDebtTycoonApp(),
  );

  testWidgets('uygulama açılır ve başlangıç metriklerini gösterir', (
    tester,
  ) async {
    useTallPhone(tester);
    final storage = InMemoryStorageService();
    await tester.pumpWidget(app(storage));

    expect(find.text('Tech Debt Tycoon'), findsOneWidget);
    expect(find.text('Hafta 1'), findsOneWidget);
    expect(find.text('15000\$'), findsOneWidget, reason: 'başlangıç bütçesi');
    expect(
      find.text('50000\$'),
      findsOneWidget,
      reason: 'başlangıç değerlemesi',
    );
    // Beş haftalık aksiyon listelenmeli.
    for (final action in kGameActions) {
      expect(find.text(action.name), findsOneWidget, reason: action.id);
    }
  });

  testWidgets('kayıtlı oyun açılışta geri yüklenir', (tester) async {
    useTallPhone(tester);
    final storage = InMemoryStorageService(
      gameState: GameState.newGame().copyWith(week: 23, budget: 77000),
    );
    await tester.pumpWidget(app(storage));

    expect(find.text('Hafta 23'), findsOneWidget);
    expect(find.text('77000\$'), findsOneWidget);
  });

  testWidgets('aksiyona dokununca sprint oynanır ve kayıt yazılır', (
    tester,
  ) async {
    useTallPhone(tester);
    final storage = InMemoryStorageService();
    await tester.pumpWidget(app(storage));

    await tester.tap(find.text(kRefactorAction.name));
    await tester.pump();

    expect(find.text('Hafta 2'), findsOneWidget);
    expect(storage.saveCount, 1);
    expect(storage.loadGameState()!.week, 2);
  });

  testWidgets('oyun sonu ekranı gösterilir', (tester) async {
    useTallPhone(tester);
    final storage = InMemoryStorageService(
      gameState: GameState.newGame().copyWith(
        status: GameStatus.won,
        valuation: 1000000,
      ),
    );
    await tester.pumpWidget(app(storage));

    expect(find.textContaining('UNICORN'), findsOneWidget);
    // Oyun bittiğinde aksiyon listesi gösterilmez.
    expect(find.text(kRefactorAction.name), findsNothing);
  });

  testWidgets('bekleyen olay kartı karar ekranı olarak çıkar', (tester) async {
    useTallPhone(tester);
    final card = eventCardById('event_friday_deploy')!;
    final storage = InMemoryStorageService(
      gameState: GameState.newGame().copyWith(week: 6, pendingEventId: card.id),
    );
    await tester.pumpWidget(app(storage));

    expect(find.text(card.title), findsOneWidget);
    for (final choice in card.choices) {
      expect(find.text(choice.label), findsOneWidget);
    }

    // Bir seçeneğe dokununca kart kapanmalı ve aksiyonlar geri gelmeli.
    await tester.tap(find.text(card.choices.first.label));
    await tester.pump();

    expect(find.text(card.title), findsNothing);
    expect(storage.loadGameState()!.hasPendingEvent, isFalse);
  });

  testWidgets('yeni oyun butonu durumu sıfırlar', (tester) async {
    useTallPhone(tester);
    final storage = InMemoryStorageService(
      gameState: GameState.newGame().copyWith(week: 15),
    );
    await tester.pumpWidget(app(storage));
    expect(find.text('Hafta 15'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.text('Hafta 1'), findsOneWidget);
  });
}

/// Olay kartı asla çıkmasın: `nextDouble` her zaman 1.0 döner.
class _ScriptedRandom implements Random {
  @override
  double nextDouble() => 1;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}
