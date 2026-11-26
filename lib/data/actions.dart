/// Haftalık aksiyonlar ve işe alım seçenekleri.
///
/// Sayısal değerler oyun dengesinin kalbidir; burada tek yerde durur ki
/// ayarlamak için kod aramak gerekmesin.
library;

import '../models/employee.dart';
import '../models/game_action.dart';
import '../models/game_effect.dart';

/// 1) Hızlı Feature Çıkar — yüksek gelir ve değerleme, ağır teknik borç.
const GameAction kShipFeatureAction = GameAction(
  id: 'action_ship_feature',
  name: 'Hızlı Feature Çıkar',
  description: 'Testi sonra yazarız. Müşteri mutlu, Zeynep mutsuz, kod tabanı biraz daha korkutucu.',
  kind: GameActionKind.shipFeature,
  iconId: 'rocket',
  effect: GameEffect(
    revenueDelta: 1200,
    valuationDelta: 28000,
    techDebtDelta: 15,
    moraleDelta: -6,
  ),
);

/// 2) Temiz Kod & Test Yaz — dengeli gelir, borç üretmez, morali hafif artırır.
const GameAction kCleanCodeAction = GameAction(
  id: 'action_clean_code',
  name: 'Temiz Kod & Test Yaz',
  description: 'Daha yavaş ama sağlam. Teknik borç büyümez, ekip nefes alır, kimse hafta sonu çalışmaz.',
  kind: GameActionKind.cleanCode,
  iconId: 'check',
  effect: GameEffect(revenueDelta: 500, valuationDelta: 12000, moraleDelta: 2),
);

/// 3) Refactoring Sprinti — borcu ciddi biçimde eritir, morali yükseltir.
const GameAction kRefactorAction = GameAction(
  id: 'action_refactor',
  name: 'Refactoring Sprinti',
  description: 'Bu hafta yeni bir şey çıkmıyor. Karşılığında kod tabanı yeniden insan tarafından okunabilir oluyor.',
  kind: GameActionKind.refactor,
  iconId: 'wrench',
  effect: GameEffect(valuationDelta: 4000, techDebtDelta: -25, moraleDelta: 8),
);

/// 4) Ekip Motivasyonu — bütçe harcar, morali ciddi yükseltir.
const GameAction kTeamMoraleAction = GameAction(
  id: 'action_team_morale',
  name: 'Ekip Motivasyonu',
  description: 'Ekip etkinliği, ekstra izin, düzgün ekipman. Para gider, insanlar kalır.',
  kind: GameActionKind.teamMorale,
  iconId: 'heart',
  effect: GameEffect(budgetDelta: -3000, moraleDelta: 20),
);

/// 5) İşe Alım — ekibe kalıcı bir çalışan ekler.
///
/// Bu aksiyonun kendi efekti boştur; gerçek etki seçilen çalışanın
/// [Employee.passiveEffect] değeridir. Seçim ekranı Aşama 3'te açılır.
const GameAction kHireAction = GameAction(
  id: 'action_hire',
  name: 'İşe Alım',
  description: 'Kadroyu büyüt. Her yeni kişi gelir getirir, maaş yazar ve kod tabanına kendi imzasını atar.',
  kind: GameActionKind.hire,
  iconId: 'person_add',
  effect: GameEffect.none,
);

/// Oyuncunun her hafta seçebileceği beş aksiyon.
const List<GameAction> kGameActions = [
  kShipFeatureAction,
  kCleanCodeAction,
  kRefactorAction,
  kTeamMoraleAction,
  kHireAction,
];

/// Kimlikten aksiyon bulur; bulunamazsa `null` döner.
GameAction? actionById(String id) {
  for (final action in kGameActions) {
    if (action.id == id) return action;
  }
  return null;
}

// --- İşe alım seçenekleri ----------------------------------------------
//
// Bunlar **şablon**dur: işe alındığında `copyWith(id: ...)` ile tekil bir
// kimlik alıp ekibe eklenir. İşe alımın tek seferlik maliyeti
// `hiringCost` ile, haftalık maliyeti `weeklySalary` ile ifade edilir.

/// Junior Developer — ucuz, hevesli, teknik borç üretir.
const Employee kJuniorHire = Employee(
  id: 'hire_junior',
  name: 'Junior Developer',
  title: 'Junior Developer',
  level: EmployeeLevel.junior,
  weeklySalary: 800,
  revenueContribution: 450,
  techDebtEffect: 3,
  moraleEffect: 1,
  iconId: 'junior',
);

/// Mid-level Developer — dengeli; borç üretmez, eritmez.
const Employee kMidHire = Employee(
  id: 'hire_mid',
  name: 'Mid-level Developer',
  title: 'Mid-level Developer',
  level: EmployeeLevel.mid,
  weeklySalary: 1500,
  revenueContribution: 1100,
  techDebtEffect: 0,
  moraleEffect: 0,
  iconId: 'mid',
);

/// Senior Developer — pahalı ama borcu eritir ve morali yükseltir.
const Employee kSeniorHire = Employee(
  id: 'hire_senior',
  name: 'Senior Developer',
  title: 'Senior Developer',
  level: EmployeeLevel.senior,
  weeklySalary: 2600,
  revenueContribution: 2000,
  techDebtEffect: -2,
  moraleEffect: 2,
  iconId: 'senior',
);

/// DevOps Engineer — teknik borcu en hızlı eriten rol.
const Employee kDevOpsHire = Employee(
  id: 'hire_devops',
  name: 'DevOps Engineer',
  title: 'DevOps Engineer',
  level: EmployeeLevel.devops,
  weeklySalary: 2300,
  revenueContribution: 1400,
  techDebtEffect: -4,
  moraleEffect: 1,
  iconId: 'devops',
);

/// İşe alım menüsünde gösterilen seçenekler (maaş sırasına göre).
const List<Employee> kHireOptions = [
  kJuniorHire,
  kMidHire,
  kSeniorHire,
  kDevOpsHire,
];

/// Bir çalışanı işe almanın tek seferlik maliyeti ($).
///
/// İlan, görüşme ve ekipman masrafı. Haftalık maaştan ayrıdır ve işe alım
/// anında bütçeden düşer.
int hiringCost(Employee candidate) => candidate.weeklySalary * 2;

/// Kimlikten işe alım şablonu bulur; bulunamazsa `null` döner.
Employee? hireOptionById(String id) {
  for (final option in kHireOptions) {
    if (option.id == id) return option;
  }
  return null;
}
