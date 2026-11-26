/// Modeller arasında paylaşılan küçük yardımcılar.
///
/// Bu dosya bilinçli olarak Flutter'a bağımlı değildir; böylece bütün
/// `lib/models` katmanı saf Dart kalır ve `dart test` ile Flutter motoru
/// başlatılmadan test edilebilir.
library;

/// İki listeyi eleman eleman karşılaştırır.
///
/// `package:flutter/foundation.dart` içindeki `listEquals` ile aynı işi yapar
/// ama Flutter bağımlılığı getirmez.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Liste içeriğine göre kararlı bir hash üretir.
int listHash<T>(List<T> items) => Object.hashAll(items);

/// Bir değeri [min] ve [max] arasına sıkıştırır.
int clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// JSON'dan gelen bir alanı güvenli biçimde `int`'e çevirir.
///
/// Kayıt dosyası eski bir sürümden geliyorsa alan eksik ya da `double` olabilir;
/// bu durumda [fallback] döner.
int readInt(Object? raw, {int fallback = 0}) {
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  if (raw is String) return int.tryParse(raw) ?? fallback;
  return fallback;
}

/// JSON'dan gelen bir alanı güvenli biçimde `String`'e çevirir.
String readString(Object? raw, {String fallback = ''}) {
  if (raw is String) return raw;
  return raw?.toString() ?? fallback;
}

/// Adı verilen enum değerini bulur, bulamazsa [fallback] döner.
///
/// Kayıt dosyalarında enum'ları indeks değil **ad** olarak tutuyoruz; böylece
/// ileride enum'a yeni bir değer eklenip sıralama değişse de eski kayıtlar
/// bozulmaz.
T enumFromName<T extends Enum>(
  List<T> values,
  Object? raw, {
  required T fallback,
}) {
  if (raw is String) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
  }
  return fallback;
}
