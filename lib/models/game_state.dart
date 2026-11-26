import 'employee.dart';
import 'game_effect.dart';
import 'model_utils.dart';

/// Oyunun genel durumu.
enum GameStatus {
  /// Oyun devam ediyor.
  playing,

  /// Unicorn! Değerleme hedefe ulaştı.
  won,

  /// Oyun kaybedildi; nedeni [GameState.lossReason] içinde.
  lost,
}

/// Oyunun kaybedilme nedeni.
enum LossReason {
  /// Bütçe 0$'a düştü.
  bankruptcy,

  /// Teknik borç %100'e ulaştı; sunucular yandı.
  serverMeltdown,

  /// Ekip morali %0'a düştü; toplu istifa.
  massResignation,
}

/// Oyunun bütün değişken durumunu tutan değişmez (immutable) kök model.
///
/// Aşama 2'deki motor her hafta bu nesneden yenisini üretir; hiçbir alan
/// yerinde değiştirilmez. Kayıt sistemi de doğrudan bunu serileştirir.
class GameState {
  const GameState({
    required this.week,
    required this.budget,
    required this.valuation,
    required this.weeklyRevenue,
    required this.techDebt,
    required this.teamMorale,
    this.status = GameStatus.playing,
    this.lossReason,
    this.resolvedCrises = 0,
    this.usedFreeHints = 0,
    this.hiredConsultants = 0,
    this.team = const [],
  });

  // --- Oyun dengesi sabitleri -------------------------------------------
  // Bu değerler durumun değişmezleridir (başlangıç noktası ve sınırlar).
  // Aksiyon/olay gibi veriye bağlı ayarlar `lib/data/` altında durur.

  /// Başlangıç bütçesi ($).
  static const int initialBudget = 15000;

  /// Başlangıç değerlemesi ($).
  static const int initialValuation = 50000;

  /// Başlangıç haftalık geliri ($/hafta).
  static const int initialWeeklyRevenue = 2000;

  /// Başlangıç teknik borcu (%).
  static const int initialTechDebt = 10;

  /// Başlangıç ekip morali (%).
  static const int initialTeamMorale = 75;

  /// Kazanmak için gerekli değerleme ($) — Unicorn eşiği.
  static const int winValuation = 1000000;

  /// Yüzde cinsinden ölçeklerin alt ve üst sınırı.
  static const int minPercent = 0;
  static const int maxPercent = 100;

  /// Teknik borcun "tehlikeli" sayıldığı eşik (%).
  /// Zeynep bu eşiğin üstünde sert uyarılar verir.
  static const int highTechDebtThreshold = 60;

  /// Moralin "düşük" sayıldığı eşik (%).
  static const int lowMoraleThreshold = 30;

  /// Bütçenin "düşük" sayıldığı eşik ($).
  static const int lowBudgetThreshold = 5000;

  /// Kayıt şeması sürümü. İleride alan eklenirse göç için kullanılacak.
  static const int schemaVersion = 1;

  // --- Durum alanları ----------------------------------------------------

  /// Kaçıncı hafta (sprint). 1'den başlar.
  final int week;

  /// Nakit bütçe ($). 0'a düşerse iflas.
  final int budget;

  /// Şirket değerlemesi ($). [winValuation]'a ulaşırsa oyun kazanılır.
  final int valuation;

  /// Haftalık gelir ($/hafta). Her hafta bütçeye eklenir.
  final int weeklyRevenue;

  /// Teknik borç (%, 0-100). 100'e ulaşırsa sunucular yanar.
  final int techDebt;

  /// Ekip morali (%, 0-100). 0'a düşerse toplu istifa.
  final int teamMorale;

  /// Oyunun genel durumu (devam/kazandı/kaybetti).
  final GameStatus status;

  /// Kaybedildiyse nedeni; aksi halde `null`.
  final LossReason? lossReason;

  /// Başarıyla çözülen kriz (olay kartı) sayısı. Skor kartında gösterilir.
  final int resolvedCrises;

  /// Kullanılan ücretsiz ipucu sayısı. Hak dolunca reklam istenir (Aşama 2).
  final int usedFreeHints;

  /// Reklam izleyerek tutulan danışman sayısı.
  final int hiredConsultants;

  /// Ekipteki çalışanlar.
  final List<Employee> team;

  // --- Türetilmiş değerler ----------------------------------------------

  /// Ekibin toplam haftalık maaş yükü ($).
  int get totalSalaries =>
      team.fold(0, (sum, employee) => sum + employee.weeklySalary);

  /// Ekibin haftalık gelire toplam katkısı ($).
  int get totalTeamRevenue =>
      team.fold(0, (sum, employee) => sum + employee.revenueContribution);

  /// Haftalık nakit akışı ($): temel gelir + ekip katkısı - maaşlar.
  ///
  /// Negatifse şirket her hafta para kaybediyor.
  int get netWeeklyCashFlow => weeklyRevenue + totalTeamRevenue - totalSalaries;

  /// Ekibin toplam pasif etkisi (maaş, gelir, borç, moral bir arada).
  GameEffect get teamPassiveEffect => team.fold(
    GameEffect.none,
    (total, employee) => total + employee.passiveEffect,
  );

  /// Unicorn hedefine ilerleme (0.0 - 1.0 arası).
  double get unicornProgress =>
      (valuation / winValuation).clamp(0.0, 1.0).toDouble();

