/// Oyun motorunun ayar düğmeleri.
///
/// `GameState` içindeki sabitler durumun *değişmezleridir* (başlangıç
/// değerleri, 0-100 sınırları, kazanma eşiği). Buradakiler ise motorun
/// haftalık simülasyonu nasıl yürüttüğünü belirleyen **denge** değerleri.
/// Oyunu zorlaştırmak/kolaylaştırmak için tek dokunulacak yer burasıdır.
library;

/// Haftalık simülasyon ve olay havuzu ayarları.
abstract final class GameBalance {
  // --- Teknik borcun doğal seyri ---------------------------------------

  /// Hiçbir şey yapılmasa bile teknik borcun haftalık doğal artışı
  /// (yüzde puanı). Kod eskir, bağımlılıklar sürüm atlar, dünya döner.
  static const int weeklyDebtDrift = 1;

  /// Teknik borcun geliri ısırmaya başladığı eşik (%).
  ///
  /// Bu eşiğin üstünde her yüzde puanı için gelir
  /// [revenuePenaltyPerDebtPoint] oranında azalır.
  static const int debtRevenuePenaltyThreshold = 60;

  /// Eşik üstündeki her teknik borç puanının gelirden kestiği oran.
  ///
  /// 0.01 → borç %80'de gelir %80'e, %100'de %60'a düşer.
  static const double revenuePenaltyPerDebtPoint = 0.01;

  /// Gelirin düşebileceği en alt çarpan. Borç ne kadar yüksek olsa da
  /// gelir tamamen sıfırlanmaz.
  static const double minRevenueMultiplier = 0.4;

  // --- Yüksek borcun morale etkisi -------------------------------------

  /// Teknik borç bu eşiğin üstündeyken ekip her hafta moral kaybeder.
  static const int debtMoralePenaltyThreshold = 60;

  /// [debtMoralePenaltyThreshold] üstünde haftalık moral kaybı (yüzde puanı).
  static const int debtMoralePenalty = 2;

  /// Teknik borç bu eşiğin üstündeyken moral kaybı ikiye katlanır.
  /// (Gece alarmları, sürekli hotfix, tükenmişlik.)
  static const int severeDebtThreshold = 80;

  // --- Olay kartları ----------------------------------------------------

  /// Bir haftanın sonunda olay kartı çıkma temel olasılığı (0.0 - 1.0).
  static const double baseEventChance = 0.55;

  /// Teknik borç [debtRevenuePenaltyThreshold] üstündeyken olasılığa
  /// eklenen pay. Borçlu kod daha çok sürpriz üretir.
  static const double highDebtEventBonus = 0.25;

  /// Olay kartı olasılığının üst sınırı.
  static const double maxEventChance = 0.9;

  /// İlk kaç hafta olay kartı çıkmaz?
  ///
  /// Oyuncu önce mekaniği öğrensin diye birinci hafta sakin geçer.
  static const int eventGraceWeeks = 1;

  // --- İpuçları ---------------------------------------------------------

  /// Oyun başına ücretsiz ipucu hakkı. Sonrasında reklam izlenip danışman
  /// tutulması gerekir.
  static const int freeHintsPerGame = 3;

  /// Reklam izleyerek tutulan her danışmanın verdiği ipucu hakkı.
  static const int hintsPerConsultant = 1;

  // --- İpucu eşikleri ---------------------------------------------------

  /// Teknik borç bu seviyede kritik ipucu verilir.
  static const int hintCriticalDebt = 85;

  /// Moral bu seviyede kritik ipucu verilir.
  static const int hintCriticalMorale = 15;

  /// Bütçe bu kaç haftalık maaşın altına düşerse kritik ipucu verilir.
  static const int hintCriticalSalaryWeeks = 2;

  /// Ekip boşken işe alım önermek için gereken en az bütçe ($).
  static const int hintHireBudgetFloor = 8000;

  /// Bu haftadan sonra ilerleme yavaşsa büyüme ipucu verilir.
  static const int hintSlowGrowthAfterWeek = 10;

  /// "Yavaş ilerleme" sayılan unicorn ilerleme oranı (0.0 - 1.0).
  static const double hintSlowGrowthProgress = 0.25;

  // --- Sahte reklam -----------------------------------------------------

  /// Sahte reklamın "oynama" süresi.
  static const Duration fakeAdDuration = Duration(seconds: 3);

  /// Sahte reklamın yüklenememe olasılığı (0.0 - 1.0).
  ///
  /// Gerçek reklam ağları da her zaman envanter bulamaz; UI'ın hata yolunu
  /// da test edebilmesi için bilinçli olarak sıfır değil.
  static const double fakeAdFailureChance = 0.1;
}
