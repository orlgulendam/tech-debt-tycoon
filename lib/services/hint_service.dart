import '../data/actions.dart';
import '../data/game_balance.dart';
import '../l10n/app_strings.dart';
import '../l10n/string_keys.dart';
import '../models/models.dart';
import 'game_engine.dart';

/// Akıllı ipucu algoritması.
///
/// Oyuncuya her seferinde tek bir net tavsiye verir. Mantık basit ve
/// öngörülebilir: kurallar aciliyet sırasına göre denenir, **ilk uyan kural
/// kazanır**. Böylece oyuncu "bütçe de düşük, moral de düşük" durumunda
/// bulanık bir liste değil, en kritik olan tek şeyi görür.
///
/// Metinleri [AppStrings] üzerinden okur; kurallarda düz metin yoktur.
class HintService {
  const HintService(this._strings);

  final AppStrings _strings;

  /// Verilen durum için en acil tavsiyeyi döner.
  ///
  /// Hiçbir kritik durum yoksa bilgilendirici bir ipucu döner; `null`
  /// dönmez, böylece UI'ın "ipucu yok" hâlini ele alması gerekmez.
  HintResult forState(GameState state) {
    for (final rule in _rules) {
      final hint = rule(state);
      if (hint != null) return hint;
    }
    // Buraya düşmemeli: son kural her zaman bir sonuç üretir.
    return _build(
      adviceKey: StringKey.hintAllGoodAdvice,
      reasonKey: StringKey.hintAllGoodReason,
      metric: HintMetric.valuation,
      priority: 0,
    );
  }

  /// Kurallar, en acilden en sakine doğru.
  List<HintResult? Function(GameState)> get _rules => [
    _criticalDebt,
    _criticalMorale,
    _criticalBudget,
    _highDebt,
    _lowMorale,
    _lowBudget,
    _negativeCashFlow,
    _emptyTeam,
    _slowGrowth,
    _allGood,
  ];

  // --- Aciliyet 3: kritik ------------------------------------------------

  HintResult? _criticalDebt(GameState state) {
    if (state.techDebt < GameBalance.hintCriticalDebt) return null;
    return _build(
      adviceKey: StringKey.hintDebtCriticalAdvice,
      reasonKey: StringKey.hintDebtCriticalReason,
      metric: HintMetric.techDebt,
      priority: 3,
      actionId: kRefactorAction.id,
      values: {'value': '${state.techDebt}'},
    );
  }

  HintResult? _criticalMorale(GameState state) {
    if (state.teamMorale > GameBalance.hintCriticalMorale) return null;
    return _build(
      adviceKey: StringKey.hintMoraleCriticalAdvice,
      reasonKey: StringKey.hintMoraleCriticalReason,
      metric: HintMetric.teamMorale,
      priority: 3,
      actionId: kTeamMoraleAction.id,
      values: {'value': '${state.teamMorale}'},
    );
  }

  HintResult? _criticalBudget(GameState state) {
    final runway = state.totalSalaries * GameBalance.hintCriticalSalaryWeeks;
    // Kadro yoksa maaş yükü de yok; bu kural yalnızca bordro varken anlamlı.
    if (runway <= 0 || state.budget > runway) return null;
    return _build(
      adviceKey: StringKey.hintBudgetCriticalAdvice,
      reasonKey: StringKey.hintBudgetCriticalReason,
      metric: HintMetric.budget,
      priority: 3,
      actionId: kShipFeatureAction.id,
      values: {'value': '${state.budget}'},
    );
  }

  // --- Aciliyet 2: önemli ------------------------------------------------

  HintResult? _highDebt(GameState state) {
    if (!state.isTechDebtCritical) return null;
    return _build(
      adviceKey: StringKey.hintDebtHighAdvice,
      reasonKey: StringKey.hintDebtHighReason,
      metric: HintMetric.techDebt,
      priority: 2,
      actionId: kRefactorAction.id,
      values: {'value': '${state.techDebt}'},
    );
  }

  HintResult? _lowMorale(GameState state) {
    if (!state.isMoraleCritical) return null;
    return _build(
      adviceKey: StringKey.hintMoraleLowAdvice,
      reasonKey: StringKey.hintMoraleLowReason,
      metric: HintMetric.teamMorale,
      priority: 2,
      actionId: kTeamMoraleAction.id,
      values: {'value': '${state.teamMorale}'},
    );
  }

  HintResult? _lowBudget(GameState state) {
    if (!state.isBudgetCritical) return null;
    return _build(
      adviceKey: StringKey.hintBudgetLowAdvice,
      reasonKey: StringKey.hintBudgetLowReason,
      metric: HintMetric.budget,
      priority: 2,
      actionId: kShipFeatureAction.id,
      values: {'value': '${state.budget}'},
    );
  }

  // --- Aciliyet 1: normal ------------------------------------------------

  HintResult? _negativeCashFlow(GameState state) {
    final cash = GameEngine.collectableCash(state);
    if (cash >= 0) return null;
    return _build(
      adviceKey: StringKey.hintCashFlowNegativeAdvice,
      reasonKey: StringKey.hintCashFlowNegativeReason,
      metric: HintMetric.revenue,
      priority: 1,
      actionId: kShipFeatureAction.id,
      values: {'value': '${-cash}'},
    );
  }

  HintResult? _emptyTeam(GameState state) {
    if (state.hasTeam) return null;
    if (state.budget < GameBalance.hintHireBudgetFloor) return null;
    return _build(
      adviceKey: StringKey.hintHireTeamAdvice,
      reasonKey: StringKey.hintHireTeamReason,
      metric: HintMetric.team,
      priority: 1,
      actionId: kHireAction.id,
      values: {'value': '${state.budget}'},
    );
  }

  HintResult? _slowGrowth(GameState state) {
    if (state.week <= GameBalance.hintSlowGrowthAfterWeek) return null;
    if (state.unicornProgress >= GameBalance.hintSlowGrowthProgress) {
      return null;
    }
    return _build(
      adviceKey: StringKey.hintSlowGrowthAdvice,
      reasonKey: StringKey.hintSlowGrowthReason,
      metric: HintMetric.valuation,
      priority: 1,
      actionId: kShipFeatureAction.id,
      values: {
        'week': '${state.week}',
        'value': '${(state.unicornProgress * 100).round()}',
      },
    );
  }

  // --- Aciliyet 0: her şey yolunda --------------------------------------

  HintResult _allGood(GameState state) => _build(
    adviceKey: StringKey.hintAllGoodAdvice,
    reasonKey: StringKey.hintAllGoodReason,
    metric: HintMetric.valuation,
    priority: 0,
  );

  // --- Yardımcı ----------------------------------------------------------

  HintResult _build({
    required StringKey adviceKey,
    required StringKey reasonKey,
    required HintMetric metric,
    required int priority,
    String? actionId,
    Map<String, String> values = const {},
  }) => HintResult(
    advice: values.isEmpty
        ? _strings[adviceKey]
        : _strings.format(adviceKey, values),
    reasoning: values.isEmpty
        ? _strings[reasonKey]
        : _strings.format(reasonKey, values),
    metric: metric,
    priority: priority,
    suggestedActionId: actionId,
  );
}
