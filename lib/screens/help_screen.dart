import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// "Nasıl Oynanır" ekranı.
///
/// Onboarding üç cümlede oyuna sokuyor; bu ekran ise oyun sırasında
/// başvurulacak tam kılavuz. Deponun içindeki
/// `docs/KULLANIM_KILAVUZU.md` ile aynı bilgiyi anlatıyor ama oyuncunun
/// telefonundan çıkmadan okunabiliyor.
///
/// Metinler l10n'dan geliyor; kaynak açıklamalarının yanında gerçek
/// eşik değerleri [GameState] sabitlerinden okunuyor, böylece denge
/// değişirse kılavuz yalan söylemiyor.
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings[StringKey.helpTitle]),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          _Block(
            icon: AppIcons.unicorn,
            color: AppColors.good,
            title: strings[StringKey.helpGoalTitle],
            body: strings[StringKey.helpGoalBody],
          ),

          SectionLabel(strings[StringKey.helpResourcesTitle]),
          _Block(
            icon: AppIcons.budget,
            color: AppColors.good,
            title: strings[StringKey.metricBudget],
            body: strings[StringKey.helpBudgetBody],
          ),
          _Block(
            icon: AppIcons.valuation,
            color: AppColors.info,
            title: strings[StringKey.metricValuation],
            body: strings[StringKey.helpValuationBody],
          ),
          _Block(
            icon: AppIcons.revenue,
            color: AppColors.info,
            title: strings[StringKey.metricWeeklyRevenue],
            body: strings[StringKey.helpRevenueBody],
          ),
          _Block(
            icon: AppIcons.techDebt,
            color: AppColors.warning,
            title: strings[StringKey.metricTechDebt],
            body: strings[StringKey.helpTechDebtBody],
          ),
          _Block(
            icon: AppIcons.morale,
            color: AppColors.danger,
            title: strings[StringKey.metricTeamMorale],
            body: strings[StringKey.helpMoraleBody],
          ),

          SectionLabel(strings[StringKey.helpActionsTitle]),
          _Block(
            icon: Icons.bolt_outlined,
            color: AppColors.good,
            title: strings[StringKey.helpActionsTitle],
            body: strings[StringKey.helpActionsBody],
          ),
          // Aksiyonların gerçek sayıları: kılavuzda tekrar yazmak yerine
          // veri katmanından okuyoruz ki denge değişince burası da
          // kendiliğinden güncellensin.
          ...ref
              .watch(contentProvider)
              .actions
              .map((action) => _ActionLine(action: action)),

          const SizedBox(height: AppDimens.gapLg),
          SectionLabel(strings[StringKey.helpEventsTitle]),
          _Block(
            icon: Icons.priority_high,
            color: AppColors.warning,
            title: strings[StringKey.helpEventsTitle],
            body: strings[StringKey.helpEventsBody],
          ),

          SectionLabel(strings[StringKey.helpHintsTitle]),
          _Block(
            icon: AppIcons.hint,
            color: AppColors.good,
            title: strings[StringKey.helpHintsTitle],
            body: strings[StringKey.helpHintsBody],
          ),

          SectionLabel(strings[StringKey.helpStrategyTitle]),
          _Block(
            icon: Icons.insights_outlined,
            color: AppColors.good,
            title: strings[StringKey.helpStrategyTitle],
            body: strings[StringKey.helpStrategyBody],
          ),

          SectionLabel(strings[StringKey.helpLoseTitle]),
          _LoseRow(
            icon: AppIcons.budget,
            text: strings[StringKey.lossReasonBankruptcy],
          ),
          _LoseRow(
            icon: AppIcons.techDebt,
            text: strings[StringKey.lossReasonServerMeltdown],
          ),
          _LoseRow(
            icon: AppIcons.morale,
            text: strings[StringKey.lossReasonMassResignation],
          ),
          const SizedBox(height: AppDimens.gapLg),
        ],
      ),
    );
  }
}

/// Başlıklı açıklama bloğu.
class _Block extends StatelessWidget {
  const _Block({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapMd),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: AppDimens.iconSm, color: color),
                  const SizedBox(width: AppDimens.gapSm),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.gapSm),
              Text(body, style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kılavuzdaki tek aksiyon satırı: adı ve gerçek etkileri.
class _ActionLine extends StatelessWidget {
  const _ActionLine({required this.action});

  final GameAction action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.forId(action.iconId),
            size: AppDimens.iconSm,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppDimens.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.name, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                EffectSummary(action.effect),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kaybetme yolu satırı.
class _LoseRow extends StatelessWidget {
  const _LoseRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimens.iconSm, color: AppColors.danger),
          const SizedBox(width: AppDimens.gapSm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