  /// Teknik borç tehlikeli seviyede mi?
  bool get isTechDebtCritical => techDebt >= highTechDebtThreshold;

  /// Moral tehlikeli seviyede mi?
  bool get isMoraleCritical => teamMorale <= lowMoraleThreshold;

  /// Bütçe tehlikeli seviyede mi?
  bool get isBudgetCritical => budget <= lowBudgetThreshold;

  /// Oyun hâlâ oynanabilir durumda mı?
  bool get isPlaying => status == GameStatus.playing;

  /// Ekip boş mu? (Oyun tek başına CTO olarak başlar.)
  bool get hasTeam => team.isNotEmpty;

  // --- Yardımcılar -------------------------------------------------------

  /// Yeni oyun için başlangıç durumu.
  factory GameState.newGame() => const GameState(
    week: 1,
    budget: initialBudget,
    valuation: initialValuation,
    weeklyRevenue: initialWeeklyRevenue,
    techDebt: initialTechDebt,
    teamMorale: initialTeamMorale,
  );

  /// Yüzde alanlarını geçerli aralığa sıkıştırmış bir kopya döner.
  ///
  /// Motor efekt uyguladıktan sonra bunu çağırır; böylece teknik borç ve
  /// moral asla 0-100 dışına taşmaz.
  GameState clamped() => copyWith(
    techDebt: clampInt(techDebt, minPercent, maxPercent),
    teamMorale: clampInt(teamMorale, minPercent, maxPercent),
  );

  /// `lossReason`'ı da temizleyebilmek için `copyWith`'in yanında ayrı bayrak
  /// kullanıyoruz: `clearLossReason: true` verilirse neden `null`'a çekilir.
  GameState copyWith({
    int? week,
    int? budget,
    int? valuation,
    int? weeklyRevenue,
    int? techDebt,
    int? teamMorale,
    GameStatus? status,
    LossReason? lossReason,
    bool clearLossReason = false,
    int? resolvedCrises,
    int? usedFreeHints,
    int? hiredConsultants,
    List<Employee>? team,
  }) => GameState(
    week: week ?? this.week,
    budget: budget ?? this.budget,
    valuation: valuation ?? this.valuation,
    weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
    techDebt: techDebt ?? this.techDebt,
    teamMorale: teamMorale ?? this.teamMorale,
    status: status ?? this.status,
    lossReason: clearLossReason ? null : (lossReason ?? this.lossReason),
    resolvedCrises: resolvedCrises ?? this.resolvedCrises,
    usedFreeHints: usedFreeHints ?? this.usedFreeHints,
    hiredConsultants: hiredConsultants ?? this.hiredConsultants,
    team: team ?? this.team,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'week': week,
    'budget': budget,
    'valuation': valuation,
    'weeklyRevenue': weeklyRevenue,
    'techDebt': techDebt,
    'teamMorale': teamMorale,
    'status': status.name,
    'lossReason': lossReason?.name,
    'resolvedCrises': resolvedCrises,
    'usedFreeHints': usedFreeHints,
    'hiredConsultants': hiredConsultants,
    'team': team.map((employee) => employee.toJson()).toList(),
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final rawTeam = json['team'];
    return GameState(
      week: readInt(json['week'], fallback: 1),
      budget: readInt(json['budget'], fallback: initialBudget),
      valuation: readInt(json['valuation'], fallback: initialValuation),
      weeklyRevenue: readInt(
        json['weeklyRevenue'],
        fallback: initialWeeklyRevenue,
      ),
      techDebt: readInt(json['techDebt'], fallback: initialTechDebt),
      teamMorale: readInt(json['teamMorale'], fallback: initialTeamMorale),
      status: enumFromName(
        GameStatus.values,
        json['status'],
        fallback: GameStatus.playing,
      ),
      lossReason: json['lossReason'] == null
          ? null
          : enumFromName(
              LossReason.values,
              json['lossReason'],
              fallback: LossReason.bankruptcy,
            ),
      resolvedCrises: readInt(json['resolvedCrises']),
      usedFreeHints: readInt(json['usedFreeHints']),
      hiredConsultants: readInt(json['hiredConsultants']),
      team: rawTeam is List
          ? rawTeam
                .whereType<Map>()
                .map((raw) => Employee.fromJson(Map<String, dynamic>.from(raw)))
                .toList(growable: false)
          : const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameState &&
      other.week == week &&
      other.budget == budget &&
      other.valuation == valuation &&
      other.weeklyRevenue == weeklyRevenue &&
      other.techDebt == techDebt &&
      other.teamMorale == teamMorale &&
      other.status == status &&
      other.lossReason == lossReason &&
      other.resolvedCrises == resolvedCrises &&
      other.usedFreeHints == usedFreeHints &&
      other.hiredConsultants == hiredConsultants &&
      listEquals(other.team, team);

  @override
  int get hashCode => Object.hash(
    week,
    budget,
    valuation,
    weeklyRevenue,
    techDebt,
    teamMorale,
    status,
    lossReason,
    resolvedCrises,
    usedFreeHints,
    hiredConsultants,
    listHash(team),
  );

  @override
  String toString() =>
      'GameState(hafta: $week, bütçe: $budget\$, değerleme: $valuation\$, '
      'borç: $techDebt%, moral: $teamMorale%, durum: ${status.name})';
}
