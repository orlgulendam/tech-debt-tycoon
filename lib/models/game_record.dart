import 'game_state.dart';
import 'model_utils.dart';

/// Tamamlanmış bir oyunun kalıcı kaydı.
///
/// "Log & Kariyer" sekmesinde geçmiş oyunlar listesi ve en yüksek değerleme
/// bu kayıtlardan hesaplanır.
class GameRecord {
  const GameRecord({
    required this.id,
    required this.playedAt,
    required this.weeksSurvived,
    required this.finalValuation,
    required this.resolvedCrises,
    required this.outcome,
    required this.ctoNote,
    this.lossReason,
  });

  /// Tekil kimlik (kayıt anındaki zaman damgasından üretilir).
  final String id;

  /// Oyunun bittiği tarih.
  final DateTime playedAt;

  /// Ulaşılan hafta sayısı.
  final int weeksSurvived;

  /// Final şirket değerlemesi ($).
  final int finalValuation;

  /// Oyun boyunca çözülen kriz sayısı.
  final int resolvedCrises;

  /// Oyunun nasıl bittiği (kazandı/kaybetti).
  final GameStatus outcome;

  /// Kaybedildiyse nedeni; aksi halde `null`.
  final LossReason? lossReason;

  /// CTO notu: oyun sonunda üretilen kısa, esprili değerlendirme metni
  /// (kullanıcıya görünür).
  final String ctoNote;

  /// Oyun kazanıldı mı?
  bool get isWin => outcome == GameStatus.won;

  /// Bitmiş bir oyun durumundan kayıt üretir.
  ///
  /// [ctoNote] metnini Aşama 2'deki skor kartı servisi üretir.
  factory GameRecord.fromGameState(
    GameState state, {
    required String ctoNote,
    required DateTime playedAt,
  }) => GameRecord(
    id: playedAt.microsecondsSinceEpoch.toString(),
    playedAt: playedAt,
    weeksSurvived: state.week,
    finalValuation: state.valuation,
    resolvedCrises: state.resolvedCrises,
    outcome: state.status,
    lossReason: state.lossReason,
    ctoNote: ctoNote,
  );

  GameRecord copyWith({
    String? id,
    DateTime? playedAt,
    int? weeksSurvived,
    int? finalValuation,
    int? resolvedCrises,
    GameStatus? outcome,
    LossReason? lossReason,
    bool clearLossReason = false,
    String? ctoNote,
  }) => GameRecord(
    id: id ?? this.id,
    playedAt: playedAt ?? this.playedAt,
    weeksSurvived: weeksSurvived ?? this.weeksSurvived,
    finalValuation: finalValuation ?? this.finalValuation,
    resolvedCrises: resolvedCrises ?? this.resolvedCrises,
    outcome: outcome ?? this.outcome,
    lossReason: clearLossReason ? null : (lossReason ?? this.lossReason),
    ctoNote: ctoNote ?? this.ctoNote,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'playedAt': playedAt.toIso8601String(),
    'weeksSurvived': weeksSurvived,
    'finalValuation': finalValuation,
    'resolvedCrises': resolvedCrises,
    'outcome': outcome.name,
    'lossReason': lossReason?.name,
    'ctoNote': ctoNote,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    id: readString(json['id']),
    playedAt:
        DateTime.tryParse(readString(json['playedAt'])) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    weeksSurvived: readInt(json['weeksSurvived']),
    finalValuation: readInt(json['finalValuation']),
    resolvedCrises: readInt(json['resolvedCrises']),
    outcome: enumFromName(
      GameStatus.values,
      json['outcome'],
      fallback: GameStatus.lost,
    ),
    lossReason: json['lossReason'] == null
        ? null
        : enumFromName(
            LossReason.values,
            json['lossReason'],
            fallback: LossReason.bankruptcy,
          ),
    ctoNote: readString(json['ctoNote']),
  );

  @override
  bool operator ==(Object other) =>
      other is GameRecord &&
      other.id == id &&
      other.playedAt == playedAt &&
      other.weeksSurvived == weeksSurvived &&
      other.finalValuation == finalValuation &&
      other.resolvedCrises == resolvedCrises &&
      other.outcome == outcome &&
      other.lossReason == lossReason &&
      other.ctoNote == ctoNote;

  @override
  int get hashCode => Object.hash(
    id,
    playedAt,
    weeksSurvived,
    finalValuation,
    resolvedCrises,
    outcome,
    lossReason,
    ctoNote,
  );

  @override
  String toString() =>
      'GameRecord($id, hafta: $weeksSurvived, değerleme: $finalValuation\$)';
}
