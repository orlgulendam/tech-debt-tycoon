import 'event_choice.dart';

/// Olayın ciddiyeti. Aşama 3'te kartın kenar/başlık rengini belirler.
enum EventSeverity {
  /// Nötr/bilgilendirici olay.
  info,

  /// Dikkat gerektiren olay.
  warning,

  /// Kritik kriz.
  critical,

  /// Olumlu haber.
  positive,
}

/// Hafta sonunda çıkabilen olay kartı.
///
/// Oyuncu kartın [choices] listesinden birini seçer; seçtiği seçeneğin efekti
/// uygulanır ve sonuç metni gösterilir.
class EventCard {
  const EventCard({
    required this.id,
    required this.title,
    required this.narration,
    required this.speakerId,
    required this.severity,
    required this.choices,
    this.minWeek = 1,
  });

  /// Tekil kimlik (ör. `event_friday_deploy`).
  final String id;

  /// Kart başlığı (kullanıcıya görünür).
  final String title;

  /// Olayı anlatan metin / karakterin açılış repliği (kullanıcıya görünür).
  final String narration;

  /// Olayı anlatan karakterin kimliği ([Character.id] ile eşleşir).
  final String speakerId;

  /// Olayın ciddiyeti.
  final EventSeverity severity;

  /// Seçenekler. Her kartta en az 2 seçenek bulunur.
  final List<EventChoice> choices;

  /// Bu olayın çıkabileceği en erken hafta.
  ///
  /// Yatırımcı sunumu gibi geç oyun olayları ilk haftalarda çıkmasın diye.
  final int minWeek;

  /// Kriz niteliğinde bir olay mı? (Skor kartı ve tema rengi için.)
  bool get isCrisis =>
      severity == EventSeverity.critical || severity == EventSeverity.warning;

  /// Verilen kimliğe sahip seçeneği bulur; yoksa `null` döner.
  EventChoice? choiceById(String choiceId) {
    for (final choice in choices) {
      if (choice.id == choiceId) return choice;
    }
    return null;
  }

  EventCard copyWith({
    String? id,
    String? title,
    String? narration,
    String? speakerId,
    EventSeverity? severity,
    List<EventChoice>? choices,
    int? minWeek,
  }) => EventCard(
    id: id ?? this.id,
    title: title ?? this.title,
    narration: narration ?? this.narration,
    speakerId: speakerId ?? this.speakerId,
    severity: severity ?? this.severity,
    choices: choices ?? this.choices,
    minWeek: minWeek ?? this.minWeek,
  );

  @override
  String toString() => 'EventCard($id, ${choices.length} seçenek)';
}
