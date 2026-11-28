import 'package:material_ui/material_ui.dart';

import '../models/glossary_term.dart';
import '../models/hint_result.dart';

/// Veri katmanındaki ikon kimliklerini gerçek ikonlara eşler.
///
/// Modeller `iconId: 'rocket'` gibi dizge taşır, `IconData` taşımaz:
/// böylece veri katmanı Flutter'a bağımlı olmuyor ve saf Dart kalıyor.
/// Eşleme tek yerde, burada.
abstract final class AppIcons {
  /// Aksiyon, karakter ve çalışan ikonları.
  ///
  /// Tanınmayan kimlikte nötr bir ikon döner; eksik eşleme uygulamayı
  /// çökertmez.
  static IconData forId(String iconId) => switch (iconId) {
    // Aksiyonlar
    'rocket' => Icons.rocket_launch_outlined,
    'check' => Icons.verified_outlined,
    'wrench' => Icons.build_outlined,
    'heart' => Icons.favorite_outline,
    'person_add' => Icons.person_add_alt_outlined,
    // Karakterler
    'ceo' => Icons.trending_up,
    'architect' => Icons.architecture_outlined,
    'junior' => Icons.school_outlined,
    'devops' => Icons.dns_outlined,
    'mid' => Icons.code,
    'senior' => Icons.workspace_premium_outlined,
    _ => Icons.circle_outlined,
  };

  /// Sözlük kategorisi ikonu.
  static IconData forGlossaryCategory(GlossaryCategory category) =>
      switch (category) {
        GlossaryCategory.engineering => Icons.code,
        GlossaryCategory.process => Icons.loop,
        GlossaryCategory.infrastructure => Icons.dns_outlined,
        GlossaryCategory.quality => Icons.bug_report_outlined,
        GlossaryCategory.business => Icons.insights_outlined,
      };

  /// İpucunun işaret ettiği metriğin ikonu.
  static IconData forHintMetric(HintMetric metric) => switch (metric) {
    HintMetric.budget => budget,
    HintMetric.revenue => revenue,
    HintMetric.valuation => valuation,
    HintMetric.techDebt => techDebt,
    HintMetric.teamMorale => morale,
    HintMetric.team => team,
  };

  // --- Metrik ikonları ---------------------------------------------------

  /// Bütçe.
  static const IconData budget = Icons.account_balance_wallet_outlined;

  /// Haftalık gelir.
  static const IconData revenue = Icons.payments_outlined;

  /// Şirket değerlemesi.
  static const IconData valuation = Icons.show_chart;

  /// Teknik borç.
  static const IconData techDebt = Icons.warning_amber_outlined;

  /// Ekip morali.
  static const IconData morale = Icons.favorite_outline;

  /// Ekip büyüklüğü.
  static const IconData team = Icons.groups_outlined;

  /// Hafta sayacı.
  static const IconData week = Icons.calendar_today_outlined;

  // --- Navigasyon --------------------------------------------------------

  /// Ofis sekmesi.
  static const IconData navOffice = Icons.terminal;

  /// Ekip sekmesi.
  static const IconData navTeam = Icons.groups_outlined;

  /// Sözlük sekmesi.
  static const IconData navGlossary = Icons.menu_book_outlined;

  /// Log & Kariyer sekmesi.
  static const IconData navLog = Icons.history;

  // --- Diğer -------------------------------------------------------------

  /// Danışman / ipucu.
  static const IconData hint = Icons.lightbulb_outline;

  /// Unicorn (kazanma).
  static const IconData unicorn = Icons.auto_awesome;

  /// Reklam.
  static const IconData ad = Icons.play_circle_outline;

  /// Yeni oyun.
  static const IconData newGame = Icons.restart_alt;
}
