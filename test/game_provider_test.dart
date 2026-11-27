import 'dart:math';

import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/data/game_balance.dart';
import 'package:tech_debt_tycoon/l10n/l10n.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/providers/providers.dart';
import 'package:tech_debt_tycoon/services/ad_service.dart';
import 'package:tech_debt_tycoon/services/storage_service.dart';

/// Riverpod katmanı testleri: otomatik kayıt, devam ettirme ve oyun akışı.
///
/// Provider'lar saf Dart `riverpod` kullandığı için bu testler Flutter
/// motoru başlatmadan `dart test` ile koşuyor.
void main() {
  /// Olay kartı asla çıkmasın (nextDouble her zaman 1.0).
  final noEvents = _ScriptedRandom(doubles: const [1.0], ints: const [0]);

  /// Test için kap kurar; depolama ve rastgeleliği enjekte eder.
  ({ProviderContainer container, InMemoryStorageService storage}) harness({
    GameState? saved,
    List<GameRecord>? records,
    Random? random,
    AdService? ads,
  }) {
    final storage = InMemoryStorageService(gameState: saved, records: records);
    final container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        randomProvider.overrideWithValue(random ?? noEvents),
        if (ads != null) adServiceProvider.overrideWithValue(ads),
      ],
    );
    addTearDown(container.dispose);
    return (container: container, storage: storage);
  }

  group('başlatma ve devam ettirme', () {
    test('kayıt yoksa yeni oyun başlar', () {
      final h = harness();
      expect(h.container.read(gameControllerProvider), GameState.newGame());
    });

    test('kayıtlı oyun varsa kaldığı haftadan devam eder', () {
      final saved = GameState.newGame().copyWith(
        week: 17,
        budget: 42000,
        techDebt: 48,
        team: [kSeniorHire.copyWith(id: 's1')],
      );
      final h = harness(saved: saved);

      expect(h.container.read(gameControllerProvider), saved);
    });

    test('karar bekleyen olay kartı kayıttan geri gelir', () {
      final saved = GameState.newGame().copyWith(
        week: 6,
        pendingEventId: 'event_cloud_bill',
      );
      final h = harness(saved: saved);
      final controller = h.container.read(gameControllerProvider.notifier);

      expect(controller.pendingEvent, isNotNull);
      expect(controller.pendingEvent!.id, 'event_cloud_bill');
    });

    test('tanınmayan bekleyen olay kimliği çökertmez', () {
      final saved = GameState.newGame().copyWith(
        pendingEventId: 'silinmis_kart',
      );
      final h = harness(saved: saved);

      expect(
        h.container.read(gameControllerProvider.notifier).pendingEvent,
        isNull,
      );
    });
  });

  group('otomatik kayıt', () {
    test('her sprint sonunda kayıt yazılır', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      controller.playSprint(kRefactorAction);
      expect(h.storage.saveCount, 1);

      controller.playSprint(kCleanCodeAction);
      expect(h.storage.saveCount, 2);
    });

    test('kaydedilen durum o anki durumla aynı', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      controller.playSprint(kShipFeatureAction);

      expect(
        h.storage.loadGameState(),
        h.container.read(gameControllerProvider),
      );
    });

    test('ipucu kullanımı da kaydedilir', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      expect(controller.useHint(), isTrue);
      expect(h.storage.saveCount, 1);
      expect(h.storage.loadGameState()!.usedFreeHints, 1);
    });

    test('yeni oyun kaydın üstüne yazar', () {
      final h = harness(saved: GameState.newGame().copyWith(week: 30));
      final controller = h.container.read(gameControllerProvider.notifier);

      controller.startNewGame();

      expect(h.container.read(gameControllerProvider).week, 1);
      expect(h.storage.loadGameState()!.week, 1);
    });
  });

  group('sprint oynatma', () {
    test('geçerli aksiyon durumu ilerletir', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      final result = controller.playSprint(kRefactorAction);

      expect(result, isNotNull);
      expect(h.container.read(gameControllerProvider).week, 2);
      expect(controller.lastSprint, result);
    });

    test('bütçe yetmiyorsa sessizce reddedilir', () {
      final h = harness(saved: GameState.newGame().copyWith(budget: 100));
      final controller = h.container.read(gameControllerProvider.notifier);

      expect(controller.playSprint(kTeamMoraleAction), isNull);
      expect(h.container.read(gameControllerProvider).week, 1);
      expect(h.storage.saveCount, 0);
    });

    test('işe alım aksiyonunda aday verilmezse reddedilir', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      expect(controller.playSprint(kHireAction), isNull);
      expect(h.container.read(gameControllerProvider).week, 1);
    });

    test('işe alım adayı ekibe eklenir', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      controller.playSprint(kHireAction, hire: kDevOpsHire);

      final team = h.container.read(gameControllerProvider).team;
      expect(team, hasLength(1));
      expect(team.single.level, EmployeeLevel.devops);
    });

    test('karar bekleyen olay varken yeni sprint oynanmaz', () {
      final h = harness(
        saved: GameState.newGame().copyWith(
          week: 5,
          pendingEventId: 'event_cloud_bill',
        ),
      );
      final controller = h.container.read(gameControllerProvider.notifier);

      expect(controller.playSprint(kRefactorAction), isNull);
    });

    test('oyun bittikten sonra sprint oynanmaz', () {
      final h = harness(
        saved: GameState.newGame().copyWith(
          status: GameStatus.lost,
          lossReason: LossReason.bankruptcy,
        ),
      );
      final controller = h.container.read(gameControllerProvider.notifier);

      expect(controller.playSprint(kRefactorAction), isNull);
    });
  });

  group('olay kartı çözme', () {
    ({ProviderContainer container, InMemoryStorageService storage})
    withPendingEvent() => harness(
      saved: GameState.newGame().copyWith(
        week: 6,
        pendingEventId: 'event_friday_deploy',
      ),
    );

    test('seçim uygulanır ve kart kapanır', () {
      final h = withPendingEvent();
      final controller = h.container.read(gameControllerProvider.notifier);
      final card = controller.pendingEvent!;

      final resolution = controller.resolveEvent(
        card.choiceById('deploy_monday')!,
      );

      expect(resolution, isNotNull);
      expect(h.container.read(gameControllerProvider).hasPendingEvent, isFalse);
      expect(controller.lastEventResolution, resolution);
      expect(h.storage.saveCount, 1);
    });

    test('krizi çözen seçim sayacı artırır', () {
      final h = withPendingEvent();
      final controller = h.container.read(gameControllerProvider.notifier);
      final card = controller.pendingEvent!;

      controller.resolveEvent(card.choiceById('deploy_monday')!);

      expect(h.container.read(gameControllerProvider).resolvedCrises, 1);
    });

    test('bekleyen olay yokken çözme reddedilir', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);
      final card = eventCardById('event_friday_deploy')!;

      expect(controller.resolveEvent(card.choices.first), isNull);
    });

    test('karta ait olmayan seçenek reddedilir', () {
      final h = withPendingEvent();
      final controller = h.container.read(gameControllerProvider.notifier);
      final other = eventCardById('event_cloud_bill')!;

      expect(controller.resolveEvent(other.choices.first), isNull);
    });
  });

  group('ipuçları ve reklam', () {
    test('ücretsiz haklar bitince ipucu kullanılamaz', () {
      final h = harness();
      final controller = h.container.read(gameControllerProvider.notifier);

      for (var i = 0; i < GameBalance.freeHintsPerGame; i++) {
        expect(controller.useHint(), isTrue, reason: '${i + 1}. ipucu');
      }
      expect(controller.useHint(), isFalse);
      expect(h.container.read(remainingHintsProvider), 0);
    });

    test('reklam izlenince danışman tutulur ve hak eklenir', () async {
      final h = harness(ads: const StubAdService(AdOutcome.rewarded));
      final controller = h.container.read(gameControllerProvider.notifier);

      // Önce bütün ücretsiz hakları tüket.
      for (var i = 0; i < GameBalance.freeHintsPerGame; i++) {
        controller.useHint();
      }
      expect(controller.useHint(), isFalse);

      final outcome = await controller.watchAdForHint();

      expect(outcome, AdOutcome.rewarded);
      expect(h.container.read(gameControllerProvider).hiredConsultants, 1);
      expect(controller.useHint(), isTrue);
    });

    test('reklam başarısız olursa hak verilmez', () async {
      final h = harness(ads: const StubAdService(AdOutcome.failed));
      final controller = h.container.read(gameControllerProvider.notifier);

      final outcome = await controller.watchAdForHint();

      expect(outcome, AdOutcome.failed);
      expect(h.container.read(gameControllerProvider).hiredConsultants, 0);
    });

    test('reklam iptal edilirse hak verilmez', () async {
      final h = harness(ads: const StubAdService(AdOutcome.cancelled));
      final controller = h.container.read(gameControllerProvider.notifier);

      await controller.watchAdForHint();

      expect(h.container.read(gameControllerProvider).hiredConsultants, 0);
    });

    test('ipucu provider durumu takip eder', () {
      final h = harness(saved: GameState.newGame().copyWith(techDebt: 90));

      final hint = h.container.read(currentHintProvider);
      expect(hint.metric, HintMetric.techDebt);
      expect(hint.isUrgent, isTrue);
    });
  });

  group('oyun sonu ve kariyer geçmişi', () {
    test('kazanılan oyun geçmişe yazılır ve devam kaydı silinir', () {
      final h = harness(
        saved: GameState.newGame().copyWith(week: 20, valuation: 999000),
      );
      final controller = h.container.read(gameControllerProvider.notifier);

      final result = controller.playSprint(kShipFeatureAction);

      expect(result!.state.status, GameStatus.won);
      final records = h.storage.loadRecords();
      expect(records, hasLength(1));
      expect(records.single.isWin, isTrue);
      expect(records.single.weeksSurvived, result.state.week);
      expect(records.single.ctoNote, isNotEmpty);
      // Bitmiş oyun "devam eden oyun" olarak kalmamalı.
      expect(h.storage.loadGameState(), isNull);
    });

    test('kaybedilen oyun nedeniyle birlikte geçmişe yazılır', () {
      // Gelir yok, maaş var: bir sprint sonunda kasa negatife düşer.
      // (Bedeli olan bir aksiyon seçmek işe yaramaz; bütçe yetmediği için
      // `canAfford` sprint'i hiç başlatmaz.)
      final h = harness(
        saved: GameState.newGame().copyWith(
          budget: 1000,
          weeklyRevenue: 0,
          team: [kSeniorHire.copyWith(id: 's1', revenueContribution: 0)],
        ),
      );
      final controller = h.container.read(gameControllerProvider.notifier);

      final result = controller.playSprint(kRefactorAction);
      expect(result, isNotNull);
      expect(result!.state.status, GameStatus.lost);

      final record = h.storage.loadRecords().single;
      expect(record.outcome, GameStatus.lost);
      expect(record.lossReason, LossReason.bankruptcy);
      expect(record.ctoNote, 'lost_bankruptcy');
    });

    test('CTO notu anahtarı her zaman çözülebilir bir metne işaret eder', () {
      final strings = AppStrings.of(AppLanguage.tr);
      for (final note in [
        CtoNoteKeys.wonClean,
        CtoNoteKeys.wonWithDebt,
        CtoNoteKeys.lostBankruptcy,
        CtoNoteKeys.lostMeltdown,
        CtoNoteKeys.lostResignation,
      ]) {
        final key = ctoNoteStringKey(note);
        expect(key, isNotNull, reason: note);
        expect(strings[key!].trim(), isNotEmpty, reason: note);
      }
    });

    test('yarıda bırakılan oyun geçmişe yazılmaz', () {
      final h = harness(saved: GameState.newGame().copyWith(week: 12));
      final controller = h.container.read(gameControllerProvider.notifier);

      controller.startNewGame();

      expect(h.storage.loadRecords(), isEmpty);
    });

    test('kariyer özeti geçmişten hesaplanır', () {
      final h = harness(
        records: [
          _record(
            'a',
            DateTime.utc(2026, 1, 1),
            GameStatus.won,
            1000000,
            40,
            6,
          ),
          _record(
            'b',
            DateTime.utc(2026, 2, 1),
            GameStatus.lost,
            300000,
            22,
            3,
          ),
        ],
      );

      final stats = h.container.read(careerStatsProvider);
      expect(stats.totalGames, 2);
      expect(stats.totalWins, 1);
      expect(stats.bestValuation, 1000000);
      expect(stats.longestRunWeeks, 40);
      expect(stats.totalResolvedCrises, 9);
      expect(stats.winRate, 0.5);
      expect(stats.bestProgress, 1.0);
    });

    test('geçmiş boşken kariyer özeti boş döner', () {
      final h = harness();
      expect(h.container.read(careerStatsProvider), CareerStats.empty);
      expect(h.container.read(careerStatsProvider).isEmpty, isTrue);
    });
  });

  group('dil ve onboarding', () {
    test('dil değişince metinler ve içerik yenilenir', () async {
      final h = harness();

      expect(h.container.read(stringsProvider).language, AppLanguage.tr);

      await h.container
          .read(languageProvider.notifier)
          .setLanguage(AppLanguage.en);

      expect(h.container.read(languageProvider), AppLanguage.en);
      expect(h.storage.language, AppLanguage.en);
      // İngilizce çevirisi henüz yok; Türkçeye düşmeli, çökmemeli.
      expect(h.container.read(stringsProvider)[StringKey.navOffice], 'Ofis');
      expect(h.container.read(contentProvider).characters, hasLength(4));
    });

    test('onboarding tamamlanınca kaydedilir', () async {
      final h = harness();

      expect(h.container.read(onboardingProvider), isFalse);
      await h.container.read(onboardingProvider.notifier).complete();

      expect(h.container.read(onboardingProvider), isTrue);
      expect(h.storage.onboardingCompleted, isTrue);
    });

    test('onboarding sıfırlanabilir', () async {
      final h = harness();
      final controller = h.container.read(onboardingProvider.notifier);

      await controller.complete();
      await controller.reset();

      expect(h.container.read(onboardingProvider), isFalse);
      expect(h.storage.onboardingCompleted, isFalse);
    });
  });

  group('uçtan uca oyun', () {
    test('rastgele oynanan oyun ya biter ya da geçerli kalır', () {
      final h = harness(random: Random(1234));
      final controller = h.container.read(gameControllerProvider.notifier);

      for (var i = 0; i < 150; i++) {
        final state = h.container.read(gameControllerProvider);
        if (!state.isPlaying) break;

        if (state.hasPendingEvent) {
          final card = controller.pendingEvent!;
          controller.resolveEvent(card.choices.first);
          continue;
        }

        final played =
            controller.playSprint(kShipFeatureAction) ??
            controller.playSprint(kRefactorAction);
        if (played == null) break;
      }

      final finalState = h.container.read(gameControllerProvider);
      expect(finalState.techDebt, inInclusiveRange(0, 100));
      expect(finalState.teamMorale, inInclusiveRange(0, 100));
      // Oyun bittiyse kaydı geçmişe düşmüş olmalı.
      if (!finalState.isPlaying) {
        expect(h.storage.loadRecords(), isNotEmpty);
      }
    });
  });
}

GameRecord _record(
  String id,
  DateTime playedAt,
  GameStatus outcome,
  int valuation,
  int weeks,
  int crises,
) => GameRecord(
  id: id,
  playedAt: playedAt,
  weeksSurvived: weeks,
  finalValuation: valuation,
  resolvedCrises: crises,
  outcome: outcome,
  lossReason: outcome == GameStatus.lost ? LossReason.bankruptcy : null,
  ctoNote: 'won_clean',
);

/// Testlerde deterministik rastgelelik.
class _ScriptedRandom implements Random {
  _ScriptedRandom({required this.doubles, required this.ints});

  final List<double> doubles;
  final List<int> ints;
  int _doubleIndex = 0;
  int _intIndex = 0;

  @override
  double nextDouble() => doubles[_doubleIndex++ % doubles.length];

  @override
  int nextInt(int max) => ints[_intIndex++ % ints.length] % max;

  @override
  bool nextBool() => nextDouble() < 0.5;
}
