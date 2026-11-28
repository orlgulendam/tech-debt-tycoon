import 'package:material_ui/material_ui.dart';

/// Animasyon süreleri ve eğrileri.
///
/// Tek yerde durması şart: oyunun "hissi" büyük ölçüde bu sayılardan
/// geliyor ve ekrandan ekrana değişirse arayüz derme çatma görünüyor.
///
/// Genel kural: geri bildirim hızlı (dokunma tepkisi), değer değişimi
/// görülebilecek kadar yavaş (sayaçlar), kutlama uzun.
abstract final class AppMotion {
  /// Dokunma tepkisi (buton basılması, kart küçülmesi).
  static const Duration fast = Duration(milliseconds: 120);

  /// Standart geçiş (renk, opaklık, yerleşim).
  static const Duration normal = Duration(milliseconds: 280);

  /// Belirgin geçiş (panel açılışı).
  static const Duration slow = Duration(milliseconds: 500);

  /// Sayaçların yeni değere koşma süresi.
  ///
  /// Oyuncu değişimi fark etsin diye bilinçli olarak uzun; daha kısası
  /// "zaten değişmişti" gibi duruyor.
  static const Duration counter = Duration(milliseconds: 750);

  /// Kritik metriklerin nabız atışı.
  static const Duration pulse = Duration(milliseconds: 1100);

  /// Kazanma kutlaması.
  static const Duration celebrate = Duration(milliseconds: 1600);

  /// Daktilo efektinde harf başına süre.
  static const Duration typewriterPerChar = Duration(milliseconds: 16);

  /// Sıralı beliren satırlar arasındaki gecikme.
  static const Duration staggerStep = Duration(milliseconds: 80);

  /// Giriş animasyonları: hızlı başlayıp yumuşak biten.
  static const Curve enter = Curves.easeOutCubic;

  /// Vurgulu giriş (hafif zıplama).
  static const Curve emphasis = Curves.easeOutBack;

  /// Çıkış animasyonları.
  static const Curve exit = Curves.easeInCubic;
}
