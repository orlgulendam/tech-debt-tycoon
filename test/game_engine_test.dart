import 'dart:math';

import 'package:test/test.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/data/game_balance.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/services/game_engine.dart';

/// Oyun motoru testleri.
///
/// Motor saf fonksiyonlardan oluştuğu ve rastgeleliği dışarıdan aldığı için
/// her kural deterministik biçimde doğrulanabiliyor.
void main() {
  /// Olay kartı **asla** çıkmasın: nextDouble her zaman 1.0 döner, bu da
  /// `nextDouble() >= chance` koşulunu her olasılıkta sağlar.
  final noEvents = _ScriptedRandom(doubles: const [1.0], ints: const [0]);

  /// Olay kartı **her zaman** çıksın.
  _ScriptedRandom alwaysEvents() =>
      _ScriptedRandom(doubles: const [0.0], ints: const [0]);

  group('applyEffect', () {
    test('bütün alanları uygular ve yüzdeleri sıkıştırır', () {
      final state = GameState.newGame();
      final next = GameEngine.applyEffect(
        state,
        const GameEffect(
          budgetDelta: -1000,
          revenueDelta: 500,
          valuationDelta: 10000,
          techDebtDelta: 200,
          moraleDelta: -200,
        ),
      );

      expect(next.budget, state.budget - 1000);
      expect(next.weeklyRevenue, state.weeklyRevenue + 500);
      expect(next.valuation, state.valuation + 10000);
      expect(next.techDebt, 100, reason: 'üst sınıra sıkışmalı');
      expect(next.teamMorale, 0, reason: 'alt sınıra sıkışmalı');
    });

    test('bütçeyi sıkıştırmaz: negatife düşmesi iflas sinyalidir', () {
      final next = GameEngine.applyEffect(
        GameState.newGame(),
        const GameEffect(budgetDelta: -99000),
      );
      expect(next.budget, lessThan(0));
    });

    test('gelir ve değerleme negatife düşmez', () {
      final next = GameEngine.applyEffect(
        GameState.newGame(),
        const GameEffect(revenueDelta: -99999, valuationDelta: -9999999),
      );
      expect(next.weeklyRevenue, 0);
      expect(next.valuation, 0);
    });
  });

  group('revenueMultiplier', () {
    test('eşik altında ceza yok', () {
      expect(GameEngine.revenueMultiplier(0), 1.0);
      expect(GameEngine.revenueMultiplier(59), 1.0);
      expect(
        GameEngine.revenueMultiplier(GameBalance.debtRevenuePenaltyThreshold),
        1.0,
      );
    });

    test('eşik üstünde her puan geliri azaltır', () {
      expect(GameEngine.revenueMultiplier(70), closeTo(0.9, 1e-9));
      expect(GameEngine.revenueMultiplier(80), closeTo(0.8, 1e-9));
    });

    test('alt sınırın altına inmez', () {
      expect(
        GameEngine.revenueMultiplier(100),
        greaterThanOrEqualTo(GameBalance.minRevenueMultiplier),
      );
    });
  });

  group('collectableCash', () {
    test('ekip yokken temel gelir kadar nakit girer', () {
      final state = GameState.newGame();
      expect(GameEngine.collectableCash(state), state.weeklyRevenue);
    });

    test('ekip katkısı eklenir, maaşlar düşülür', () {
      final state = GameState.newGame().copyWith(
        team: [kSeniorHire.copyWith(id: 's1')],
      );
      // 2000 temel + 2000 katkı - 2600 maaş
      expect(GameEngine.collectableCash(state), 1400);
    });

    test('yüksek teknik borç nakit girişini azaltır', () {
      final healthy = GameState.newGame().copyWith(techDebt: 10);
      final indebted = GameState.newGame().copyWith(techDebt: 90);
      expect(
        GameEngine.collectableCash(indebted),
        lessThan(GameEngine.collectableCash(healthy)),
      );
    });

    test('maaşlar gelirden fazlaysa nakit akışı negatif olur', () {
      final state = GameState.newGame().copyWith(
        weeklyRevenue: 0,
        team: [kSeniorHire.copyWith(id: 's1')],
      );
      expect(GameEngine.collectableCash(state), lessThan(0));
    });
  });

  group('debtPressure', () {
    test('düşük borçta yalnızca doğal artış var', () {
      final effect = GameEngine.debtPressure(10);
      expect(effect.techDebtDelta, GameBalance.weeklyDebtDrift);
      expect(effect.moraleDelta, 0);
    });

    test('yüksek borçta moral cezası eklenir', () {
      final effect = GameEngine.debtPressure(65);
      expect(effect.moraleDelta, -GameBalance.debtMoralePenalty);
    });

    test('çok yüksek borçta moral cezası ikiye katlanır', () {
      final effect = GameEngine.debtPressure(85);
      expect(effect.moraleDelta, -GameBalance.debtMoralePenalty * 2);
    });
  });

  group('evaluateOutcome', () {
    test('hedefe ulaşınca kazanılır', () {
      final state = GameState.newGame().copyWith(valuation: 1000000);
      expect(GameEngine.evaluateOutcome(state).status, GameStatus.won);
    });

    test('bütçe sıfıra düşünce iflas', () {
      final state = GameState.newGame().copyWith(budget: 0);
      final result = GameEngine.evaluateOutcome(state);
      expect(result.status, GameStatus.lost);
      expect(result.lossReason, LossReason.bankruptcy);
    });

    test('teknik borç %100 olunca sunucular yanar', () {
      final state = GameState.newGame().copyWith(techDebt: 100);
      final result = GameEngine.evaluateOutcome(state);
      expect(result.lossReason, LossReason.serverMeltdown);
    });

    test('moral sıfırlanınca toplu istifa', () {
      final state = GameState.newGame().copyWith(teamMorale: 0);
      final result = GameEngine.evaluateOutcome(state);
      expect(result.lossReason, LossReason.massResignation);
    });

    test('aynı anda kazanma ve kaybetme varsa kazanma kazanır', () {
      final state = GameState.newGame().copyWith(
        valuation: 1000000,
        budget: -500,
        techDebt: 100,
      );
      final result = GameEngine.evaluateOutcome(state);
      expect(result.status, GameStatus.won);
      expect(result.lossReason, isNull);
    });

    test('bitmiş oyuna tekrar bakılmaz', () {
      final won = GameState.newGame().copyWith(status: GameStatus.won);
      expect(GameEngine.evaluateOutcome(won), won);
    });
  });

  group('actionCost / canAfford', () {
    test('bütçe harcayan aksiyonun maliyeti pozitif okunur', () {
      expect(GameEngine.actionCost(kTeamMoraleAction), 3000);
    });

    test('bütçe harcamayan aksiyonun maliyeti sıfır', () {
      expect(GameEngine.actionCost(kShipFeatureAction), 0);
      expect(GameEngine.actionCost(kRefactorAction), 0);
    });

    test('işe alım maliyeti adaya göre hesaplanır', () {
      expect(
        GameEngine.actionCost(kHireAction, hire: kSeniorHire),
        hiringCost(kSeniorHire),
      );
    });

    test('bütçe yetmiyorsa aksiyon seçilemez', () {
      final broke = GameState.newGame().copyWith(budget: 100);
      expect(GameEngine.canAfford(broke, kTeamMoraleAction), isFalse);
      expect(GameEngine.canAfford(broke, kShipFeatureAction), isTrue);
    });
  });

  group('playSprint', () {
    test('hafta ilerler ve aksiyonun etkisi uygulanır', () {
      final start = GameState.newGame();
      final result = GameEngine.playSprint(
        start,
        kShipFeatureAction,
        random: noEvents,
      );

      expect(result.state.week, start.week + 1);
      expect(
        result.state.weeklyRevenue,
        start.weeklyRevenue + kShipFeatureAction.revenueDelta,
      );
      expect(
        result.state.valuation,
        start.valuation + kShipFeatureAction.valuationDelta,
      );
      // +15 aksiyon, +1 doğal artış
      expect(
        result.state.techDebt,
        start.techDebt + 15 + GameBalance.weeklyDebtDrift,
      );
      expect(result.state.teamMorale, start.teamMorale - 6);
    });

    test('haftalık gelir kasaya girer', () {
      final start = GameState.newGame();
      final result = GameEngine.playSprint(
        start,
        kRefactorAction,
        random: noEvents,
      );
      // Refactoring bütçe harcamıyor; kasaya yalnızca gelir girer.
      expect(result.revenueCollected, start.weeklyRevenue);
      expect(result.state.budget, start.budget + start.weeklyRevenue);
    });

    test('refactoring teknik borcu eritir', () {
      final start = GameState.newGame().copyWith(techDebt: 50);
      final result = GameEngine.playSprint(
        start,
        kRefactorAction,
        random: noEvents,
      );
      // -25 aksiyon, +1 doğal artış
      expect(result.state.techDebt, 26);
      expect(result.state.teamMorale, start.teamMorale + 8);
    });

    test('ekip motivasyonu bütçeden düşer, morali yükseltir', () {
      final start = GameState.newGame();
      final result = GameEngine.playSprint(
        start,
        kTeamMoraleAction,
        random: noEvents,
      );
      expect(result.state.budget, start.budget - 3000 + start.weeklyRevenue);
      expect(result.state.teamMorale, start.teamMorale + 20);
    });

    test('işe alım adayı ekibe tekil kimlikle ekler', () {
      final start = GameState.newGame();
      final result = GameEngine.playSprint(
        start,
        kHireAction,
        hire: kDevOpsHire,
        random: noEvents,
      );

      expect(result.state.team, hasLength(1));
      expect(result.hiredEmployee, isNotNull);
      expect(result.state.team.single.id, isNot(kDevOpsHire.id));
      expect(result.state.team.single.id, contains('hire_devops'));
      expect(result.state.team.single.level, EmployeeLevel.devops);
    });

    test('işe alım tek seferlik maliyeti bütçeden düşer', () {
      final start = GameState.newGame();
      final result = GameEngine.playSprint(
        start,
        kHireAction,
        hire: kJuniorHire,
        random: noEvents,
      );
      // -işe alım maliyeti + (temel gelir + katkı - maaş)
      final expected =
          start.budget -
          hiringCost(kJuniorHire) +
          (start.weeklyRevenue +
              kJuniorHire.revenueContribution -
              kJuniorHire.weeklySalary);
      expect(result.state.budget, expected);
    });

    test('ekip katkısı haftalık gelire kalıcı olarak eklenmez', () {
      // Bu, bilinçli bir tasarım kararı: çalışan katkısı her hafta yeniden
      // hesaplanır, birikmez. Aksi hâlde tek işe alım geliri sonsuza
      // kadar katlardı.
      var state = GameState.newGame();
      state = GameEngine.playSprint(
        state,
        kHireAction,
        hire: kSeniorHire,
        random: noEvents,
      ).state;
      final revenueAfterHire = state.weeklyRevenue;

      state = GameEngine.playSprint(
        state,
        kRefactorAction,
        random: noEvents,
      ).state;

      expect(state.weeklyRevenue, revenueAfterHire);
    });

    test('işe alım aksiyonunda aday verilmezse hata atar', () {
      expect(
        () => GameEngine.playSprint(
          GameState.newGame(),
          kHireAction,
          random: noEvents,
        ),
        throwsArgumentError,
      );
    });

    test('bitmiş oyunda sprint oynatılamaz', () {
      final lost = GameState.newGame().copyWith(status: GameStatus.lost);
      expect(
        () => GameEngine.playSprint(lost, kRefactorAction, random: noEvents),
        throwsStateError,
      );
    });

    test('karar bekleyen olay varken sprint oynatılamaz', () {
      final pending = GameState.newGame().copyWith(
        pendingEventId: 'event_friday_deploy',
      );
      expect(
        () => GameEngine.playSprint(pending, kRefactorAction, random: noEvents),
        throwsStateError,
      );
    });

    test('sonuç önceki durumu da taşır', () {
      final start = GameState.newGame();
      final result = GameEngine.playSprint(
        start,
        kCleanCodeAction,
        random: noEvents,
      );
      expect(result.previousState, start);
      expect(result.action, kCleanCodeAction);
      expect(result.budgetChange, result.state.budget - start.budget);
    });

    test('kazanma koşulu sprint sonunda yakalanır', () {
      final almost = GameState.newGame().copyWith(valuation: 999000);
      final result = GameEngine.playSprint(
        almost,
        kShipFeatureAction,
        random: noEvents,
      );
      expect(result.state.status, GameStatus.won);
      expect(result.isGameOver, isTrue);
    });

    test('bütçe tükenince iflasla biter', () {
      final broke = GameState.newGame().copyWith(
        budget: 3000,
        weeklyRevenue: 0,
      );
      final result = GameEngine.playSprint(
        broke,
        kTeamMoraleAction,
        random: noEvents,
      );
      expect(result.state.status, GameStatus.lost);
      expect(result.state.lossReason, LossReason.bankruptcy);
    });
  });

  group('olay kartı çekilişi', () {
    test('ilk haftalarda olay çıkmaz', () {
      final state = GameState.newGame();
      expect(
        GameEngine.rollEvent(state, alwaysEvents()),
        isNull,
        reason: 'hafta ${state.week} bağışıklık penceresinde',
      );
    });

    test('sonraki haftalarda olay çıkabilir', () {
      final state = GameState.newGame().copyWith(week: 5);
      expect(GameEngine.rollEvent(state, alwaysEvents()), isNotNull);
    });

    test('olasılık tutmazsa olay çıkmaz', () {
      final state = GameState.newGame().copyWith(week: 5);
      expect(GameEngine.rollEvent(state, noEvents), isNull);
    });

    test('yüksek teknik borç olay olasılığını artırır', () {
      expect(
        GameEngine.eventChance(90),
        greaterThan(GameEngine.eventChance(10)),
      );
      expect(
        GameEngine.eventChance(100),
        lessThanOrEqualTo(GameBalance.maxEventChance),
      );
    });

    test('görülmemiş kartlar tercih edilir', () {
      final firstCard = kEventCards.first;
      final state = GameState.newGame().copyWith(
        week: 99,
        seenEventIds: [firstCard.id],
      );
      // ints her zaman 0 döner → havuzun ilk elemanı seçilir. Görülmüş kart
      // havuzdan çıktığı için ilk eleman artık o olmamalı.
      final drawn = GameEngine.rollEvent(state, alwaysEvents());
      expect(drawn, isNotNull);
      expect(drawn!.id, isNot(firstCard.id));
    });

    test('bütün kartlar görülmüşse havuz baştan başlar', () {
      final state = GameState.newGame().copyWith(
        week: 99,
        seenEventIds: kEventCards.map((c) => c.id).toList(),
      );
      expect(GameEngine.rollEvent(state, alwaysEvents()), isNotNull);
    });

    test('olay çıkınca duruma bekleyen kart olarak yazılır', () {
      final start = GameState.newGame().copyWith(week: 5);
      final result = GameEngine.playSprint(
        start,
        kRefactorAction,
        random: alwaysEvents(),
      );
      expect(result.triggeredEvent, isNotNull);
      expect(result.state.pendingEventId, result.triggeredEvent!.id);
      expect(result.state.hasPendingEvent, isTrue);
    });
  });

  group('resolveEvent', () {
    EventCard card() => eventCardById('event_friday_deploy')!;

    GameState pendingState() => GameState.newGame().copyWith(
      week: 5,
      pendingEventId: 'event_friday_deploy',
    );

    test('seçeneğin etkisi uygulanır ve kart kapanır', () {
      final state = pendingState();
      final choice = card().choiceById('deploy_now')!;
      final resolution = GameEngine.resolveEvent(state, card(), choice);

      expect(resolution.state.hasPendingEvent, isFalse);
      expect(resolution.state.seenEventIds, contains(card().id));
      expect(
        resolution.state.techDebt,
        state.techDebt + choice.effect.techDebtDelta,
      );
      expect(
        resolution.state.valuation,
        state.valuation + choice.effect.valuationDelta,
      );
    });

    test('krizi çözen seçenek sayacı artırır', () {
      final state = pendingState();
      final choice = card().choiceById('deploy_monday')!;
      expect(choice.resolvesCrisis, isTrue);

      final resolution = GameEngine.resolveEvent(state, card(), choice);
      expect(resolution.state.resolvedCrises, state.resolvedCrises + 1);
      expect(resolution.resolvedCrisis, isTrue);
    });

    test('krizi çözmeyen seçenek sayacı artırmaz', () {
      final state = pendingState();
      final choice = card().choiceById('deploy_now')!;
      expect(choice.resolvesCrisis, isFalse);

      final resolution = GameEngine.resolveEvent(state, card(), choice);
      expect(resolution.state.resolvedCrises, state.resolvedCrises);
    });

    test('bekleyen kart başkasıysa hata atar', () {
      final state = GameState.newGame().copyWith(pendingEventId: 'baska_id');
      expect(
        () => GameEngine.resolveEvent(state, card(), card().choices.first),
        throwsStateError,
      );
    });

    test('karta ait olmayan seçenek hata atar', () {
      final other = eventCardById('event_cloud_bill')!;
      expect(
        () => GameEngine.resolveEvent(
          pendingState(),
          card(),
          other.choices.first,
        ),
        throwsArgumentError,
      );
    });

    test('aynı kart iki kez görülmüş listesine eklenmez', () {
      final state = pendingState().copyWith(
        seenEventIds: ['event_friday_deploy'],
      );
      final resolution = GameEngine.resolveEvent(
        state,
        card(),
        card().choices.first,
      );
      expect(
        resolution.state.seenEventIds
            .where((id) => id == 'event_friday_deploy')
            .length,
        1,
      );
    });

    test('olay seçimi oyunu bitirebilir', () {
      final fragile = GameState.newGame().copyWith(
        week: 5,
        valuation: 999000,
        pendingEventId: 'event_friday_deploy',
      );
      final resolution = GameEngine.resolveEvent(
        fragile,
        card(),
        card().choiceById('deploy_now')!,
      );
      expect(resolution.state.status, GameStatus.won);
      expect(resolution.isGameOver, isTrue);
    });
  });

  group('ipucu hakkı', () {
    test('yeni oyunda ücretsiz hak kadar ipucu var', () {
      final state = GameState.newGame();
      expect(GameEngine.remainingHints(state), GameBalance.freeHintsPerGame);
      expect(GameEngine.canUseHint(state), isTrue);
    });

    test('kullanılan ipuçları haktan düşer', () {
      final state = GameState.newGame().copyWith(
        usedFreeHints: GameBalance.freeHintsPerGame,
      );
      expect(GameEngine.remainingHints(state), 0);
      expect(GameEngine.canUseHint(state), isFalse);
    });

    test('danışman tutmak hak ekler', () {
      final state = GameState.newGame().copyWith(
        usedFreeHints: GameBalance.freeHintsPerGame,
        hiredConsultants: 2,
      );
      expect(
        GameEngine.remainingHints(state),
        2 * GameBalance.hintsPerConsultant,
      );
    });

    test('kalan hak negatife düşmez', () {
      final state = GameState.newGame().copyWith(usedFreeHints: 99);
      expect(GameEngine.remainingHints(state), 0);
    });
  });

  group('uzun oyun dayanıklılığı', () {
    test('200 hafta boyunca durum hiçbir zaman geçersiz olmaz', () {
      // Rastgele aksiyonlarla uzun bir oyun koştur: yüzdeler aralık dışına
      // çıkmamalı, oyun bittiğinde de bir neden taşımalı.
      final random = Random(42);
      var state = GameState.newGame();

      for (var i = 0; i < 200 && state.isPlaying; i++) {
        if (state.hasPendingEvent) {
          final card = eventCardById(state.pendingEventId!)!;
          final choice = card.choices[random.nextInt(card.choices.length)];
          state = GameEngine.resolveEvent(state, card, choice).state;
          continue;
        }

        final affordable = kGameActions
            .where(
              (a) => GameEngine.canAfford(
                state,
                a,
                hire: a.requiresHireSelection ? kJuniorHire : null,
              ),
            )
            .toList();
        final action = affordable[random.nextInt(affordable.length)];

        state = GameEngine.playSprint(
          state,
          action,
          hire: action.requiresHireSelection ? kJuniorHire : null,
          random: random,
        ).state;

        expect(state.techDebt, inInclusiveRange(0, 100));
        expect(state.teamMorale, inInclusiveRange(0, 100));
        expect(state.weeklyRevenue, greaterThanOrEqualTo(0));
        expect(state.valuation, greaterThanOrEqualTo(0));
      }

      if (!state.isPlaying) {
        expect(
          state.status == GameStatus.won || state.lossReason != null,
          isTrue,
          reason: 'kaybedilen oyunun nedeni olmalı',
        );
      }
    });

    test('hiçbir şey yapmasa bile teknik borç birikir', () {
      var state = GameState.newGame();
      final startDebt = state.techDebt;
      for (var i = 0; i < 5; i++) {
        state = GameEngine.playSprint(
          state,
          kCleanCodeAction,
          random: noEvents,
        ).state;
      }
      expect(state.techDebt, greaterThan(startDebt));
    });
  });
}

/// Testlerde deterministik rastgelelik için önceden yazılmış [Random].
///
/// `nextDouble` ve `nextInt` verilen listeleri sırayla döner, liste bitince
/// başa sarar. Böylece "olay her zaman çıksın" / "asla çıkmasın" gibi
/// senaryolar kesin biçimde kurulabiliyor.
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
