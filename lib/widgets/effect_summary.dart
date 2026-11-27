import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';

/// Bir [GameEffect]'i renkli etiketler hâlinde gösterir.
///
/// Aksiyon kartlarında ve olay seçeneklerinde kullanılır: oyuncu seçimin
/// bedelini önceden görebilsin. Sıfır olan alanlar gösterilmez — gürültü
/// yapmasın.
///
/// Renk kuralı: artması iyi olan metrikte artış yeşil; teknik borçta
/// tersi ([AppColors.forDelta] `inverted`).
class EffectSummary extends ConsumerWidget {
  const EffectSummary(this.effect, {super.key, this.compact = false});

  /// Gösterilecek efekt.
  final GameEffect effect;

  /// `true` ise yalnızca en belirleyici iki alanı gösterir (dar yerler için).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final entries = <_EffectEntry>[
      if (effect.budgetDelta != 0)
        _EffectEntry(
          icon: AppIcons.budget,
          text: formatSignedMoney(effect.budgetDelta),
          color: AppColors.forDelta(effect.budgetDelta),
          semantics: strings[StringKey.metricBudget],
        ),
      if (effect.revenueDelta != 0)
        _EffectEntry(
          icon: AppIcons.revenue,
          text: formatSignedMoney(effect.revenueDelta),
          color: AppColors.forDelta(effect.revenueDelta),
          semantics: strings[StringKey.metricWeeklyRevenue],
        ),
      if (effect.valuationDelta != 0)
        _EffectEntry(
          icon: AppIcons.valuation,
          text: formatSignedMoney(effect.valuationDelta),
          color: AppColors.forDelta(effect.valuationDelta),
          semantics: strings[StringKey.metricValuation],
        ),
      if (effect.techDebtDelta != 0)
        _EffectEntry(
          icon: AppIcons.techDebt,
          text: formatSignedPercent(effect.techDebtDelta),
          color: AppColors.forDelta(effect.techDebtDelta, inverted: true),
          semantics: strings[StringKey.metricTechDebt],
        ),
      if (effect.moraleDelta != 0)
        _EffectEntry(
          icon: AppIcons.morale,
          text: formatSignedPercent(effect.moraleDelta),
          color: AppColors.forDelta(effect.moraleDelta),
          semantics: strings[StringKey.metricTeamMorale],
        ),
    ];

    if (entries.isEmpty) return const SizedBox.shrink();

    final shown = compact ? entries.take(2).toList() : entries;

    return Wrap(
      spacing: AppDimens.gapSm,
      runSpacing: AppDimens.gapXs,
      children: shown
          .map(
            (entry) => Semantics(
              label: entry.semantics,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(entry.icon, size: 13, color: entry.color),
                  const SizedBox(width: 3),
                  Text(
                    entry.text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: entry.color,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EffectEntry {
  const _EffectEntry({
    required this.icon,
    required this.text,
    required this.color,
    required this.semantics,
  });

  final IconData icon;
  final String text;
  final Color color;
  final String semantics;
}
