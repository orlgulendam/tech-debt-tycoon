import 'dart:math';

import '../data/actions.dart';
import '../data/events.dart';
import '../data/game_balance.dart';
import '../models/models.dart';

/// Oyunun kuralları.
///
/// Tamamen **saf fonksiyonlardan** oluşur: içeride durum tutmaz, Riverpod
/// ya da Flutter bilmez, rastgeleliği çağırandan alır. Bu yüzden her kural
/// `dart test` ile deterministik biçimde test edilebilir.
///
/// Haftalık akış:
/// 1. Oyuncu bir aksiyon seçer → [playSprint]
/// 2. Hafta sonunda olay kartı çıkabilir → [SprintResult.triggeredEvent]
/// 3. Oyuncu olayı karara bağlar → [resolveEvent]
abstract final class GameEngine {
  /// Bir efekti duruma uygular ve yüzdeleri 0-100 aralığına sıkıştırır.
  ///
  /// Bütçe bilinçli olarak sıkıştırılmaz: negatife düşmesi iflas demektir ve
  /// [evaluateOutcome] bunu görmek zorundadır.
  static GameState applyEffect(GameState state, GameEffect effect) {
    return state
        .copyWith(
          budget: state.budget + effect.budgetDelta,
          // Gelir ve değerleme negatif olamaz.
          weeklyRevenue: max(0, state.weeklyRevenue + effect.revenueDelta),
          valuation: max(0, state.valuation + effect.valuationDelta),
          techDebt: state.techDebt + effect.techDebtDelta,
          teamMorale: state.teamMorale + effect.moraleDelta,
        )
        .clamped();
  }

  /// Teknik borcun gelire uyguladığı çarpan (0.0 - 1.0).
  ///
  /// Borç [GameBalance.debtRevenuePenaltyThreshold] altındaysa ceza yok.
  /// Üstündeyse her puan geliri biraz daha ısırır, ama çarpan
  /// [GameBalance.minRevenueMultiplier] altına inmez.
  static double revenueMultiplier(int techDebt) {
    if (techDebt <= GameBalance.debtRevenuePenaltyThreshold) return 1;
    final excess = techDebt - GameBalance.debtRevenuePenaltyThreshold;
    final multiplier = 1 - excess * GameBalance.revenuePenaltyPerDebtPoint;
    return max(GameBalance.minRevenueMultiplier, multiplier);
  }

  /// Bu hafta kasaya girecek net nakit ($).
  ///
  /// Temel gelir + ekip katkısı, teknik borç cezası uygulanır, sonra
  /// maaşlar düşülür. Negatif olabilir.
  static int collectableCash(GameState state) {
    final gross = state.weeklyRevenue + state.totalTeamRevenue;
    final afterPenalty = (gross * revenueMultiplier(state.techDebt)).round();
    return afterPenalty - state.totalSalaries;
  }

  /// Teknik borcun doğal artışı ve yüksek borcun moral cezası.
  static GameEffect debtPressure(int techDebt) {
    var moralePenalty = 0;
    if (techDebt >= GameBalance.debtMoralePenaltyThreshold) {
      moralePenalty = GameBalance.debtMoralePenalty;
      if (techDebt >= GameBalance.severeDebtThreshold) {
        moralePenalty *= 2;
      }
    }
    return GameEffect(
      techDebtDelta: GameBalance.weeklyDebtDrift,
      moraleDelta: -moralePenalty,
    );
  }

  /// Oyunun bitip bitmediğine karar verir.
  ///
  /// Kazanma önce kontrol edilir: aynı hafta hem hedefe ulaşıp hem kasayı
  /// tüketmek oyuncunun aleyhine yorumlanmaz.
  static GameState evaluateOutcome(GameState state) {
    if (!state.isPlaying) return state;

    if (state.valuation >= GameState.winValuation) {
      return state.copyWith(status: GameStatus.won, clearLossReason: true);
    }
    if (state.budget <= 0) {
      return state.copyWith(
        status: GameStatus.lost,
        lossReason: LossReason.bankruptcy,
      );
    }
    if (state.techDebt >= GameState.maxPercent) {
      return state.copyWith(
        status: GameStatus.lost,
        lossReason: LossReason.serverMeltdown,
      );
    }
    if (state.teamMorale <= GameState.minPercent) {
      return state.copyWith(
        status: GameStatus.lost,
        lossReason: LossReason.massResignation,
      );
    }
    return state;
  }

  /// Verilen aksiyonun o anki durumda seçilebilir olup olmadığı.
  ///
  /// Bütçe yetmiyorsa aksiyon kilitlenir; UI bunu butonu devre dışı
  /// bırakmak için kullanır.
  static bool canAfford(GameState state, GameAction action, {Employee? hire}) {
    final cost = actionCost(action, hire: hire);
    if (cost <= 0) return true;
    return state.budget >= cost;
  }

  /// Aksiyonun tek seferlik nakit maliyeti ($, pozitif sayı).
  static int actionCost(GameAction action, {Employee? hire}) {
    if (action.kind == GameActionKind.hire) {
      return hire == null ? 0 : hiringCost(hire);
    }
    final budgetDelta = action.effect.budgetDelta;
    return budgetDelta < 0 ? -budgetDelta : 0;
  }

