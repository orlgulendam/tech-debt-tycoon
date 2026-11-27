import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import 'character_bubble.dart';
import 'section_label.dart';

/// Oyun sonu kartı: skor özeti ve kapanış repliği.
///
/// Bottom sheet değil, ofis ekranının içinde duran bir kart. Nedeni:
/// oyun bittiğinde geriye dönülecek bir "oyun" kalmıyor, dolayısıyla
/// kapatılabilir bir katman göstermek yanıltıcı olurdu. Oyuncunun tek
/// yolu yeni oyun başlatmak.
///
/// Zengin skor kartı (paylaşılabilir görsel) Aşama 4'te gelecek.
class GameOverCard extends ConsumerWidget {
  const GameOverCard({required this.state, super.key});

  /// Bitmiş oyunun durumu.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final characters = ref.watch(contentProvider).characters;
    final textTheme = Theme.of(context).textTheme;
    final won = state.status == GameStatus.won;
    final accent = won ? AppColors.good : AppColors.danger;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  won ? AppIcons.unicorn : Icons.dangerous_outlined,
                  color: accent,
                  size: AppDimens.iconMd,
                ),
                const SizedBox(width: AppDimens.gapSm),
                Expanded(
                  child: Text(
                    won
                        ? strings[StringKey.gameOverWonTitle]
                        : strings[StringKey.gameOverLostTitle],
                    style: textTheme.headlineSmall?.copyWith(color: accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapMd),
            Text(
              won
                  ? strings[StringKey.gameOverWonSubtitle]
                  : strings[_lossReasonKey(state.lossReason)],
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimens.gapLg),
            SectionLabel(strings[StringKey.logStatsSectionTitle]),
            _ScoreRow(
              label: strings[StringKey.gameOverWeeksLabel],
              value: '${state.week}',
            ),
            _ScoreRow(
              label: strings[StringKey.gameOverValuationLabel],
              value: formatMoney(state.valuation),
            ),
            _ScoreRow(
              label: strings[StringKey.gameOverCrisesLabel],
              value: '${state.resolvedCrises}',
            ),
            const SizedBox(height: AppDimens.gapLg),
            // Kapanış repliği: kazandıysak Mert, kaybettiysek Zeynep
            // konuşuyor — ikisi de karakterine uygun.
            CharacterBubble(
              character: _closingSpeaker(characters, won),
              line: _closingLine(characters, won, state),
              accentColor: accent,
              dense: true,
            ),
            const SizedBox(height: AppDimens.gapLg),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(gameControllerProvider.notifier).startNewGame(),
              icon: const Icon(AppIcons.newGame, size: AppDimens.iconSm),
              label: Text(strings[StringKey.gameOverRestartButton]),
            ),
          ],
        ),
      ),
    );
  }

  StringKey _lossReasonKey(LossReason? reason) => switch (reason) {
    LossReason.bankruptcy => StringKey.lossReasonBankruptcy,
    LossReason.serverMeltdown => StringKey.lossReasonServerMeltdown,
    LossReason.massResignation => StringKey.lossReasonMassResignation,
    null => StringKey.gameOverLostTitle,
  };

  Character? _closingSpeaker(List<Character> characters, bool won) {
    final id = won ? 'mert' : 'zeynep';
    for (final character in characters) {
      if (character.id == id) return character;
    }
    return characters.isEmpty ? null : characters.first;
  }

  String _closingLine(List<Character> characters, bool won, GameState state) {
    final speaker = _closingSpeaker(characters, won);
    final situation = won
        ? DialogueSituation.victory
        : DialogueSituation.defeat;
    // Replik seçimi hafta sayısına bağlı: aynı oyunda hep aynı cümle
    // görünür, farklı oyunlarda değişir.
    return speaker?.dialogueAt(situation, state.week) ?? '';
  }
}

/// Skor kartındaki etiket/değer satırı.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodySmall)),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
