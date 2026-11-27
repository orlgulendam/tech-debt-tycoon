import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../providers/providers.dart';
import '../../services/ad_service.dart';
import '../../theme/theme.dart';
import 'ad_sheet.dart';
import 'sheet_scaffold.dart';

/// Danışman ipucu sheet'i.
///
/// Ücretsiz hak varsa ipucunu doğrudan gösterir ve bir hak harcar. Hak
/// bittiyse ipucunu gizler ve reklam izleyip danışman tutmayı teklif eder.
class HintSheet extends ConsumerStatefulWidget {
  const HintSheet({super.key});

  @override
  ConsumerState<HintSheet> createState() => _HintSheetState();
}

class _HintSheetState extends ConsumerState<HintSheet> {
  /// Bu sheet açıkken ipucu hakkı harcandı mı?
  ///
  /// Hak harcama sheet açılırken değil oyuncu "danışmana sor"a bastığında
  /// olur; böylece yanlışlıkla açıp kapatmak hak yakmaz.
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final hint = ref.watch(currentHintProvider);
    final remaining = ref.watch(remainingHintsProvider);
    final textTheme = Theme.of(context).textTheme;

    final accent = hint.isUrgent ? AppColors.danger : AppColors.good;

    return SheetScaffold(
      title: strings[StringKey.hintSheetTitle],
      icon: AppIcons.hint,
      accentColor: accent,
      footer: _buildFooter(strings, remaining),
      children: [
        if (!_revealed)
          Text(
            remaining > 0
                ? strings.format(StringKey.hintFreeRemaining, {
                    'count': '$remaining',
                  })
                : strings[StringKey.hintNoFreeLeft],
            style: textTheme.bodySmall,
          )
        else ...[
          Row(
            children: [
              Icon(
                AppIcons.forHintMetric(hint.metric),
                size: AppDimens.iconSm,
                color: accent,
              ),
              const SizedBox(width: AppDimens.gapXs),
              Text(
                '${strings[StringKey.hintMetricLabel]}: '
                '${strings[hint.metric.labelKey]}',
                style: textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapMd),
          Text(strings[StringKey.hintAdviceLabel], style: textTheme.labelSmall),
          const SizedBox(height: AppDimens.gapXs),
          Text(
            hint.advice,
            style: textTheme.bodyMedium?.copyWith(color: accent),
          ),
          const SizedBox(height: AppDimens.gapMd),
          Text(strings[StringKey.hintReasonLabel], style: textTheme.labelSmall),
          const SizedBox(height: AppDimens.gapXs),
          Text(hint.reasoning, style: textTheme.bodySmall),
          const SizedBox(height: AppDimens.gapMd),
          Text(
            strings.format(StringKey.hintFreeRemaining, {
              'count': '$remaining',
            }),
            style: textTheme.labelSmall,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(AppStrings strings, int remaining) {
    if (_revealed) {
      return FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(strings[StringKey.commonClose]),
      );
    }

    if (remaining > 0) {
      return FilledButton.icon(
        onPressed: _askAdvisor,
        icon: const Icon(AppIcons.hint, size: AppDimens.iconSm),
        label: Text(strings[StringKey.hintAskButton]),
      );
    }

    return Column(
      children: [
        FilledButton.icon(
          onPressed: _watchAd,
          icon: const Icon(AppIcons.ad, size: AppDimens.iconSm),
          label: Text(strings[StringKey.hintWatchAdButton]),
        ),
        const SizedBox(height: AppDimens.gapSm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings[StringKey.commonClose]),
        ),
      ],
    );
  }

  /// Bir ipucu hakkı harcayıp tavsiyeyi açar.
  void _askAdvisor() {
    final used = ref.read(gameControllerProvider.notifier).useHint();
    if (used) setState(() => _revealed = true);
  }

  /// Reklam izleyip danışman tutar; başarılıysa ipucunu açar.
  Future<void> _watchAd() async {
    final outcome = await showAdSheet(context);
    if (!mounted) return;

    if (outcome == AdOutcome.rewarded) {
      _askAdvisor();
    }
  }
}

/// İpucu sheet'ini açar.
Future<void> showHintSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    builder: (context) => const HintSheet(),
  );
}
