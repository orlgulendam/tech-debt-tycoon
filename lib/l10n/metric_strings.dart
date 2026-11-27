import '../models/employee.dart';
import '../models/glossary_term.dart';
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

/// [EmployeeLevel] değerlerini metin anahtarlarına eşler.
extension EmployeeLevelStrings on EmployeeLevel {
  /// Seviyenin kullanıcıya gösterilecek adının anahtarı.
  StringKey get labelKey => switch (this) {
    EmployeeLevel.junior => StringKey.levelJunior,
    EmployeeLevel.mid => StringKey.levelMid,
    EmployeeLevel.senior => StringKey.levelSenior,
    EmployeeLevel.devops => StringKey.levelDevops,
  };
}

/// [GlossaryCategory] değerlerini metin anahtarlarına eşler.
extension GlossaryCategoryStrings on GlossaryCategory {
  /// Kategorinin kullanıcıya gösterilecek adının anahtarı.
  StringKey get labelKey => switch (this) {
    GlossaryCategory.engineering => StringKey.glossaryCategoryEngineering,
    GlossaryCategory.process => StringKey.glossaryCategoryProcess,
    GlossaryCategory.infrastructure => StringKey.glossaryCategoryInfrastructure,
    GlossaryCategory.quality => StringKey.glossaryCategoryQuality,
    GlossaryCategory.business => StringKey.glossaryCategoryBusiness,
  };
}
