import 'employee.dart';
import 'event_card.dart';
import 'event_choice.dart';
import 'game_action.dart';
import 'game_effect.dart';
import 'game_state.dart';

/// Bir sprint'in (haftanın) simülasyon sonucu.
///
/// Motor metin üretmez; yalnızca **ne olduğunu sayısal olarak** döner.
/// Kullanıcıya görünen metinleri Aşama 3'teki UI `lib/l10n/` üzerinden
/// kurar. Böylece motor saf Dart kalır ve dile bağımlı olmaz.
class SprintResult {
  const SprintResult({
    required this.previousState,
    required this.state,
    required this.action,
    required this.actionEffect,
    required this.teamEffect,
    required this.debtEffect,
    required this.revenueCollected,
    this.hiredEmployee,
    this.triggeredEvent,
  });

  /// Sprint başlamadan önceki durum (önce/sonra karşılaştırması için).
  final GameState previousState;

  /// Sprint sonrası yeni durum.
  final GameState state;

  /// Oyuncunun seçtiği aksiyon.
  final GameAction action;

  /// Aksiyonun kendi etkisi (işe alımda tek seferlik maliyet).
  final GameEffect actionEffect;

  /// Ekibin pasif borç/moral etkisi.
  final GameEffect teamEffect;

  /// Teknik borcun doğal artışı ve yüksek borç cezası.
  final GameEffect debtEffect;

  /// Bu hafta kasaya giren net nakit ($).
  ///
  /// Gelir (teknik borç cezası uygulanmış) eksi maaşlar. Negatif olabilir.
  final int revenueCollected;

  /// İşe alım yapıldıysa ekibe katılan çalışan.
  final Employee? hiredEmployee;

  /// Hafta sonunda çıkan ve karar bekleyen olay kartı.
  ///
  /// `null` ise bu hafta sakin geçti. Doluysa [state] içindeki
  /// [GameState.pendingEventId] de bu kartı işaret eder.
  final EventCard? triggeredEvent;

  /// Bu sprint'te duruma uygulanan bütün etkilerin toplamı.
  ///
  /// Nakit tarafı [revenueCollected] ile ayrı geldiği için burada
  /// `budgetDelta` yalnızca aksiyonun maliyetini içerir.
  GameEffect get totalEffect => actionEffect + teamEffect + debtEffect;

  /// Bütçenin sprint boyunca toplam değişimi ($).
  int get budgetChange => state.budget - previousState.budget;

  /// Oyun bu sprint'te bitti mi?
  bool get isGameOver => !state.isPlaying;

  @override
  String toString() =>
      'SprintResult(hafta ${previousState.week} → ${state.week}, '
      '${action.id}, olay: ${triggeredEvent?.id ?? "yok"})';
}

/// Bir olay kartı seçiminin sonucu.
class EventResolution {
  const EventResolution({
    required this.previousState,
    required this.state,
    required this.card,
    required this.choice,
  });

  /// Seçim yapılmadan önceki durum.
  final GameState previousState;

  /// Seçim uygulandıktan sonraki durum.
  final GameState state;

  /// Karar verilen olay kartı.
  final EventCard card;

  /// Oyuncunun seçtiği seçenek.
  final EventChoice choice;

  /// Bu seçim krizi çözdü mü?
  bool get resolvedCrisis => choice.resolvesCrisis;

  /// Oyun bu seçimle bitti mi?
  bool get isGameOver => !state.isPlaying;

  @override
  String toString() =>
      'EventResolution(${card.id} → ${choice.id}, '
      'kriz çözüldü: $resolvedCrisis)';
}
