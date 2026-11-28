/// Sözlük teriminin kategorisi. Sözlük ekranında filtreleme için kullanılır.
enum GlossaryCategory {
  /// Kod ve mimari (Refactoring, Legacy Code, Spaghetti Code...).
  engineering,

  /// Süreç ve ekip çalışması (Sprint, Pull Request, Code Review...).
  process,

  /// Altyapı ve operasyon (Deploy, CI/CD, Rollback, Production...).
  infrastructure,

  /// Test ve kalite (Unit Test, Hotfix...).
  quality,

  /// Ürün ve iş tarafı (MVP, Bottleneck...).
  business,
}

/// Sözlükteki tek bir yazılım terimi.
///
/// Oyunun eğitici tarafı buradan gelir: oyuncu bir terimin ne olduğunu,
/// gerçek hayatta neye benzediğini ve oyun mekaniğinde ne işe yaradığını
/// aynı kartta görür.
class GlossaryTerm {
  const GlossaryTerm({
    required this.id,
    required this.name,
    required this.shortDefinition,
    required this.realLifeExample,
    required this.gameEffect,
    required this.category,
  });

  /// Tekil kimlik (ör. `technical_debt`).
  final String id;

  /// Terimin adı (kullanıcıya görünür, genelde İngilizce özgün hâli).
  final String name;

  /// Kısa tanım — tek cümlede ne olduğu (kullanıcıya görünür).
  final String shortDefinition;

  /// Gerçek hayattan örnek (kullanıcıya görünür).
  final String realLifeExample;

  /// Oyundaki mekanik etkisi: bu terim oyunun hangi sayısına dokunuyor
  /// (kullanıcıya görünür).
  final String gameEffect;

  /// Kategori.
  final GlossaryCategory category;

  GlossaryTerm copyWith({
    String? id,
    String? name,
    String? shortDefinition,
    String? realLifeExample,
    String? gameEffect,
    GlossaryCategory? category,
  }) => GlossaryTerm(
    id: id ?? this.id,
    name: name ?? this.name,
    shortDefinition: shortDefinition ?? this.shortDefinition,
    realLifeExample: realLifeExample ?? this.realLifeExample,
    gameEffect: gameEffect ?? this.gameEffect,
    category: category ?? this.category,
  );

  @override
  String toString() => 'GlossaryTerm($id, $name)';
}
