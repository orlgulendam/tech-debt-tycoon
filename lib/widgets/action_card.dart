import 'package:material_ui/material_ui.dart';

import '../models/models.dart';
import '../theme/theme.dart';
import 'effect_summary.dart';

/// Haftalık aksiyon kartı.
///
/// Tek elle oynanabilirlik için kart bütünüyle dokunulabilir ve en az
/// [AppDimens.minTouchTarget] yüksekliğinde. Bütçe yetmediğinde kart
/// kilitlenir ve nedeni [lockedReason] ile yazılır — buton sessizce
/// çalışmamazlık etmesin.
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.action,
    required this.onTap,
    super.key,
    this.cost,
    this.lockedReason,
    this.highlighted = false,
  });

  /// Gösterilecek aksiyon.
  final GameAction action;

  /// Karta dokunulduğunda. Kart kilitliyse çağrılmaz.
  final VoidCallback onTap;

  /// Tek seferlik nakit maliyeti (pozitif, `0` ise gösterilmez).
  final int? cost;

  /// Doluysa kart kilitlidir ve bu metin gösterilir.
  final String? lockedReason;

  /// `true` ise kart vurgulanır (danışmanın önerdiği aksiyon).
  final bool highlighted;

  bool get _locked => lockedReason != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = highlighted ? AppColors.good : AppColors.border;

    return Opacity(
      opacity: _locked ? 0.55 : 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: BorderSide(color: accent, width: highlighted ? 1.5 : 1),
        ),
        child: InkWell(
          onTap: _locked ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.forId(action.iconId),
                      size: AppDimens.iconMd,
                      color: highlighted
                          ? AppColors.good
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimens.gapMd),
                    Expanded(
                      child: Text(action.name, style: textTheme.titleSmall),
                    ),
                    if (highlighted)
                      Icon(
                        AppIcons.hint,
                        size: AppDimens.iconSm,
                        color: AppColors.good,
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.gapSm),
                Text(action.description, style: textTheme.bodySmall),
                const SizedBox(height: AppDimens.gapMd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: EffectSummary(action.effect)),
                    if (action.requiresHireSelection)
                      Icon(
                        Icons.chevron_right,
                        size: AppDimens.iconMd,
                        color: AppColors.textMuted,
                      ),
                  ],
                ),
                if (_locked) ...[
                  const SizedBox(height: AppDimens.gapSm),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 13,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: AppDimens.gapXs),
                      Expanded(
                        child: Text(
                          lockedReason!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
