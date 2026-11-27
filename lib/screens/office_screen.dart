import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/game_engine.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Ofis: oyunun ana ekranı.
///
/// Yerleşim tek elle oynanabilirlik için düşünüldü — üstte okunacak şeyler
/// (metrikler, durum yorumu), altta dokunulacak şeyler (aksiyon kartları).
/// Başparmak hep ekranın alt yarısında kalıyor.
class OfficeScreen extends ConsumerWidget {
  const OfficeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final state = ref.watch(gameControllerProvider);
    final content = ref.watch(contentProvider);
    final hint = ref.watch(currentHintProvider);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        ResourceHeader(state: state),
        const SizedBox(height: AppDimens.gapLg),

        if (!state.isPlaying)
          GameOverCard(state: state)
        else ...[
          // Durum yorumu: o anki duruma en uygun karakter konuşuyor.
          _StatusComment(state: state, characters: content.characters),
          const SizedBox(height: AppDimens.gapLg),

          _AdvisorRow(hint: hint),
          const SizedBox(height: AppDimens.gapLg),

          SectionLabel(
            strings[StringKey.officeActionsSectionTitle],
            trailing: Text(
              strings.format(StringKey.officeWeekLabel, {
                'week': '${state.week}',
              }),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Text(
            strings[StringKey.officeChooseAction],
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.gapMd),

          for (final action in content.actions) ...[
            ActionCard(
              action: action,
              highlighted: hint.suggestedActionId == action.id,
              cost: GameEngine.actionCost(action),
              lockedReason: _lockedReason(strings, state, action),
              onTap: () => _onAction(context, ref, action),
            ),
            const SizedBox(height: AppDimens.gapMd),
          ],
        ],
      ],
    );
  }

  /// Aksiyon bütçe yüzünden kilitliyse gösterilecek metin.
  ///
  /// İşe alım aksiyonu hiç kilitlenmez: adaylardan en az biri uygun
  /// olabilir, karar sheet içinde veriliyor.
  String? _lockedReason(
    AppStrings strings,
    GameState state,
    GameAction action,
  ) {
    if (action.requiresHireSelection) return null;
    if (GameEngine.canAfford(state, action)) return null;
    return strings[StringKey.teamInsufficientBudget];
  }

  /// Aksiyona dokunulduğunda.
  ///
  /// İşe alım önce aday seçimi sheet'i açar; diğerleri doğrudan sprint
  /// oynatır. Her iki yolda da sprint sonunda olay kartı çıkmışsa karar
  /// sheet'i açılır.
  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    GameAction action,
  ) async {
    final controller = ref.read(gameControllerProvider.notifier);

    final SprintResult? result;
    if (action.requiresHireSelection) {
      result = await showHireSheet(context);
    } else {
      result = controller.playSprint(action);
    }

    if (!context.mounted) return;

    final event = result?.triggeredEvent;
    if (event != null) {
      await showEventSheet(context, event);
    }
  }
}

/// O anki duruma uygun karakter yorumu.
///
/// Hangi karakterin konuşacağı duruma göre seçiliyor: teknik borç
/// yüksekken Zeynep, moral düşükken Elif, bütçe kritikken Mert. Oyunun
/// anlatı sesi böyle oluşuyor.
class _StatusComment extends StatelessWidget {
  const _StatusComment({required this.state, required this.characters});

  final GameState state;
  final List<Character> characters;

  @override
  Widget build(BuildContext context) {
    final (situation, speakerId) = _pickSituation();
    final character = _byId(speakerId);
    final line = character?.dialogueAt(situation, state.week);
    if (line == null) return const SizedBox.shrink();

    return CharacterBubble(
      character: character,
      line: line,
      accentColor: _accentFor(situation),
    );
  }

  /// Duruma göre (konu, konuşan) seçer.
  ///
  /// Sıra önemli: en kritik durum konuşur. Hiçbiri kritik değilse iyi
  /// hafta repliği gelir.
  (DialogueSituation, String) _pickSituation() {
    if (state.week == 1) return (DialogueSituation.gameStart, 'mert');
    if (state.isTechDebtCritical) {
      return (DialogueSituation.highTechDebt, 'zeynep');
    }
    if (state.isMoraleCritical) return (DialogueSituation.lowMorale, 'elif');
    if (state.isBudgetCritical) return (DialogueSituation.lowBudget, 'mert');
    return (DialogueSituation.goodWeek, _rotatingSpeaker());
  }

  /// İyi haftalarda karakterler sırayla konuşsun; hep aynı kişi
  /// konuşursa anlatı tekdüze olur.
  String _rotatingSpeaker() {
    const speakers = ['can', 'elif', 'zeynep', 'mert'];
    return speakers[state.week % speakers.length];
  }

  Color _accentFor(DialogueSituation situation) => switch (situation) {
    DialogueSituation.highTechDebt => AppColors.warning,
    DialogueSituation.lowMorale => AppColors.danger,
    DialogueSituation.lowBudget => AppColors.warning,
    _ => AppColors.info,
  };

  Character? _byId(String id) {
    for (final character in characters) {
      if (character.id == id) return character;
    }
    return characters.isEmpty ? null : characters.first;
  }
}

/// Danışman satırı: ipucunun başlığı ve sorma butonu.
///
/// İpucunun kendisi burada gösterilmiyor — hak harcandığında sheet
/// içinde açılıyor. Burada yalnızca "danışman bir şey söylemek istiyor"
/// sinyali var; aciliyet yüksekse renk değişiyor.
class _AdvisorRow extends ConsumerWidget {
  const _AdvisorRow({required this.hint});

  final HintResult hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final remaining = ref.watch(remainingHintsProvider);
    final accent = hint.isUrgent ? AppColors.danger : AppColors.good;

    return Card(
      child: InkWell(
        onTap: () => showHintSheet(context),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          child: Row(
            children: [
              Icon(AppIcons.hint, color: accent, size: AppDimens.iconMd),
              const SizedBox(width: AppDimens.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings[StringKey.officeAdvisorSectionTitle],
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      remaining > 0
                          ? strings.format(StringKey.hintFreeRemaining, {
                              'count': '$remaining',
                            })
                          : strings[StringKey.hintNoFreeLeft],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (hint.isUrgent)
                const Icon(
                  Icons.priority_high,
                  color: AppColors.danger,
                  size: AppDimens.iconMd,
                ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: AppDimens.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
