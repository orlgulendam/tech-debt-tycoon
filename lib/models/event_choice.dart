import 'game_effect.dart';

/// Bir olay kartındaki tek bir seçenek.
class EventChoice {
  const EventChoice({
    required this.id,
    required this.label,
    required this.effect,
    required this.outcomeText,
    this.outcomeSpeakerId,
    this.resolvesCrisis = false,
  });

  /// Tekil kimlik (kart içinde benzersiz, ör. `deploy`).
  final String id;

  /// Butonda yazan seçenek metni (kullanıcıya görünür).
  final String label;

  /// Seçeneğin kaynaklara etkisi.
  final GameEffect effect;

  /// Seçim yapıldıktan sonra gösterilen sonuç metni (kullanıcıya görünür).
  final String outcomeText;

  /// Sonuç metnini söyleyen karakterin kimliği. `null` ise anlatıcı konuşur.
  final String? outcomeSpeakerId;

  /// Bu seçenek krizi "çözmüş" sayılır mı?
  ///
  /// `true` ise [GameState.resolvedCrises] bir artar; skor kartında
  /// "çözülen kriz" olarak görünür.
  final bool resolvesCrisis;

  EventChoice copyWith({
    String? id,
    String? label,
    GameEffect? effect,
    String? outcomeText,
    String? outcomeSpeakerId,
    bool? resolvesCrisis,
  }) => EventChoice(
    id: id ?? this.id,
    label: label ?? this.label,
    effect: effect ?? this.effect,
    outcomeText: outcomeText ?? this.outcomeText,
    outcomeSpeakerId: outcomeSpeakerId ?? this.outcomeSpeakerId,
    resolvesCrisis: resolvesCrisis ?? this.resolvesCrisis,
  );

  @override
  String toString() => 'EventChoice($id)';
}
