import 'package:material_ui/material_ui.dart';

import '../models/game_state.dart';

/// Oyunun renk paleti.
///
/// Estetik referansı bir IDE / terminal penceresi: koyu slate arka plan,
/// üstünde neon yeşil, kehribar ve kırmızı durum renkleri. Renkler
/// doğrudan widget'lara yazılmaz; hepsi buradan okunur.
abstract final class AppColors {
  // --- Arka plan katmanları ---------------------------------------------
  // Üç kademe: ekran zemini, kart, kart içi vurgu. Koyu temada derinlik
  // gölgeyle değil bu kademelerle anlatılır.

  /// Ekran zemini (editör arka planı).
  static const Color background = Color(0xFF0B0F14);

  /// Kart ve panel zemini.
  static const Color surface = Color(0xFF151B23);

  /// Kart içindeki vurgulu alan (girinti, seçili satır).
  static const Color surfaceAlt = Color(0xFF1E2630);

  /// Kenarlık ve ayırıcı çizgiler.
  static const Color border = Color(0xFF2A3340);

  // --- Metin -------------------------------------------------------------

  /// Ana metin.
  static const Color textPrimary = Color(0xFFE6EDF3);

  /// İkincil metin (açıklama, alt satır).
  static const Color textSecondary = Color(0xFF8B98A5);

  /// Soluk metin (etiket, yardımcı not).
  static const Color textMuted = Color(0xFF5A6673);

  /// Koyu zemin üstünde değil, neon zemin üstünde kullanılacak metin.
  static const Color textOnAccent = Color(0xFF07130D);

  // --- Durum renkleri ----------------------------------------------------

  /// Neon yeşil: iyi durum, başarı, birincil eylem.
  static const Color good = Color(0xFF3FE08F);

  /// Kehribar: uyarı, dikkat gerektiren durum.
  static const Color warning = Color(0xFFF5B942);

  /// Kırmızı: tehlike, kayıp, kritik durum.
  static const Color danger = Color(0xFFF4635B);

  /// Camgöbeği: bilgi, değerleme, nötr vurgu.
  static const Color info = Color(0xFF56B6C2);

  /// Mor: sözlük ve eğitici içerik vurgusu.
  static const Color accent = Color(0xFFC678DD);

  // --- Metriğe göre renk -------------------------------------------------

  /// Teknik borç seviyesinin rengi.
  ///
  /// Düşükken yeşil, kritik eşiği geçince kehribar, tehlikeliyken kırmızı.
  /// Oyuncu sayıyı okumadan da durumu görsün diye.
  static Color forTechDebt(int techDebt) {
    if (techDebt >= 80) return danger;
    if (techDebt >= GameState.highTechDebtThreshold) return warning;
    return good;
  }

  /// Ekip moralinin rengi (teknik borcun tersi yönde çalışır).
  static Color forMorale(int morale) {
    if (morale <= GameState.lowMoraleThreshold) return danger;
    if (morale <= 50) return warning;
    return good;
  }

  /// Bütçenin rengi.
  static Color forBudget(int budget) {
    if (budget <= 0) return danger;
    if (budget <= GameState.lowBudgetThreshold) return warning;
    return good;
  }

  /// Bir sayısal değişimin rengi: artış yeşil, azalış kırmızı.
  ///
  /// [inverted] teknik borç gibi "artması kötü" metrikler için kullanılır.
  static Color forDelta(int delta, {bool inverted = false}) {
    if (delta == 0) return textMuted;
    final positive = inverted ? delta < 0 : delta > 0;
    return positive ? good : danger;
  }
}
