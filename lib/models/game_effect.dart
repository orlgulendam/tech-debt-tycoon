import 'model_utils.dart';

/// Bir aksiyonun ya da olay seçeneğinin oyun kaynaklarına etkisi.
///
/// Oyundaki **bütün** sayısal etkiler bu tek değer nesnesinden geçer:
/// haftalık aksiyonlar, olay kartı seçenekleri ve çalışanların pasif etkileri.
/// Böylece Aşama 2'deki motor tek bir `applyEffect` yolu ile çalışır.
///
/// Para birimi alanları tam dolar ($) cinsinden `int`'tir; yüzde alanları
/// **yüzde puanı** farkıdır (ör. `techDebtDelta: 15` → teknik borç +%15).
class GameEffect {
  const GameEffect({
    this.budgetDelta = 0,
    this.revenueDelta = 0,
    this.valuationDelta = 0,
    this.techDebtDelta = 0,
    this.moraleDelta = 0,
  });

  /// Etkisi olmayan nötr efekt.
  static const GameEffect none = GameEffect();

  /// Bütçeye eklenen/çıkarılan tutar ($). Negatif değer harcamadır.
  final int budgetDelta;

  /// Haftalık gelire eklenen/çıkarılan tutar ($/hafta). Kalıcı etkidir.
  final int revenueDelta;

  /// Şirket değerlemesine eklenen/çıkarılan tutar ($).
  final int valuationDelta;

  /// Teknik borca eklenen/çıkarılan yüzde puanı (0-100 aralığına sıkıştırılır).
  final int techDebtDelta;

  /// Ekip moraline eklenen/çıkarılan yüzde puanı (0-100 aralığına sıkıştırılır).
  final int moraleDelta;

  /// Hiçbir kaynağı değiştirmeyen efekt mi?
  bool get isEmpty =>
      budgetDelta == 0 &&
      revenueDelta == 0 &&
      valuationDelta == 0 &&
      techDebtDelta == 0 &&
      moraleDelta == 0;

  /// İki efekti toplar. Çalışanların pasif etkilerini tek efekte indirmek için.
  GameEffect operator +(GameEffect other) => GameEffect(
    budgetDelta: budgetDelta + other.budgetDelta,
    revenueDelta: revenueDelta + other.revenueDelta,
    valuationDelta: valuationDelta + other.valuationDelta,
    techDebtDelta: techDebtDelta + other.techDebtDelta,
    moraleDelta: moraleDelta + other.moraleDelta,
  );

  /// Efektin bütün alanlarını [factor] ile ölçekler.
  ///
  /// Teknik borcun "faizi" gibi mekanikler için (ör. borç yüksekken olumsuz
  /// etkileri büyütmek) kullanılabilir.
  GameEffect scaled(double factor) => GameEffect(
    budgetDelta: (budgetDelta * factor).round(),
    revenueDelta: (revenueDelta * factor).round(),
    valuationDelta: (valuationDelta * factor).round(),
    techDebtDelta: (techDebtDelta * factor).round(),
    moraleDelta: (moraleDelta * factor).round(),
  );

  GameEffect copyWith({
    int? budgetDelta,
    int? revenueDelta,
    int? valuationDelta,
    int? techDebtDelta,
    int? moraleDelta,
  }) => GameEffect(
    budgetDelta: budgetDelta ?? this.budgetDelta,
    revenueDelta: revenueDelta ?? this.revenueDelta,
    valuationDelta: valuationDelta ?? this.valuationDelta,
    techDebtDelta: techDebtDelta ?? this.techDebtDelta,
    moraleDelta: moraleDelta ?? this.moraleDelta,
  );

  Map<String, dynamic> toJson() => {
    'budgetDelta': budgetDelta,
    'revenueDelta': revenueDelta,
    'valuationDelta': valuationDelta,
    'techDebtDelta': techDebtDelta,
    'moraleDelta': moraleDelta,
  };

  factory GameEffect.fromJson(Map<String, dynamic> json) => GameEffect(
    budgetDelta: readInt(json['budgetDelta']),
    revenueDelta: readInt(json['revenueDelta']),
    valuationDelta: readInt(json['valuationDelta']),
    techDebtDelta: readInt(json['techDebtDelta']),
    moraleDelta: readInt(json['moraleDelta']),
  );

  @override
  bool operator ==(Object other) =>
      other is GameEffect &&
      other.budgetDelta == budgetDelta &&
      other.revenueDelta == revenueDelta &&
      other.valuationDelta == valuationDelta &&
      other.techDebtDelta == techDebtDelta &&
      other.moraleDelta == moraleDelta;

  @override
  int get hashCode => Object.hash(
    budgetDelta,
    revenueDelta,
    valuationDelta,
    techDebtDelta,
    moraleDelta,
  );

  @override
  String toString() =>
      'GameEffect(bütçe: $budgetDelta, gelir: $revenueDelta, '
      'değerleme: $valuationDelta, borç: $techDebtDelta, moral: $moraleDelta)';
}
