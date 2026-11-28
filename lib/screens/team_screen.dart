import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Ekip sekmesi: kadro ve işe alım.
///
/// Oyuncu burada kimin ne kazandırdığını ve ne kadar borç ürettiğini
/// görür. İşe alım buradan da yapılabilir (ofisteki aksiyon kartıyla aynı
/// sprint'i oynatır), çünkü oyuncunun "ekip" ekranında işe alım araması
/// doğal bir refleks.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final state = ref.watch(gameControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        _TeamSummary(state: state),
        const SizedBox(height: AppDimens.gapLg),

        SectionLabel(
          strings[StringKey.teamRosterSectionTitle],
          trailing: Text(
            '${state.team.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),

        if (!state.hasTeam)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    color: AppColors.textMuted,
                    size: AppDimens.iconMd,
                  ),
                  const SizedBox(width: AppDimens.gapMd),
                  Expanded(
                    child: Text(
                      strings[StringKey.teamEmptyMessage],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final employee in state.team) ...[
            EmployeeCard(employee: employee),
            const SizedBox(height: AppDimens.gapMd),
          ],

        const SizedBox(height: AppDimens.gapMd),

        // Oyun bittiyse işe alım teklif etmek anlamsız.
        if (state.isPlaying) ...[
          SectionLabel(strings[StringKey.teamHireSectionTitle]),
          FilledButton.icon(
            onPressed: state.hasPendingEvent
                ? null
                : () => _openHireSheet(context, ref),
            icon: const Icon(Icons.person_add_alt, size: AppDimens.iconSm),
            label: Text(strings[StringKey.teamHireButton]),
          ),
        ],
      ],
    );
  }

  /// İşe alım sheet'ini açar.
  ///
  /// Ofisteki akışın aynısı: işe alım da bir sprint oynatıyor, dolayısıyla
  /// hafta kapanış özeti ve (varsa) olay kartı burada da gösterilmeli.
  Future<void> _openHireSheet(BuildContext context, WidgetRef ref) async {
    final result = await showHireSheet(context);
    if (result == null || !context.mounted) return;

    if (!result.isGameOver) {
      await showSprintResultSheet(context, result);
      if (!context.mounted) return;
    }

    final event = result.triggeredEvent;
    if (event != null) {
      await showEventSheet(context, event);
    }
  }
}

/// Ekibin toplu maliyeti ve katkısı.
class _TeamSummary extends ConsumerWidget {
  const _TeamSummary({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.revenue,
                    label: strings[StringKey.teamRevenueLabel],
                    value: formatMoney(state.totalTeamRevenue),
                    valueColor: AppColors.good,
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.budget,
                    label: strings[StringKey.teamSalaryLabel],
                    value: formatMoney(state.totalSalaries),
                    valueColor: state.totalSalaries > 0
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: AppDimens.gapLg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings[StringKey.metricNetCashFlow],
                    style: textTheme.titleSmall,
                  ),
                ),
                Text(
                  formatSignedMoney(state.netWeeklyCashFlow),
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.forDelta(state.netWeeklyCashFlow),
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapMd),
            // Ekibin pasif borç/moral etkisi: işe alım kararının görünmeyen
            // tarafı. Oyuncu junior yığdığında borcun neden arttığını
            // burada görüyor.
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings[StringKey.teamPassiveEffectLabel],
                    style: textTheme.bodySmall,
                  ),
                ),
                EffectSummary(state.teamDebtMoraleEffect),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
