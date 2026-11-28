import 'game_record.dart';
import 'game_state.dart';

/// Oyuncunun bütün oyunlarından türetilen kariyer özeti.
///
/// "Log & Kariyer" sekmesinin üst kısmında gösterilir. Kayıtlardan
/// hesaplanır, ayrıca saklanmaz: tek doğruluk kaynağı [GameRecord] listesi.
class CareerStats {
  const CareerStats({
    required this.totalGames,
    required this.totalWins,
    required this.bestValuation,
    required this.longestRunWeeks,
    required this.totalResolvedCrises,
  });

  /// Hiç oyun oynanmamış durum.
  static const CareerStats empty = CareerStats(
    totalGames: 0,
    totalWins: 0,
    bestValuation: 0,
    longestRunWeeks: 0,
    totalResolvedCrises: 0,
  );

  /// Tamamlanmış oyun sayısı.
  final int totalGames;

  /// Kazanılan (Unicorn) oyun sayısı.
  final int totalWins;

  /// Ulaşılan en yüksek değerleme ($).
  final int bestValuation;

  /// En uzun süren oyunun hafta sayısı.
  final int longestRunWeeks;

  /// Bütün oyunlarda çözülen toplam kriz sayısı.
  final int totalResolvedCrises;

  /// Hiç oyun oynanmamış mı?
  bool get isEmpty => totalGames == 0;

  /// Kazanma oranı (0.0 - 1.0). Oyun yoksa 0.
  double get winRate => totalGames == 0 ? 0 : totalWins / totalGames;

  /// Unicorn hedefine en yakın gelinen oran (0.0 - 1.0).
  double get bestProgress =>
      (bestValuation / GameState.winValuation).clamp(0.0, 1.0).toDouble();

  /// Kayıt listesinden özet hesaplar.
  factory CareerStats.fromRecords(List<GameRecord> records) {
    if (records.isEmpty) return empty;

    var wins = 0;
    var bestValuation = 0;
    var longestRun = 0;
    var crises = 0;

    for (final record in records) {
      if (record.isWin) wins++;
      if (record.finalValuation > bestValuation) {
        bestValuation = record.finalValuation;
      }
      if (record.weeksSurvived > longestRun) {
        longestRun = record.weeksSurvived;
      }
      crises += record.resolvedCrises;
    }

    return CareerStats(
      totalGames: records.length,
      totalWins: wins,
      bestValuation: bestValuation,
      longestRunWeeks: longestRun,
      totalResolvedCrises: crises,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CareerStats &&
      other.totalGames == totalGames &&
      other.totalWins == totalWins &&
      other.bestValuation == bestValuation &&
      other.longestRunWeeks == longestRunWeeks &&
      other.totalResolvedCrises == totalResolvedCrises;

  @override
  int get hashCode => Object.hash(
    totalGames,
    totalWins,
    bestValuation,
    longestRunWeeks,
    totalResolvedCrises,
  );

  @override
  String toString() =>
      'CareerStats($totalGames oyun, $totalWins unicorn, '
      'en iyi: $bestValuation\$)';
}