  /// Bir sprint'i (haftayı) simüle eder.
  ///
  /// [hire] yalnızca [GameActionKind.hire] aksiyonunda verilir ve zorunludur.
  /// [random] olay kartı çekilişi için kullanılır; test ederken sabit tohumlu
  /// bir [Random] verilir.
  ///
  /// Oyun bitmişse ya da karar bekleyen bir olay varsa [StateError] atar:
  /// bunlar çağıran tarafın hatasıdır, sessizce yutulmamalı.
  static SprintResult playSprint(
    GameState state,
    GameAction action, {
    Employee? hire,
    Random? random,
  }) {
    if (!state.isPlaying) {
      throw StateError('Oyun bitmiş durumda sprint oynatılamaz.');
    }
    if (state.hasPendingEvent) {
      throw StateError(
        'Karar bekleyen bir olay kartı var: ${state.pendingEventId}. '
        'Önce resolveEvent çağrılmalı.',
      );
    }
    if (action.kind == GameActionKind.hire && hire == null) {
      throw ArgumentError('İşe alım aksiyonu için bir aday verilmeli.');
    }

    final rng = random ?? Random();
    var next = state;

    // 1) Aksiyonun etkisi. İşe alımda aksiyonun kendi efekti boştur; onun
    //    yerine adayın tek seferlik maliyeti bütçeden düşer.
    final actionEffect = action.kind == GameActionKind.hire
        ? GameEffect(budgetDelta: -hiringCost(hire!))
        : action.effect;
    next = applyEffect(next, actionEffect);

    // 2) İşe alım: aday ekibe tekil bir kimlikle katılır.
    Employee? hiredEmployee;
    if (action.kind == GameActionKind.hire) {
      hiredEmployee = hire!.copyWith(id: '${hire.id}#w${state.week}');
      next = next.copyWith(team: [...next.team, hiredEmployee]);
    }

    // 3) Haftalık nakit akışı. Gelir ve maaşlar işe alım sonrası kadroya
    //    göre hesaplanır: yeni gelen ilk haftasından itibaren maaş yazar.
    final revenueCollected = collectableCash(next);
    next = next.copyWith(budget: next.budget + revenueCollected);

    // 4) Ekibin pasif borç/moral etkisi.
    final teamEffect = next.teamDebtMoraleEffect;
    next = applyEffect(next, teamEffect);

    // 5) Teknik borcun doğal artışı ve yüksek borç cezası.
    final debtEffect = debtPressure(next.techDebt);
    next = applyEffect(next, debtEffect);

    // 6) Hafta ilerler.
    next = next.copyWith(week: next.week + 1);

    // 7) Olay kartı çekilişi.
    final event = rollEvent(next, rng);
    if (event != null) {
      next = next.copyWith(pendingEventId: event.id);
    }

    // 8) Kazanma/kaybetme kontrolü.
    next = evaluateOutcome(next);

    return SprintResult(
      previousState: state,
      state: next,
      action: action,
      actionEffect: actionEffect,
      teamEffect: teamEffect,
      debtEffect: debtEffect,
      revenueCollected: revenueCollected,
      hiredEmployee: hiredEmployee,
      triggeredEvent: event,
    );
  }

  /// Bu hafta olay kartı çıkacak mı, çıkacaksa hangisi?
  ///
  /// Önce görülmemiş kartlar arasından seçer; havuz tükenmişse baştan
  /// başlar. İlk [GameBalance.eventGraceWeeks] hafta sakin geçer.
  static EventCard? rollEvent(GameState state, Random random) {
    if (state.week <= GameBalance.eventGraceWeeks) return null;

    final chance = eventChance(state.techDebt);
    if (random.nextDouble() >= chance) return null;

    final available = eventCardsAvailableAt(state.week);
    if (available.isEmpty) return null;

    final unseen = available
        .where((card) => !state.seenEventIds.contains(card.id))
        .toList(growable: false);
    final pool = unseen.isNotEmpty ? unseen : available;

    return pool[random.nextInt(pool.length)];
  }

  /// Verilen teknik borç seviyesinde olay kartı çıkma olasılığı (0.0 - 1.0).
  static double eventChance(int techDebt) {
    var chance = GameBalance.baseEventChance;
    if (techDebt >= GameBalance.debtRevenuePenaltyThreshold) {
      chance += GameBalance.highDebtEventBonus;
    }
    return min(GameBalance.maxEventChance, chance);
  }

  /// Karar bekleyen olay kartını oyuncunun seçimiyle kapatır.
  ///
  /// Seçim [card] içinde yoksa ya da durumda bekleyen olay bu kart değilse
  /// hata atar.
  static EventResolution resolveEvent(
    GameState state,
    EventCard card,
    EventChoice choice,
  ) {
    if (state.pendingEventId != card.id) {
      throw StateError(
        'Bekleyen olay "${state.pendingEventId}", "${card.id}" değil.',
      );
    }
    if (card.choiceById(choice.id) == null) {
      throw ArgumentError(
        '"${choice.id}" seçeneği "${card.id}" kartına ait değil.',
      );
    }

    var next = applyEffect(state, choice.effect);
    next = next.copyWith(
      clearPendingEvent: true,
      seenEventIds: state.seenEventIds.contains(card.id)
          ? state.seenEventIds
          : [...state.seenEventIds, card.id],
      resolvedCrises: choice.resolvesCrisis
          ? state.resolvedCrises + 1
          : state.resolvedCrises,
    );
    next = evaluateOutcome(next);

    return EventResolution(
      previousState: state,
      state: next,
      card: card,
      choice: choice,
    );
  }

  /// Oyuncunun kullanabileceği toplam ipucu hakkı.
  static int totalHintAllowance(GameState state) =>
      GameBalance.freeHintsPerGame +
      state.hiredConsultants * GameBalance.hintsPerConsultant;

  /// Kalan ipucu hakkı (0'ın altına düşmez).
  static int remainingHints(GameState state) =>
      max(0, totalHintAllowance(state) - state.usedFreeHints);

  /// Oyuncu şu an ipucu alabilir mi?
  static bool canUseHint(GameState state) => remainingHints(state) > 0;
}
