/// Boşluk, köşe yarıçapı ve diğer ölçüler.
///
/// Tek elle oynanabilirlik için tasarım kuralları: dokunulabilir her şey
/// en az [minTouchTarget] yüksekliğinde, birincil eylemler ekranın alt
/// yarısında, kenar boşluğu [screenPadding].
abstract final class AppDimens {
  /// Ekran kenar boşluğu.
  static const double screenPadding = 16;

  /// Kart içi boşluk.
  static const double cardPadding = 14;

  /// Küçük boşluk.
  static const double gapXs = 4;

  /// Standart boşluk.
  static const double gapSm = 8;

  /// Orta boşluk.
  static const double gapMd = 12;

  /// Büyük boşluk (bölümler arası).
  static const double gapLg = 20;

  /// Çok büyük boşluk.
  static const double gapXl = 32;

  /// Kart köşe yarıçapı.
  static const double radiusCard = 12;

  /// Buton köşe yarıçapı.
  static const double radiusButton = 10;

  /// Bottom sheet üst köşe yarıçapı.
  static const double radiusSheet = 20;

  /// Erişilebilirlik için en küçük dokunma hedefi.
  static const double minTouchTarget = 48;

  /// İlerleme çubuğu yüksekliği.
  static const double progressHeight = 8;

  /// Metrik çubuğundaki ikon boyutu.
  static const double iconSm = 16;

  /// Standart ikon boyutu.
  static const double iconMd = 22;

  /// Büyük ikon (karakter avatarı, oyun sonu).
  static const double iconLg = 40;
}
