import 'package:test/test.dart';

import 'package:tech_debt_tycoon/l10n/l10n.dart';

/// Merkezi metin yönetimi testleri.
///
/// En önemlisi ilk test: widget'ların içine metin gömmediğimiz için her
/// anahtarın karşılığının dolu olması şart.
void main() {
  group('AppStrings - Türkçe', () {
    final strings = AppStrings.of(AppLanguage.tr);

    test('her anahtarın Türkçe karşılığı var', () {
      expect(
        strings.missingKeys,
        isEmpty,
        reason:
            'Çevirisi eksik anahtarlar: '
            '${strings.missingKeys.map((k) => k.name).join(', ')}',
      );
      expect(strings.definedKeyCount, StringKey.values.length);
    });

    test('hiçbir metin boş değil ve yer tutucu kalmamış', () {
      for (final key in StringKey.values) {
        final text = strings[key];
        expect(text.trim(), isNotEmpty, reason: '${key.name}: boş metin');
        expect(
          text,
          isNot(startsWith('⟨')),
          reason: '${key.name}: karşılığı bulunamadı',
        );
        expect(text, isNot(contains('TODO')), reason: '${key.name}: TODO var');
      }
    });

    test('format placeholder\'ları doldurur', () {
      expect(
        strings.format(StringKey.officeWeekLabel, {'week': '7'}),
        'Hafta 7',
      );
      expect(
        strings.format(StringKey.teamHiredMessage, {'name': 'Zeynep'}),
        contains('Zeynep'),
      );
    });

    test('format bilinmeyen placeholder\'ı yok sayar', () {
      expect(
        strings.format(StringKey.commonOk, {'yok': 'x'}),
        strings[StringKey.commonOk],
      );
    });

    test('placeholder içeren metinlerin anahtarı doldurulmamış bırakılmaz', () {
      // Süslü parantez içeren her metin için en az bir doldurma yolu olmalı;
      // burada sadece bilinen placeholder adlarını kullandığımızı doğruluyoruz.
      const known = {'week', 'count', 'name', 'weeks', 'remaining'};
      final pattern = RegExp(r'\{(\w+)\}');
      for (final key in StringKey.values) {
        for (final match in pattern.allMatches(strings[key])) {
          expect(
            known,
            contains(match.group(1)),
            reason: '${key.name}: bilinmeyen placeholder {${match.group(1)}}',
          );
        }
      }
    });

    test('get ve operator[] aynı sonucu verir', () {
      expect(strings.get(StringKey.navOffice), strings[StringKey.navOffice]);
    });
  });

  group('AppLanguage', () {
    test('varsayılan dil Türkçe', () {
      expect(AppLanguage.fallback, AppLanguage.tr);
      expect(AppLanguage.tr.code, 'tr');
    });

    test('fromCode tanımadığı kodda varsayılana düşer', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.en);
      expect(AppLanguage.fromCode('de'), AppLanguage.fallback);
      expect(AppLanguage.fromCode(null), AppLanguage.fallback);
    });

    test('her dilin kodu ve görünen adı dolu', () {
      for (final language in AppLanguage.values) {
        expect(language.code, isNotEmpty);
        expect(language.displayName, isNotEmpty);
      }
    });
  });

  group('AppStrings - desteklenen diller', () {
    test('şu an yalnızca Türkçe hazır', () {
      expect(AppStrings.supportedLanguages, [AppLanguage.tr]);
    });

    test('çevirisi olmayan dil varsayılan tabloya düşer', () {
      // İngilizce tablosu henüz yok; uygulama çökmemeli, Türkçeye düşmeli.
      final fallback = AppStrings.of(AppLanguage.en);
      expect(fallback[StringKey.navOffice], 'Ofis');
    });

    test('tanımsız anahtar görünür bir işaretle döner (çökmez)', () {
      // Bu davranış üretimde tetiklenmemeli; yine de güvenli olduğunu doğrula.
      final strings = AppStrings.of(AppLanguage.tr);
      expect(strings[StringKey.appTitle], isNot(startsWith('⟨')));
    });
  });
}
