/// Sayı biçimlendirme.
///
/// Biçim dile bağlı olduğu için (Türkçe binlik ayırıcı nokta, ondalık
/// virgül) bu dosya `l10n` katmanında duruyor. İkinci dil eklenirken
/// biçimlendiriciler de dile göre seçilebilir hâle getirilecek.
///
/// `intl` paketi bilinçli olarak eklenmedi: ihtiyaç duyulan tek şey binlik
/// ayırıcı ve işaretli gösterim; bunun için koca bir yerelleştirme paketi
/// taşımak gereksiz.
library;

/// Binlik ayırıcı ekler: `1234567` → `1.234.567`.
String groupDigits(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    // Sondan sayarak her üç basamakta bir nokta koy.
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return '${value < 0 ? '-' : ''}$buffer';
}

/// Para: `15000` → `15.000$`.
String formatMoney(int amount) => '${groupDigits(amount)}\$';

/// İşaretli para: `1200` → `+1.200$`, `-3000` → `-3.000$`, `0` → `0$`.
///
/// Artı işareti bilinçli olarak gösteriliyor: oyuncu bir aksiyonun
/// etkisine baktığında yönü okumadan görmeli.
String formatSignedMoney(int amount) {
  if (amount == 0) return '0\$';
  final sign = amount > 0 ? '+' : '';
  return '$sign${groupDigits(amount)}\$';
}

/// Yüzde: `45` → `%45`.
String formatPercent(int value) => '%$value';

/// İşaretli yüzde puanı: `15` → `+%15`, `-25` → `-%25`.
String formatSignedPercent(int value) {
  if (value == 0) return '%0';
  final sign = value > 0 ? '+' : '-';
  return '$sign%${value.abs()}';
}

/// Büyük parayı kısaltır: `1000000` → `1,0M$`, `250000` → `250B$`.
///
/// Dar alanlarda (ilerleme çubuğu etiketi, metrik rozeti) kullanılır.
/// Türkçe kısaltmalar: B = bin, M = milyon.
String formatCompactMoney(int amount) {
  final abs = amount.abs();
  final sign = amount < 0 ? '-' : '';

  if (abs >= 1000000) {
    final millions = abs / 1000000;
    // 1.000.000 → "1M", 1.250.000 → "1,3M"
    final text = millions >= 10
        ? millions.round().toString()
        : millions.toStringAsFixed(1).replaceAll('.', ',');
    return '$sign${text}M\$';
  }
  if (abs >= 1000) {
    final thousands = abs / 1000;
    final text = thousands >= 10
        ? thousands.round().toString()
        : thousands.toStringAsFixed(1).replaceAll('.', ',');
    return '$sign${text}B\$';
  }
  return '$sign$abs\$';
}

/// Tarihi gün/ay/yıl olarak yazar: `27.11.2026`.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
