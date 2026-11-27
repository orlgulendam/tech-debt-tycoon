import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Tek bir metriği gösteren küçük kutu.
///
/// Değer rengi duruma göre değişir (bkz. [AppColors.forTechDebt] vb.), böylece
/// oyuncu sayıyı okumadan da iyi/kötü ayrımını görebilir.
class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
    this.onTap,
  });

  /// Metriğin ikonu.
  final IconData icon;

  /// Metriğin adı (`l10n`'dan gelir).
  final String label;

  /// Biçimlendirilmiş değer (bkz. `lib/l10n/formatters.dart`).
  final String value;

  /// Değerin rengi. Verilmezse ana metin rengi kullanılır.
  final Color? valueColor;

  /// Dokunulabilir yapmak için.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.gapSm,
          vertical: AppDimens.gapSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: AppDimens.iconSm, color: AppColors.textMuted),
                const SizedBox(width: AppDimens.gapXs),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapXs),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontFeatures: AppTypography.tabularFigures,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
