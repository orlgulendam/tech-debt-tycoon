import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import 'metric_tile.dart';
import 'pulse.dart';
import 'stat_bar.dart';
import 'unicorn_progress.dart';

/// Oyunun durum paneli: değerleme ilerlemesi, nakit metrikleri ve
/// yüzdelik çubuklar.
///
/// Ofis ve Ekip ekranlarının üstünde duruyor. Tek elle oynanabilirlik
/// kuralı gereği burada dokunulabilir bir şey yok; bütün eylemler ekranın
/// alt yarısında.
class ResourceHeader extends ConsumerWidget {
  const ResourceHeader({required this.state, super.key});

  /// O anki oyun durumu.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UnicornProgress(state: state),
            const Divider(height: AppDimens.gapLg),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.budget,
                    label: strings[StringKey.metricBudget],
                    value: formatMoney(state.budget),
                    animatedValue: state.budget,
                    format: formatMoney,
                    valueColor: AppColors.forBudget(state.budget),
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.revenue,
                    label: strings[StringKey.metricWeeklyRevenueShort],
                    value: formatMoney(state.weeklyRevenue),
                    animatedValue: state.weeklyRevenue,
                    format: formatMoney,
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    icon: AppIcons.team,
                    label: strings[StringKey.metricTeamSize],
                    value: '${state.team.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapSm),
            // Net nakit akışı: oyuncunun en çok gözden kaçırdığı sayı.
            // Negatifse kırmızı görünsün ki maaş yükü fark edilsin.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      strings[StringKey.metricNetCashFlow],
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Text(
                    formatSignedMoney(state.netWeeklyCashFlow),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.forDelta(state.netWeeklyCashFlow),
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.gapMd),
            // Kritik seviyede nabız atıyor: oyuncu ekrana bakmasa bile
            // köşesinde bir şeyin yanıp söndüğünü fark etsin.
            Pulse(
              active: state.techDebt >= 80,
              child: StatBar(
                label: strings[StringKey.metricTechDebt],
                value: state.techDebt,
                color: AppColors.forTechDebt(state.techDebt),
                icon: AppIcons.techDebt,
                thresholdPercent: GameState.highTechDebtThreshold,
                inverted: true,
              ),
            ),
            const SizedBox(height: AppDimens.gapMd),
            Pulse(
              active: state.isMoraleCritical,
              child: StatBar(
                label: strings[StringKey.metricTeamMorale],
                value: state.teamMorale,
                color: AppColors.forMorale(state.teamMorale),
                icon: AppIcons.morale,
                thresholdPercent: GameState.lowMoraleThreshold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
