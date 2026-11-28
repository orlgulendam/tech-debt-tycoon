import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Log & Kariyer sekmesi: kariyer özeti ve geçmiş oyunlar.
///
/// Oyuncunun kalıcı ilerleme hissi buradan geliyor. Tek bir oyun
/// kaybedilse bile en yüksek değerleme ve çözülen kriz sayısı kalıyor.
class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final stats = ref.watch(careerStatsProvider);
    final records = ref.watch(gameRecordsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        SectionLabel(strings[StringKey.logStatsSectionTitle]),
        _CareerSummary(stats: stats),
        const SizedBox(height: AppDimens.gapLg),

        SectionLabel(
          strings[StringKey.logHistorySectionTitle],
          trailing: Text(
            '${records.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),

        if (records.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              child: Row(
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    color: AppColors.textMuted,
                    size: AppDimens.iconMd,
                  ),
                  const SizedBox(width: AppDimens.gapMd),
                  Expanded(
                    child: Text(
                      strings[StringKey.logEmptyMessage],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final record in records) ...[
            _RecordCard(record: record),
            const SizedBox(height: AppDimens.gapSm),
          ],
      ],
    );
  }
}

/// Kariyer özeti kutusu.
class _CareerSummary extends ConsumerWidget {
  const _CareerSummary({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.valuation,
                    label: strings[StringKey.logBestValuation],
                    value: formatCompactMoney(stats.bestValuation),
                    valueColor: AppColors.good,
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.unicorn,
                    label: strings[StringKey.logTotalWins],
                    value: '${stats.totalWins}',
                    valueColor: stats.totalWins > 0
                        ? AppColors.good
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapSm),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    icon: Icons.sports_esports_outlined,
                    label: strings[StringKey.logTotalGames],
                    value: '${stats.totalGames}',
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.week,
                    label: strings[StringKey.logLongestRun],
                    value: strings.format(StringKey.logRecordWeeks, {
                      'weeks': '${stats.longestRunWeeks}',
                    }),
                  ),
                ),
              ],
            ),
            if (!stats.isEmpty) ...[
              const Divider(height: AppDimens.gapLg),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: AppDimens.iconSm,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppDimens.gapXs),
                  Expanded(
                    child: Text(
                      strings.format(StringKey.logRecordCrises, {
                        'count': '${stats.totalResolvedCrises}',
                      }),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tek bir geçmiş oyun kaydı.
class _RecordCard extends ConsumerWidget {
  const _RecordCard({required this.record});

  final GameRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;
    final accent = record.isWin ? AppColors.good : AppColors.danger;
    final noteKey = ctoNoteStringKey(record.ctoNote);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  record.isWin ? AppIcons.unicorn : Icons.dangerous_outlined,
                  size: AppDimens.iconSm,
                  color: accent,
                ),
                const SizedBox(width: AppDimens.gapXs),
                Text(
                  record.isWin
                      ? strings[StringKey.logOutcomeWin]
                      : strings[StringKey.logOutcomeLoss],
                  style: textTheme.titleSmall?.copyWith(color: accent),
                ),
                const Spacer(),
                Text(formatDate(record.playedAt), style: textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: AppDimens.gapSm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.format(StringKey.logRecordWeeks, {
                      'weeks': '${record.weeksSurvived}',
                    }),
                    style: textTheme.bodySmall,
                  ),
                ),
                Text(
                  formatMoney(record.finalValuation),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
            Text(
              strings.format(StringKey.logRecordCrises, {
                'count': '${record.resolvedCrises}',
              }),
              style: textTheme.bodySmall,
            ),
            // CTO notu: kayıtta anahtar olarak saklandığı için dil
            // değişince de doğru dilde görünüyor.
            if (noteKey != null) ...[
              const SizedBox(height: AppDimens.gapMd),
              Container(
                padding: const EdgeInsets.all(AppDimens.gapMd),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings[StringKey.gameOverCtoNoteLabel].toUpperCase(),
                      style: textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppDimens.gapXs),
                    Text(strings[noteKey], style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
