import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';

/// Paylaşılabilir CTO karnesi.
///
/// Oyun sonu kartından ayrı bir widget: bunun tek işi **görsele
/// dönüştürülebilir** olmak. Bu yüzden kendi arka planı, kendi
/// kenarlıkları ve sabit bir en-boy oranı var — ekrandaki temadan
/// bağımsız olarak tek başına anlamlı görünmeli, çünkü sosyal medyada
/// bağlamsız duracak.
///
/// Ekranda da aynı widget gösteriliyor; paylaşılan görsel ile oyuncunun
/// gördüğü şeyin birebir aynı olması önemli.
class ScoreCard extends ConsumerWidget {
  const ScoreCard({required this.state, super.key});

  /// Bitmiş oyunun durumu.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;
    final won = state.status == GameStatus.won;
    final accent = won ? AppColors.good : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(AppDimens.gapLg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst şerit: oyunun adı. Paylaşılan görselde bu olmazsa kimse
          // neyin skoru olduğunu anlamaz.
          // Dar telefonlarda iki etiket yan yana sığmıyordu; oyun adı
          // esneyip gerekirse kısalıyor, karne etiketi sabit kalıyor.
          Row(
            children: [
              Icon(Icons.terminal, size: AppDimens.iconSm, color: accent),
              const SizedBox(width: AppDimens.gapXs),
              Flexible(
                child: Text(
                  strings[StringKey.appTitle].toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(color: accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimens.gapSm),
              Text(
                strings[StringKey.gameOverScoreCardTitle].toUpperCase(),
                style: textTheme.labelSmall,
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapLg),

          Row(
            children: [
              Icon(
                won ? AppIcons.unicorn : Icons.dangerous_outlined,
                color: accent,
                size: 30,
              ),
              const SizedBox(width: AppDimens.gapMd),
              Expanded(
                child: Text(
                  won
                      ? strings[StringKey.gameOverWonTitle]
                      : strings[_lossKey(state.lossReason)],
                  style: textTheme.titleMedium?.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapLg),

          // Üç büyük sayı: hafta, değerleme, çözülen kriz.
          Row(
            children: [
              Expanded(
                child: _BigStat(
                  label: strings[StringKey.gameOverWeeksLabel],
                  value: '${state.week}',
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _BigStat(
                  label: strings[StringKey.gameOverValuationLabel],
                  value: formatCompactMoney(state.valuation),
                  color: accent,
                ),
              ),
              Expanded(
                child: _BigStat(
                  label: strings[StringKey.gameOverCrisesLabel],
                  value: '${state.resolvedCrises}',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapLg),

          // Son durumdaki teknik borç ve moral: skorun "nasıl"ı.
          _MiniBar(
            label: strings[StringKey.metricTechDebt],
            value: state.techDebt,
            color: AppColors.forTechDebt(state.techDebt),
          ),
          const SizedBox(height: AppDimens.gapSm),
          _MiniBar(
            label: strings[StringKey.metricTeamMorale],
            value: state.teamMorale,
            color: AppColors.forMorale(state.teamMorale),
          ),

          const SizedBox(height: AppDimens.gapLg),
          Text(strings[StringKey.appTagline], style: textTheme.labelSmall),
        ],
      ),
    );
  }

  StringKey _lossKey(LossReason? reason) => switch (reason) {
    LossReason.bankruptcy => StringKey.lossReasonBankruptcy,
    LossReason.serverMeltdown => StringKey.lossReasonServerMeltdown,
    LossReason.massResignation => StringKey.lossReasonMassResignation,
    null => StringKey.gameOverLostTitle,
  };
}

/// Karnedeki büyük sayı.
class _BigStat extends StatelessWidget {
  const _BigStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: color,
            fontFeatures: AppTypography.tabularFigures,
          ),
          maxLines: 1,
        ),
        Text(label, style: textTheme.labelSmall, maxLines: 2),
      ],
    );
  }
}

/// Karnedeki ince yüzde çubuğu.
class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(width: 96, child: Text(label, style: textTheme.labelSmall)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              color: color,
              backgroundColor: AppColors.surfaceAlt,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.gapSm),
        Text(
          formatPercent(value),
          style: textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
