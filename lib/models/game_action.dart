import 'game_effect.dart';

/// Haftalık aksiyonun türü.
///
/// Motor bazı aksiyonları özel ele alır: [hire] seçildiğinde doğrudan efekt
/// uygulanmaz, önce işe alım seçimi için bir bottom sheet açılır (Aşama 3).
enum GameActionKind {
  /// Hızlı feature çıkarma: gelir ve değerleme artar, teknik borç birikir.
  shipFeature,

  /// Temiz kod ve test yazma: dengeli, borç üretmez.
  cleanCode,

  /// Refactoring sprinti: teknik borcu eritir.
  refactor,

  /// Ekip motivasyonu: bütçe harcayıp moral satın alır.
  teamMorale,

  /// İşe alım: ekibe kalıcı bir çalışan ekler.
  hire,
}

/// Oyuncunun her hafta seçebileceği aksiyon.
class GameAction {
  const GameAction({
    required this.id,
    required this.name,
    required this.description,
    required this.kind,
    required this.effect,
    required this.iconId,
  });

  /// Tekil kimlik (ör. `action_ship_feature`).
  final String id;

  /// Aksiyonun adı (kullanıcıya görünür).
  final String name;

  /// Kısa açıklama (kullanıcıya görünür).
  final String description;

  /// Aksiyonun türü.
  final GameActionKind kind;

  /// Aksiyonun kaynaklara etkisi.
  final GameEffect effect;

  /// İkon tanımlayıcısı. Aşama 3'te tema katmanı bir ikona eşler.
  final String iconId;

  // Efektin alanlarına kısayollar — UI ve testler tek tek alanlara
  // `action.effect.budgetDelta` yazmak zorunda kalmasın.

  /// Bütçe etkisi ($).
  int get budgetDelta => effect.budgetDelta;

  /// Haftalık gelir etkisi ($/hafta).
  int get revenueDelta => effect.revenueDelta;

  /// Değerleme etkisi ($).
  int get valuationDelta => effect.valuationDelta;

  /// Teknik borç etkisi (yüzde puanı).
  int get techDebtDelta => effect.techDebtDelta;

  /// Moral etkisi (yüzde puanı).
  int get moraleDelta => effect.moraleDelta;

  /// Bu aksiyon ekibe yeni biri eklemek için mi?
  bool get requiresHireSelection => kind == GameActionKind.hire;

  GameAction copyWith({
    String? id,
    String? name,
    String? description,
    GameActionKind? kind,
    GameEffect? effect,
    String? iconId,
  }) => GameAction(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    kind: kind ?? this.kind,
    effect: effect ?? this.effect,
    iconId: iconId ?? this.iconId,
  );

  @override
  String toString() => 'GameAction($id, ${kind.name})';
}
