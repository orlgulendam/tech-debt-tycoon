import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/l10n/l10n.dart';
import 'package:tech_debt_tycoon/main.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/providers/providers.dart';
import 'package:tech_debt_tycoon/screens/home_shell.dart';
import 'package:tech_debt_tycoon/screens/onboarding_screen.dart';
import 'package:tech_debt_tycoon/services/storage_service.dart';
import 'package:tech_debt_tycoon/theme/theme.dart';

/// Uygulamanın gerçekten ayağa kalktığını doğrulayan duman testleri.
///
/// `flutter analyze` tip hatalarını yakalıyor ama provider'ların widget
/// ağacında doğru bağlandığını, sekmelerin açıldığını ve sheet'lerin
/// çalıştığını yakalamıyor. Bu dosya onları yakalar.
///
/// Flutter bağlamı gerektirdiği için `test/widget/` altında duruyor ve
/// yalnızca `flutter test` ile koşuyor (bkz. `dart_test.yaml`).
void main() {
  final strings = AppStrings.of(AppLanguage.tr);

  /// Olay kartı asla çıkmasın: sprint sonucu deterministik olsun.
  final noEvents = _ScriptedRandom();

  /// Testi uzun bir telefon ekranına ayarlar.
  ///
  /// Varsayılan 800x600 test yüzeyinde `ListView` alt öğeleri çizmiyor ve
  /// `find.text` onları bulamıyor. `devicePixelRatio` 1 veriyoruz ki
  /// fiziksel boyut doğrudan mantıksal boyut olsun.
  void useTallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget app(InMemoryStorageService storage) => ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      randomProvider.overrideWithValue(noEvents),
    ],
    // Hareket azaltma açık: sonsuz nabız animasyonları pumpAndSettle'ı
    // kilitlemesin ve daktilo efekti metni hemen tam göstersin.
    //
    // MediaQueryData gerçek görünümden türetiliyor; sıfırdan kurulan bir
    // MediaQueryData ekran boyutunu 0x0 yapıyor ve dokunmalar hedefi
    // bulamıyor.
    child: Builder(
      builder: (context) => MediaQuery(
        data: MediaQueryData.fromView(View.of(context))
            .copyWith(disableAnimations: true),
        child: const TechDebtTycoonApp(),
      ),
    ),
  );

  /// Alt navigasyon çubuğundaki sekme etiketini bulur.
  ///
  /// Düz `find.text` yetmiyor: bazı etiketler ekran içinde de geçiyor
  /// (ör. metrik adı). Aramayı navigasyon çubuğuna kısıtlıyoruz.
  Finder navTab(StringKey key) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(strings[key]),
  );

  /// Onboarding'i tamamlanmış sayan depolama (oyuna doğrudan girsin).
  InMemoryStorageService readyStorage({GameState? gameState}) =>
      InMemoryStorageService(gameState: gameState, onboardingCompleted: true);

  group('onboarding', () {
    testWidgets('ilk açılışta tanıtım gösterilir', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(InMemoryStorageService()));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeShell), findsNothing);
      expect(
        find.text(strings[StringKey.onboardingStep1Title]),
        findsOneWidget,
      );
    });

    testWidgets('atla tanıtımı kapatır ve kaydeder', (tester) async {
      useTallPhone(tester);
      final storage = InMemoryStorageService();
      await tester.pumpWidget(app(storage));

      await tester.tap(find.text(strings[StringKey.onboardingSkip]));
      await tester.pumpAndSettle();

      expect(find.byType(HomeShell), findsOneWidget);
      expect(storage.onboardingCompleted, isTrue);
    });

    testWidgets('tanıtım tamamlanmışsa doğrudan oyuna girilir', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));
      await tester.pumpAndSettle();

      expect(find.byType(HomeShell), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('ofis ekranı', () {
    testWidgets('başlangıç metriklerini ve aksiyonları gösterir', (
      tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));
      await tester.pumpAndSettle();

      expect(find.text(strings[StringKey.appTitle]), findsOneWidget);
      // Başlangıç bütçesi ve değerlemesi biçimlendirilmiş hâlde.
      expect(find.text('15.000\$'), findsOneWidget);
      expect(find.text('50.000\$'), findsOneWidget);

      for (final action in kGameActions) {
        expect(find.text(action.name), findsOneWidget, reason: action.id);
      }
    });

    testWidgets('kayıtlı oyun açılışta geri yüklenir', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(
          readyStorage(
            gameState: GameState.newGame().copyWith(week: 23, budget: 77000),
          ),
        ),
      );

      expect(find.text('Hafta 23'), findsOneWidget);
      expect(find.text('77.000\$'), findsOneWidget);
    });

    testWidgets('aksiyona dokununca sprint oynanır ve kayıt yazılır', (
      tester,
    ) async {
      useTallPhone(tester);
      final storage = readyStorage();
      await tester.pumpWidget(app(storage));

      await tester.tap(find.text(kRefactorAction.name));
      await tester.pumpAndSettle();

      expect(find.text('Hafta 2'), findsOneWidget);
      expect(storage.saveCount, 1);
      expect(storage.loadGameState()!.week, 2);
    });

    testWidgets('sprint sonunda hafta kapanış özeti gösterilir', (
      tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(kRefactorAction.name));
      await tester.pumpAndSettle();

      // Kapanan hafta 1'di; özet onu söylemeli.
      expect(find.text('Hafta 1 kapandı'), findsOneWidget);
      expect(find.text(strings[StringKey.sprintResultRevenue]), findsOneWidget);
      expect(
        find.text(strings[StringKey.sprintResultValuationGrowth]),
        findsOneWidget,
      );
      // Olay çıkmadığı için sakin hafta mesajı görünmeli.
      expect(
        find.text(strings[StringKey.sprintResultCalmWeek]),
        findsOneWidget,
      );

      await tester.tap(find.text(strings[StringKey.sprintResultContinue]));
      await tester.pumpAndSettle();

      expect(find.text('Hafta 1 kapandı'), findsNothing);
      expect(find.text(kRefactorAction.name), findsOneWidget);
    });

    testWidgets('oyun biterse kapanış özeti yerine sonuç kartı gelir', (
      tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(
          readyStorage(
            gameState: GameState.newGame().copyWith(
              week: 20,
              valuation: 999000,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(kShipFeatureAction.name));
      await tester.pumpAndSettle();

      expect(find.textContaining('kapandı'), findsNothing);
      expect(find.text(strings[StringKey.gameOverWonTitle]), findsOneWidget);
    });

    testWidgets('bütçe yetmeyen aksiyon kilitli görünür', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(readyStorage(gameState: GameState.newGame().copyWith(budget: 500))),
      );

      // Ekip motivasyonu 3.000$ istiyor; 500$ ile kilitli olmalı.
      expect(
        find.text(strings[StringKey.teamInsufficientBudget]),
        findsWidgets,
      );
    });

    testWidgets('oyun sonu kartı gösterilir ve aksiyonlar gizlenir', (
      tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(
          readyStorage(
            gameState: GameState.newGame().copyWith(
              status: GameStatus.won,
              valuation: 1000000,
            ),
          ),
        ),
      );

      expect(find.text(strings[StringKey.gameOverWonTitle]), findsOneWidget);
      expect(find.text(kRefactorAction.name), findsNothing);
      expect(
        find.text(strings[StringKey.gameOverRestartButton]),
        findsOneWidget,
      );
    });

    testWidgets('yeniden dene oyunu sıfırlar', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(
          readyStorage(
            gameState: GameState.newGame().copyWith(
              week: 30,
              status: GameStatus.lost,
              lossReason: LossReason.bankruptcy,
            ),
          ),
        ),
      );

      await tester.tap(find.text(strings[StringKey.gameOverRestartButton]));
      await tester.pumpAndSettle();

      expect(find.text('Hafta 1'), findsOneWidget);
    });
  });

  group('danışman sheet', () {
    testWidgets('ipucu sorulunca tavsiye ve gerekçe gösterilir', (
      tester,
    ) async {
      useTallPhone(tester);
      final storage = readyStorage(
        gameState: GameState.newGame().copyWith(techDebt: 90),
      );
      await tester.pumpWidget(app(storage));

      await tester.tap(find.text(strings[StringKey.officeAdvisorSectionTitle]));
      await tester.pumpAndSettle();

      expect(find.text(strings[StringKey.hintSheetTitle]), findsOneWidget);

      // Hak harcanması "danışmana sor"a basınca olur, açılışta değil.
      expect(storage.loadGameState()?.usedFreeHints ?? 0, 0);

      await tester.tap(find.text(strings[StringKey.hintAskButton]));
      await tester.pumpAndSettle();

      expect(find.text(strings[StringKey.hintAdviceLabel]), findsOneWidget);
      expect(find.text(strings[StringKey.hintReasonLabel]), findsOneWidget);
      expect(storage.loadGameState()!.usedFreeHints, 1);
    });
  });

  group('olay kartı sheet', () {
    testWidgets('bekleyen kart açılışta gösterilir ve karar verilebilir', (
      tester,
    ) async {
      useTallPhone(tester);
      final card = eventCardById('event_friday_deploy')!;
      final storage = readyStorage(
        gameState: GameState.newGame().copyWith(
          week: 6,
          pendingEventId: card.id,
        ),
      );
      await tester.pumpWidget(app(storage));
      await tester.pumpAndSettle();

      expect(find.text(card.title), findsOneWidget);
      for (final choice in card.choices) {
        expect(find.text(choice.label), findsOneWidget, reason: choice.id);
      }

      await tester.tap(find.text(card.choices.first.label));
      await tester.pumpAndSettle();

      // Seçimden sonra sonuç aşaması gelir.
      expect(find.text(strings[StringKey.eventOutcomeTitle]), findsOneWidget);
      expect(storage.loadGameState()!.hasPendingEvent, isFalse);

      await tester.tap(find.text(strings[StringKey.eventContinueButton]));
      await tester.pumpAndSettle();

      expect(find.text(card.title), findsNothing);
    });
  });

  group('sekmeler', () {
    testWidgets('dört sekme de açılıyor', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));

      // Ekip
      await tester.tap(navTab(StringKey.navTeam));
      await tester.pumpAndSettle();
      expect(find.text(strings[StringKey.teamEmptyMessage]), findsOneWidget);

      // Sözlük
      await tester.tap(navTab(StringKey.navGlossary));
      await tester.pumpAndSettle();
      expect(find.text('Technical Debt'), findsOneWidget);

      // Log
      await tester.tap(navTab(StringKey.navLog));
      await tester.pumpAndSettle();
      expect(find.text(strings[StringKey.logEmptyMessage]), findsOneWidget);

      // Ofis'e geri dön
      await tester.tap(navTab(StringKey.navOffice));
      await tester.pumpAndSettle();
      expect(find.text(kRefactorAction.name), findsOneWidget);
    });

    testWidgets('sözlükte arama süzme yapıyor', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));

      await tester.tap(navTab(StringKey.navGlossary));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'rollback');
      await tester.pumpAndSettle();

      expect(find.text('Rollback'), findsOneWidget);
      expect(find.text('Technical Debt'), findsNothing);
    });

    testWidgets('sözlük araması Türkçe karaktere duyarsız', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));

      await tester.tap(navTab(StringKey.navGlossary));
      await tester.pumpAndSettle();

      // "borc" yazıp "borç" içeren terimleri bulmalı.
      await tester.enterText(find.byType(TextField), 'borc');
      await tester.pumpAndSettle();

      expect(find.text('Technical Debt'), findsOneWidget);
    });

    testWidgets('sözlük terimine dokununca detay sheet açılır', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(app(readyStorage()));

      await tester.tap(navTab(StringKey.navGlossary));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Technical Debt'));
      await tester.pumpAndSettle();

      expect(
        find.text(strings[StringKey.glossaryDefinitionLabel].toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(strings[StringKey.glossaryGameEffectLabel].toUpperCase()),
        findsOneWidget,
      );
    });
  });

  group('ekip sekmesi', () {
    testWidgets('işe alım sheet açılıp aday işe alınabiliyor', (tester) async {
      useTallPhone(tester);
      final storage = readyStorage();
      await tester.pumpWidget(app(storage));

      await tester.tap(navTab(StringKey.navTeam));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings[StringKey.teamHireButton]));
      await tester.pumpAndSettle();

      // Adayların hepsi listelenmeli.
      for (final candidate in kHireOptions) {
        expect(find.text(candidate.name), findsOneWidget, reason: candidate.id);
      }

      // İlk adayın "işe al" butonuna bas.
      await tester.tap(
        find.textContaining(strings[StringKey.teamHireButton]).last,
      );
      await tester.pumpAndSettle();

      expect(storage.loadGameState()!.team, hasLength(1));
    });

    testWidgets('kadro dolu olduğunda çalışanlar listeleniyor', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(
          readyStorage(
            gameState: GameState.newGame().copyWith(
              team: [kSeniorHire.copyWith(id: 's1')],
            ),
          ),
        ),
      );

      await tester.tap(navTab(StringKey.navTeam));
      await tester.pumpAndSettle();

      expect(find.text(kSeniorHire.name), findsOneWidget);
      expect(find.text(strings[StringKey.teamEmptyMessage]), findsNothing);
    });
  });

  group('yeni oyun', () {
    testWidgets('onay istenir ve onaylanınca sıfırlanır', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(readyStorage(gameState: GameState.newGame().copyWith(week: 15))),
      );
      expect(find.text('Hafta 15'), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.newGame));
      await tester.pumpAndSettle();

      expect(
        find.text(strings[StringKey.commonNewGameConfirmTitle]),
        findsOneWidget,
      );

      await tester.tap(find.text(strings[StringKey.commonNewGame]).last);
      await tester.pumpAndSettle();

      expect(find.text('Hafta 1'), findsOneWidget);
    });

    testWidgets('iptal edilince oyun korunur', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        app(readyStorage(gameState: GameState.newGame().copyWith(week: 15))),
      );

      await tester.tap(find.byIcon(AppIcons.newGame));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings[StringKey.commonCancel]));
      await tester.pumpAndSettle();

      expect(find.text('Hafta 15'), findsOneWidget);
    });
  });

  group('log sekmesi', () {
    testWidgets('geçmiş kayıtlar ve kariyer özeti gösterilir', (tester) async {
      useTallPhone(tester);
      final storage = InMemoryStorageService(
        onboardingCompleted: true,
        records: [
          GameRecord(
            id: '1',
            playedAt: DateTime.utc(2026, 5, 20),
            weeksSurvived: 31,
            finalValuation: 1000000,
            resolvedCrises: 7,
            outcome: GameStatus.won,
            ctoNote: 'won_clean',
          ),
        ],
      );
      await tester.pumpWidget(app(storage));

      await tester.tap(navTab(StringKey.navLog));
      await tester.pumpAndSettle();

      expect(find.text(strings[StringKey.logOutcomeWin]), findsOneWidget);
      expect(find.text('20.05.2026'), findsOneWidget);
      expect(find.text('1.000.000\$'), findsOneWidget);
      // CTO notu anahtardan çözülüp gösterilmeli.
      expect(find.text(strings[StringKey.ctoNoteWonClean]), findsOneWidget);
    });
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
