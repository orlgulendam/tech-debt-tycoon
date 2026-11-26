import 'app_language.dart';
import 'string_keys.dart';
import 'strings_tr.dart';

/// Kullanıcıya görünen metinlere tek erişim noktası.
///
/// Kullanım:
/// ```dart
/// final strings = AppStrings.of(AppLanguage.tr);
/// Text(strings[StringKey.navOffice]);
/// Text(strings.format(StringKey.officeWeekLabel, {'week': '3'}));
/// ```
///
/// Aşama 2'de bir Riverpod provider mevcut dili tutacak ve bu nesneyi
/// widget ağacına verecek; widget'lar yine sadece [StringKey] kullanacak.
class AppStrings {
  const AppStrings._(this.language, this._values);

  /// Dil tablolarının kayıt defteri.
  ///
  /// Yeni dil eklemek için: `strings_en.dart` yazılır ve buraya bir satır
  /// eklenir. UI kodunda değişiklik gerekmez.
  static const Map<AppLanguage, Map<StringKey, String>> _registry = {
    AppLanguage.tr: kStringsTr,
  };

  /// Verilen dil için metin tablosunu döner.
  ///
  /// İstenen dilin tablosu henüz yoksa varsayılan dile ([AppLanguage.fallback])
  /// düşer; böylece yarım çeviri uygulamayı çökertmez.
  factory AppStrings.of(AppLanguage language) {
    final values = _registry[language] ?? _registry[AppLanguage.fallback]!;
    return AppStrings._(language, values);
  }

  /// Çevirisi hazır olan diller.
  static List<AppLanguage> get supportedLanguages =>
      _registry.keys.toList(growable: false);

  /// Bu tablonun dili.
  final AppLanguage language;

  final Map<StringKey, String> _values;

  /// Anahtara karşılık gelen metin.
  ///
  /// Çeviri eksikse anahtarın adını köşeli parantez içinde döner (ör.
  /// `⟨navOffice⟩`); böylece eksik metin ekranda hemen fark edilir, uygulama
  /// çökmez. `test/l10n_test.dart` bu durumun hiç oluşmadığını doğrular.
  String operator [](StringKey key) => _values[key] ?? '⟨${key.name}⟩';

  /// [operator []] ile aynı; zincirleme çağrılarda okunabilir olsun diye.
  String get(StringKey key) => this[key];

  /// Placeholder'ları doldurur: `'Hafta {week}'` + `{'week': '3'}` → `'Hafta 3'`.
  ///
  /// Metinde bulunmayan bir placeholder verilmesi hata değildir; sessizce
  /// yok sayılır.
  String format(StringKey key, Map<String, String> values) {
    var text = this[key];
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  /// Bu dilde tanımlı anahtar sayısı (testler ve tanılama için).
  int get definedKeyCount => _values.length;

  /// Çevirisi eksik olan anahtarlar (testler ve tanılama için).
  List<StringKey> get missingKeys => StringKey.values
      .where((key) => !_values.containsKey(key))
      .toList(growable: false);
}
