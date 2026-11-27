import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';

/// Bir çalışanı ya da işe alım adayını gösteren kart.
///
/// Hem ekip kadrosunda (mevcut çalışan) hem işe alım sayfasında (aday)
/// kullanılır; fark [onHire] ve [hiringCost] verilip verilmemesinde.
class EmployeeCard extends ConsumerWidget {
  const EmployeeCard({
    required this.employee,
    super.key,
    this.onHire,
    this.hireCost,
    this.affordable = true,
  });

  /// Gösterilecek çalışan ya da aday.
  final Employee employee;

  /// Doluysa kart bir "işe al" butonu gösterir.
  final VoidCallback? onHire;

  /// İşe alımın tek seferlik maliyeti ($).
  final int? hireCost;

  /// Bütçe bu adaya yetiyor mu?
  final bool affordable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    AppIcons.forId(employee.iconId),
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimens.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.name, style: textTheme.titleSmall),
                      Text(
                        strings[employee.level.labelKey],
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapMd),
            _StatLine(
              label: strings[StringKey.teamSalaryLabel],
              value: '-${formatMoney(employee.weeklySalary)}',
              color: AppColors.danger,
            ),
            _StatLine(
              label: strings[StringKey.teamRevenueLabel],
              value: '+${formatMoney(employee.revenueContribution)}',
              color: AppColors.good,
            ),
            _StatLine(
              label: strings[StringKey.teamDebtEffectLabel],
              value: formatSignedPercent(employee.techDebtEffect),
              color: AppColors.forDelta(
                employee.techDebtEffect,
                inverted: true,
              ),
            ),
            _StatLine(
              label: strings[StringKey.teamMoraleEffectLabel],
              value: formatSignedPercent(employee.moraleEffect),
              color: AppColors.forDelta(employee.moraleEffect),
            ),
            const Divider(height: AppDimens.gapLg),
            _StatLine(
              label: strings[StringKey.teamNetValueLabel],
              value: formatSignedMoney(employee.netWeeklyValue),
              color: AppColors.forDelta(employee.netWeeklyValue),
              emphasized: true,
            ),
            if (onHire != null) ...[
              const SizedBox(height: AppDimens.gapMd),
              FilledButton(
                onPressed: affordable ? onHire : null,
                child: Text(
                  hireCost == null
                      ? strings[StringKey.teamHireButton]
                      : '${strings[StringKey.teamHireButton]} · '
                            '${formatMoney(hireCost!)}',
                ),
              ),
              if (!affordable)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimens.gapSm),
                  child: Text(
                    strings[StringKey.teamInsufficientBudget],
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kart içindeki etiket/değer satırı.
class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    required this.color,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized ? textTheme.titleSmall : textTheme.bodySmall,
            ),
          ),
          Text(
            value,
            style: (emphasized ? textTheme.titleSmall : textTheme.bodySmall)
                ?.copyWith(
                  color: color,
                  fontFeatures: AppTypography.tabularFigures,
                ),
          ),
        ],
      ),
    );
  }
}
