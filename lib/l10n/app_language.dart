/// Uygulamanın desteklediği diller.
///
/// Aşama 1'de yalnızca [tr] doludur. [en] bilinçli olarak şimdiden tanımlı:
/// ikinci dil eklenirken sadece `lib/l10n/strings_en.dart` dosyası yazılıp
/// [AppStrings] kayıt tablosuna eklenecek, UI kodunda hiçbir değişiklik
/// gerekmeyecek.
enum AppLanguage {
  /// Türkçe (varsayılan).
  tr('tr', 'Türkçe'),

  /// İngilizce (henüz çevirisi yok).
  en('en', 'English');

  const AppLanguage(this.code, this.displayName);

  /// ISO 639-1 dil kodu. Flutter `Locale` nesnesine bu kodla çevrilir.
  final String code;

  /// Dil seçiminde gösterilecek ad.
  final String displayName;

  /// Uygulamanın varsayılan dili.
  static const AppLanguage fallback = AppLanguage.tr;

  /// Dil kodundan [AppLanguage] bulur; tanımadığı kodda [fallback] döner.
  static AppLanguage fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return fallback;
  }
}
