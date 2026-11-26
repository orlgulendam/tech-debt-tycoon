/// İpucunun işaret ettiği metrik.
enum HintMetric {
  /// Nakit bütçe.
  budget,

  /// Haftalık gelir.
  revenue,

  /// Şirket değerlemesi.
  valuation,

  /// Teknik borç.
  techDebt,

  /// Ekip morali.
  teamMorale,

  /// Ekip kadrosu (işe alım ihtiyacı).
  team,
}

/// Akıllı ipucu algoritmasının (Aşama 2) ürettiği tavsiye.
///
/// Algoritma o anki [GameState]'in en kritik metriğini bulup tek bir net
/// tavsiye döner; "danışman" bunu oyuncuya söyler.
class HintResult {
  const HintResult({
    required this.advice,
    required this.reasoning,
    required this.metric,
    this.suggestedActionId,
    this.priority = 1,
  });

  /// Tavsiye metni: ne yapılmalı (kullanıcıya görünür).
  final String advice;

  /// Gerekçe: neden bu tavsiye verildi (kullanıcıya görünür).
  final String reasoning;

  /// Tavsiyenin dayandığı metrik.
  final HintMetric metric;

  /// Önerilen aksiyonun kimliği ([GameAction.id]). Aşama 3'te ilgili aksiyon
  /// butonu vurgulanır. Belirli bir aksiyon önerilmiyorsa `null`.
  final String? suggestedActionId;

  /// Aciliyet: 0 = bilgi, 1 = normal, 2 = önemli, 3 = kritik.
  /// Aşama 2'deki seçici en yüksek aciliyetli ipucunu gösterir.
  final int priority;

  /// Kritik aciliyette mi?
  bool get isUrgent => priority >= 3;

  HintResult copyWith({
    String? advice,
    String? reasoning,
    HintMetric? metric,
    String? suggestedActionId,
    bool clearSuggestedActionId = false,
    int? priority,
  }) => HintResult(
    advice: advice ?? this.advice,
    reasoning: reasoning ?? this.reasoning,
    metric: metric ?? this.metric,
    suggestedActionId: clearSuggestedActionId
        ? null
        : (suggestedActionId ?? this.suggestedActionId),
    priority: priority ?? this.priority,
  );

  @override
  bool operator ==(Object other) =>
      other is HintResult &&
      other.advice == advice &&
      other.reasoning == reasoning &&
      other.metric == metric &&
      other.suggestedActionId == suggestedActionId &&
      other.priority == priority;

  @override
  int get hashCode =>
      Object.hash(advice, reasoning, metric, suggestedActionId, priority);

  @override
  String toString() => 'HintResult(${metric.name}, aciliyet: $priority)';
}
