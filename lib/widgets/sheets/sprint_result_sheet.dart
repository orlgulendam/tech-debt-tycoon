import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';
import '../effect_summary.dart';
import 'sheet_scaffold.dart';

/// Bir haftanın kapanış özeti.
///
/// Oyunun ritmini bu panel veriyor: oyuncu aksiyonu seçiyor, hafta
/// kapanıyor ve ne olduğunu burada **satır satır** görüyor. Öncesinde
/// sayılar sessizce değişiyordu; neyin neden değiştiği anlaşılmıyordu.
///
/// Satırlar sırayla beliriyor (stagger). Bu süsleme değil: para girişi,
/// değerleme büyümesi ve borç artışı ayrı ayrı okunsun diye. Hepsi aynı
/// anda gelse göz tek bir blok görür.
class SprintResultSheet extends ConsumerStatefulWidget {
  const SprintResultSheet({required this.result, super.key});

  /// Kapanan haftanın sonucu.
  final SprintResult result;

  @override
  ConsumerState<SprintResultSheet> createState() => _SprintResultSheetState();
}

class _SprintResultSheetState extends ConsumerState<SprintResultSheet> {
  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;
    final result = widget.result;
    final hired = result.hiredEmployee;

    // Gösterilecek satırlar. Boş olanlar hiç eklenmiyor: sıfır dolu bir
    // liste okunmuyor.
    final rows = <Widget>[
      _ResultRow(
        label: strings[StringKey.sprintResultActionLabel],
        valueText: result.action.name,
        icon: AppIcons.forId(result.action.iconId),
        color: AppColors.textPrimary,
      ),
      if (hired != null)
        _ResultRow(
          label: strings.format(StringKey.sprintResultHired, {
            'name': hired.name,
          }),
          valueText: '',
          icon: Icons.person_add_alt,
          color: AppColors.good,
        ),
      _ResultRow(
        label: strings[StringKey.sprintResultRevenue],
        valueText: formatSignedMoney(result.revenueCollected),
        icon: AppIcons.revenue,
        color: AppColors.forDelta(result.revenueCollected),
      ),
      _ResultRow(
        label: strings[StringKey.sprintResultValuationGrowth],
        valueText: formatSignedMoney(result.valuationGrowth),
        icon: AppIcons.valuation,
        color: AppColors.forDelta(result.valuationGrowth),
      ),
      if (!result.actionEffect.isEmpty)
        _ResultRow(
          label: strings[StringKey.sprintResultActionEffect],
          icon: Icons.bolt_outlined,
          color: AppColors.textSecondary,
          trailing: EffectSummary(result.actionEffect),
        ),
      if (!result.teamEffect.isEmpty)
        _ResultRow(
          label: strings[StringKey.sprintResultTeamEffect],
          icon: AppIcons.team,
          color: AppColors.textSecondary,
          trailing: EffectSummary(result.teamEffect),
        ),
      if (!result.debtEffect.isEmpty)
        _ResultRow(
          label: strings[StringKey.sprintResultDebtDrift],
          icon: AppIcons.techDebt,
          color: AppColors.textSecondary,
          trailing: EffectSummary(result.debtEffect),
        ),
    ];

    return SheetScaffold(
      title: strings.format(StringKey.sprintResultTitle, {
        'week': '${result.previousState.week}',
      }),
      icon: Icons.task_alt,
      accentColor: AppColors.good,
      footer: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          result.triggeredEvent != null
              ? strings[StringKey.eventContinueButton]
              : strings[StringKey.sprintResultContinue],
        ),
      ),
      children: [
        for (var i = 0; i < rows.length; i++)
          _Staggered(index: i, child: rows[i]),
        const SizedBox(height: AppDimens.gapMd),
        _Staggered(
          index: rows.length,
          child: Row(
            children: [
              Icon(
                result.triggeredEvent != null
                    ? Icons.priority_high
                    : Icons.nightlight_outlined,
                size: AppDimens.iconSm,
                color: result.triggeredEvent != null
                    ? AppColors.warning
                    : AppColors.textMuted,
              ),
              const SizedBox(width: AppDimens.gapXs),
              Expanded(
                child: Text(
                  result.triggeredEvent != null
                      ? strings[StringKey.sprintResultEventIncoming]
                      : strings[StringKey.sprintResultCalmWeek],
                  style: textTheme.bodySmall?.copyWith(
                    color: result.triggeredEvent != null
                        ? AppColors.warning
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gapSm),
      ],
    );
  }
}

/// Satırı sırası geldiğinde aşağıdan yukarı kaydırarak gösterir.
class _Staggered extends StatefulWidget {
  const _Staggered({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Staggered> createState() => _StaggeredState();
}

class _StaggeredState extends State<_Staggered>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppMotion.staggerStep * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: AppMotion.enter);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Özet panelindeki tek satır.
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.icon,
    required this.color,
    this.valueText,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String? valueText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.gapSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.iconSm, color: AppColors.textMuted),
          const SizedBox(width: AppDimens.gapSm),
          Expanded(child: Text(label, style: textTheme.bodySmall)),
          if (trailing != null)
            trailing!
          else if (valueText != null && valueText!.isNotEmpty)
            Text(
              valueText!,
              style: textTheme.titleSmall?.copyWith(
                color: color,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
        ],
      ),
    );
  }
}

/// Sprint sonucu panelini açar.
Future<void> showSprintResultSheet(BuildContext context, SprintResult result) {
  return showAppSheet<void>(
    context: context,
    builder: (context) => SprintResultSheet(result: result),
  );
}
