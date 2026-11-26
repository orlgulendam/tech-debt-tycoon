/// Bütün statik oyun içeriğini tek noktadan dışa açar.
///
/// **Çoklu dil notu:** Karakter replikleri, olay kartları ve sözlük metinleri
/// hacimli olduğu için `lib/l10n/` içindeki anahtar tablosuna değil bu
/// dosyaların içine yazıldı. İkinci dil eklenirken izlenecek yol:
///
/// 1. `characters_en.dart`, `events_en.dart`, `glossary_en.dart` yazılır
///    (model yapıları aynı kalır, sadece metinler değişir).
/// 2. Aşağıdaki [GameContent] kayıt tablosuna o dil için bir satır eklenir.
/// 3. Aşama 2'deki içerik provider'ı mevcut dile göre doğru [GameContent]
///    nesnesini seçer.
///
/// UI katmanı içeriğe her zaman provider üzerinden eriştiği için ekran ve
/// widget kodunda hiçbir değişiklik gerekmez.
library;

import '../l10n/app_language.dart';
import '../models/character.dart';
import '../models/employee.dart';
import '../models/event_card.dart';
import '../models/game_action.dart';
import '../models/glossary_term.dart';
import 'actions.dart';
import 'characters.dart';
import 'events.dart';
import 'glossary.dart';

export 'actions.dart';
export 'characters.dart';
export 'events.dart';
export 'glossary.dart';

/// Bir dile ait bütün statik oyun içeriği.
class GameContent {
  const GameContent({
    required this.language,
    required this.characters,
    required this.actions,
    required this.hireOptions,
    required this.events,
    required this.glossary,
  });

  /// İçeriğin dili.
  final AppLanguage language;

  /// Ana karakterler.
  final List<Character> characters;

  /// Haftalık aksiyonlar.
  final List<GameAction> actions;

  /// İşe alım şablonları.
  final List<Employee> hireOptions;

  /// Olay kartları.
  final List<EventCard> events;

  /// Sözlük terimleri.
  final List<GlossaryTerm> glossary;

  /// Türkçe içerik.
  static const GameContent turkish = GameContent(
    language: AppLanguage.tr,
    characters: kCharacters,
    actions: kGameActions,
    hireOptions: kHireOptions,
    events: kEventCards,
    glossary: kGlossaryTerms,
  );

  /// Dile göre içerik kayıt tablosu. Yeni dil buraya eklenir.
  static const Map<AppLanguage, GameContent> _registry = {
    AppLanguage.tr: turkish,
  };

  /// Verilen dilin içeriğini döner; o dil için içerik yoksa varsayılan dile düşer.
  static GameContent of(AppLanguage language) =>
      _registry[language] ?? _registry[AppLanguage.fallback]!;

  /// İçeriği hazır olan diller.
  static List<AppLanguage> get supportedLanguages =>
      _registry.keys.toList(growable: false);
}
