import '../models/hint_result.dart';
import 'string_keys.dart';

/// [HintMetric] değerlerini metin anahtarlarına eşler.
///
/// Motor ve ipucu servisi enum döner; hangi metnin gösterileceğine karar
/// vermek sunum katmanının işi. Bu eşleme tek yerde dursun diye burada.
extension HintMetricStrings on HintMetric {
  /// Metriğin kullanıcıya gösterilecek adının anahtarı.
  StringKey get labelKey => switch (this) {
    HintMetric.budget => StringKey.metricBudget,
    HintMetric.revenue => StringKey.metricWeeklyRevenue,
    HintMetric.valuation => StringKey.metricValuation,
    HintMetric.techDebt => StringKey.metricTechDebt,
    HintMetric.teamMorale => StringKey.metricTeamMorale,
    HintMetric.team => StringKey.metricTeamSize,
  };
}
