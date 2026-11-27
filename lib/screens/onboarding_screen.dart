import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';

/// Üç adımlı tanıtım.
///
/// Oyun ilk açılışta bir kez gösterilir, sonra kayda işlenir. Amaç kuralları
/// ezberletmek değil üç şeyi anlatmak: ne olduğun (CTO), neyin bedeli olduğu
/// (teknik borç) ve hedefin ne olduğu (1.000.000$).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  /// Tanıtım adımları: (başlık, gövde, ikon, renk).
  static const List<_Step> _steps = [
    _Step(
      titleKey: StringKey.onboardingStep1Title,
      bodyKey: StringKey.onboardingStep1Body,
      icon: Icons.terminal,
      color: AppColors.info,
    ),
    _Step(
      titleKey: StringKey.onboardingStep2Title,
      bodyKey: StringKey.onboardingStep2Body,
      icon: AppIcons.techDebt,
      color: AppColors.warning,
    ),
    _Step(
      titleKey: StringKey.onboardingStep3Title,
      bodyKey: StringKey.onboardingStep3Body,
      icon: AppIcons.unicorn,
      color: AppColors.good,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _steps.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() => ref.read(onboardingProvider.notifier).complete();

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Atla: oyuncu tanıtımı okumak zorunda değil.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.gapSm),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(strings[StringKey.onboardingSkip]),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.gapXl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: step.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusCard,
                            ),
                            border: Border.all(
                              color: step.color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(step.icon, size: 44, color: step.color),
                        ),
                        const SizedBox(height: AppDimens.gapXl),
                        Text(
                          strings[step.titleKey],
                          style: textTheme.headlineSmall?.copyWith(
                            color: step.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimens.gapMd),
                        Text(
                          strings[step.bodyKey],
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Sayfa göstergesi.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _steps.length; i++)
                  Container(
                    width: i == _page ? 20 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.good : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.gapLg),

            Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: FilledButton(
                onPressed: _next,
                child: Text(
                  _isLast
                      ? strings[StringKey.onboardingStart]
                      : strings[StringKey.onboardingNext],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir tanıtım adımı.
class _Step {
  const _Step({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.color,
  });

  final StringKey titleKey;
  final StringKey bodyKey;
  final IconData icon;
  final Color color;
}
