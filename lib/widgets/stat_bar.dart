import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme/theme.dart';

/// Yüzdelik bir metriği çubukla gösterir (teknik borç, ekip morali).
///
/// Çubuğun rengi değere göre değişir; eşik varsa çubuk üstünde ince bir
/// işaretle gösterilir — oyuncu "ne zaman tehlikeye girerim" sorusunu
/// sayı okumadan görebilsin diye.
class StatBar extends StatelessWidget {
  const StatBar({
    required this.label,
    required this.value,
    required this.color,
    super.key,
    this.icon,
    this.thresholdPercent,
    this.inverted = false,
  });

  /// Metriğin adı (`l10n`'dan gelir).
  final String label;

  /// Değer (0-100).
  final int value;

  /// Çubuğun ve sayının rengi.
  final Color color;

  /// İsteğe bağlı ikon.
  final IconData? icon;

  /// Tehlike eşiği (0-100). Verilirse çubuk üstünde işaretlenir.
  final int? thresholdPercent;

  /// `true` ise yüksek değer kötüdür (teknik borç).
  ///
  /// Şu an yalnızca anlam belirtmek için; renk kararı çağırana ait.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppDimens.iconSm, color: AppColors.textMuted),
              const SizedBox(width: AppDimens.gapXs),
            ],
            Expanded(child: Text(label, style: textTheme.labelSmall)),
            Text(
              formatPercent(value),
              style: textTheme.titleSmall?.copyWith(
                color: color,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.gapXs),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimens.progressHeight / 2,
                  ),
                  child: LinearProgressIndicator(
                    value: (value / 100).clamp(0.0, 1.0),
                    color: color,
                    backgroundColor: AppColors.surfaceAlt,
                    minHeight: AppDimens.progressHeight,
                  ),
                ),
                if (thresholdPercent != null)
                  Positioned(
                    left:
                        constraints.maxWidth *
                        (thresholdPercent!.clamp(0, 100) / 100),
                    child: Container(
                      width: 2,
                      height: AppDimens.progressHeight,
                      color: AppColors.background,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
