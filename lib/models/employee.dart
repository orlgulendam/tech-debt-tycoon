import 'game_effect.dart';
import 'model_utils.dart';

/// Çalışanın kıdem/rol seviyesi.
///
/// Her seviyenin maaş, gelir katkısı ve pasif teknik borç etkisi profili
/// farklıdır; sayısal değerler `lib/data/actions.dart` içindeki işe alım
/// seçeneklerinde tanımlıdır.
enum EmployeeLevel {
  /// Ucuz ve hevesli, ama production'da teknik borç üretmeye meyilli.
  junior,

  /// Dengeli: ne borç üretir ne de azaltır.
  mid,

  /// Pahalı ama borcu aktif olarak azaltır ve morali yükseltir.
  senior,

  /// Altyapı/CI-CD odaklı; teknik borcu en hızlı eriten rol.
  devops,
}

/// Ekipteki bir çalışan.
///
/// Hem işe alım menüsündeki **şablonlar** hem de ekipteki **gerçek kişiler**
/// bu sınıfla temsil edilir. İşe alındığında şablon `copyWith` ile tekil bir
/// [id] alır.
class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.title,
    required this.level,
    required this.weeklySalary,
    required this.revenueContribution,
    required this.techDebtEffect,
    required this.moraleEffect,
    required this.iconId,
  });

  /// Tekil kimlik. Şablonlarda rol adı (ör. `hire_senior`), ekipte ise
  /// işe alım sırasında üretilen tekil değer (ör. `hire_senior#3`).
  final String id;

  /// Çalışanın adı (kullanıcıya görünür).
  final String name;

  /// Unvan (kullanıcıya görünür, ör. "Senior Backend Developer").
  final String title;

  /// Kıdem/rol seviyesi.
  final EmployeeLevel level;

  /// Haftalık maaş ($). Her hafta bütçeden düşer.
  final int weeklySalary;

  /// Haftalık gelire katkısı ($/hafta).
  final int revenueContribution;

  /// Pasif teknik borç etkisi (yüzde puanı/hafta).
  /// Pozitif değer borç **üretir**, negatif değer borcu **eritir**.
  final int techDebtEffect;

  /// Pasif moral etkisi (yüzde puanı/hafta).
  final int moraleEffect;

  /// Avatar/ikon tanımlayıcısı. Aşama 3'te tema katmanı bunu bir ikona eşler.
  final String iconId;

  /// Çalışanın her hafta otomatik uygulanan pasif etkisi.
  ///
  /// Maaş bütçeden gider, gelir katkısı haftalık gelire eklenir.
  GameEffect get passiveEffect => GameEffect(
    budgetDelta: -weeklySalary,
    revenueDelta: revenueContribution,
    techDebtDelta: techDebtEffect,
    moraleDelta: moraleEffect,
  );

  /// Çalışanın haftalık net katkısı ($). Negatifse şirkete yük bindiriyor.
  int get netWeeklyValue => revenueContribution - weeklySalary;

  Employee copyWith({
    String? id,
    String? name,
    String? title,
    EmployeeLevel? level,
    int? weeklySalary,
    int? revenueContribution,
    int? techDebtEffect,
    int? moraleEffect,
    String? iconId,
  }) => Employee(
    id: id ?? this.id,
    name: name ?? this.name,
    title: title ?? this.title,
    level: level ?? this.level,
    weeklySalary: weeklySalary ?? this.weeklySalary,
    revenueContribution: revenueContribution ?? this.revenueContribution,
    techDebtEffect: techDebtEffect ?? this.techDebtEffect,
    moraleEffect: moraleEffect ?? this.moraleEffect,
    iconId: iconId ?? this.iconId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'level': level.name,
    'weeklySalary': weeklySalary,
    'revenueContribution': revenueContribution,
    'techDebtEffect': techDebtEffect,
    'moraleEffect': moraleEffect,
    'iconId': iconId,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: readString(json['id']),
    name: readString(json['name']),
    title: readString(json['title']),
    level: enumFromName(
      EmployeeLevel.values,
      json['level'],
      fallback: EmployeeLevel.mid,
    ),
    weeklySalary: readInt(json['weeklySalary']),
    revenueContribution: readInt(json['revenueContribution']),
    techDebtEffect: readInt(json['techDebtEffect']),
    moraleEffect: readInt(json['moraleEffect']),
    iconId: readString(json['iconId']),
  );

  @override
  bool operator ==(Object other) =>
      other is Employee &&
      other.id == id &&
      other.name == name &&
      other.title == title &&
      other.level == level &&
      other.weeklySalary == weeklySalary &&
      other.revenueContribution == revenueContribution &&
      other.techDebtEffect == techDebtEffect &&
      other.moraleEffect == moraleEffect &&
      other.iconId == iconId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    title,
    level,
    weeklySalary,
    revenueContribution,
    techDebtEffect,
    moraleEffect,
    iconId,
  );

  @override
  String toString() => 'Employee($id, $name, ${level.name})';
}
