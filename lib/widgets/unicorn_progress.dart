import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import 'animated_counter.dart';

/// Unicorn hedefine ilerleme çubuğu.
///
/// Oyunun tek uzun vadeli hedefi bu; ekranın en üstünde duruyor ki oyuncu
/// her hafta nereye doğru gittiğini görsün.
class UnicornProgress extends ConsumerWidget {
  const UnicornProgress({required this.state, super.key});

  /// O anki oyun durumu.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;
    final remaining = GameState.winValuation - state.valuation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              AppIcons.unicorn,
              size: AppDimens.iconSm,
              color: AppColors.good,
            ),
            const SizedBox(width: AppDimens.gapXs),
            Expanded(
              child: AnimatedCounter(
                value: state.valuation,
                format: formatMoney,
                style: textTheme.titleMedium,
              ),
            ),
            Text(
              remaining > 0
                  ? strings.format(StringKey.officeUnicornProgress, {
                      'remaining': formatCompactMoney(remaining),
                    })
                  : strings[StringKey.logOutcomeWin],
              style: textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.gapSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.progressHeight / 2),
          // İlerleme çubuğu da hedefe doğru akarak gidiyor; birden
          // sıçraması kazanılan mesafeyi görünmez kılıyordu.
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: state.unicornProgress),
            duration: AppMotion.counter,
            curve: AppMotion.enter,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              color: AppColors.good,
              backgroundColor: AppColors.surfaceAlt,
              minHeight: AppDimens.progressHeight,
            ),
          ),
        ),
      ],
    );
  }
}
