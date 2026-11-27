import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';
import '../character_bubble.dart';
import '../effect_summary.dart';
import 'sheet_scaffold.dart';

/// Olay kartı karar sheet'i.
///
/// İki aşamalı: önce anlatım + seçenekler, seçim yapıldıktan sonra sonuç
/// metni. Oyuncu karar vermeden kapatamaz — kart durumda bekliyor ve
/// kapatmaya izin vermek oyunu tıkanmış gösterirdi.
class EventSheet extends ConsumerStatefulWidget {
  const EventSheet({required this.card, super.key});

  /// Karar bekleyen olay kartı.
  final EventCard card;

  @override
  ConsumerState<EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends ConsumerState<EventSheet> {
  /// Seçim yapıldıysa sonucu; `null` ise hâlâ karar aşamasında.
  EventResolution? _resolution;

  /// Olayın ciddiyetine göre vurgu rengi.
  Color get _accent => switch (widget.card.severity) {
    EventSeverity.critical => AppColors.danger,
    EventSeverity.warning => AppColors.warning,
    EventSeverity.positive => AppColors.good,
    EventSeverity.info => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final characters = ref.watch(contentProvider).characters;
    final textTheme = Theme.of(context).textTheme;
    final resolution = _resolution;

    return SheetScaffold(
      title: widget.card.title,
      icon: resolution == null
          ? Icons.priority_high
          : Icons.subdirectory_arrow_right,
      accentColor: _accent,
      footer: resolution == null
          ? null
          : FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings[StringKey.eventContinueButton]),
            ),
      children: resolution == null
          ? _buildChoiceStage(strings, characters, textTheme)
          : _buildOutcomeStage(strings, characters, textTheme, resolution),
    );
  }

  /// Karar aşaması: anlatım + seçenekler.
  List<Widget> _buildChoiceStage(
    AppStrings strings,
    List<Character> characters,
    TextTheme textTheme,
  ) {
    return [
      CharacterBubble(
        character: _characterById(characters, widget.card.speakerId),
        line: widget.card.narration,
        accentColor: _accent,
      ),
      const SizedBox(height: AppDimens.gapLg),
      Text(strings[StringKey.eventChooseOption], style: textTheme.labelSmall),
      const SizedBox(height: AppDimens.gapSm),
      ...widget.card.choices.map(
        (choice) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
          child: _ChoiceButton(choice: choice, onTap: () => _choose(choice)),
        ),
      ),
      const SizedBox(height: AppDimens.gapSm),
    ];
  }

  /// Sonuç aşaması: seçimin ne getirdiği.
  List<Widget> _buildOutcomeStage(
    AppStrings strings,
    List<Character> characters,
    TextTheme textTheme,
    EventResolution resolution,
  ) {
    final speakerId = resolution.choice.outcomeSpeakerId;

    return [
      Text(strings[StringKey.eventOutcomeTitle], style: textTheme.labelSmall),
      const SizedBox(height: AppDimens.gapSm),
      CharacterBubble(
        character: speakerId == null
            ? null
            : _characterById(characters, speakerId),
        line: resolution.choice.outcomeText,
        accentColor: _accent,
      ),
      const SizedBox(height: AppDimens.gapLg),
      Container(
        padding: const EdgeInsets.all(AppDimens.gapMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        ),
        child: EffectSummary(resolution.choice.effect),
      ),
      if (resolution.resolvedCrisis) ...[
        const SizedBox(height: AppDimens.gapMd),
        Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              size: AppDimens.iconSm,
              color: AppColors.good,
            ),
            const SizedBox(width: AppDimens.gapXs),
            Text(
              strings[StringKey.gameOverCrisesLabel],
              style: textTheme.labelSmall?.copyWith(color: AppColors.good),
            ),
          ],
        ),
      ],
      const SizedBox(height: AppDimens.gapSm),
    ];
  }

  void _choose(EventChoice choice) {
    final resolution = ref
        .read(gameControllerProvider.notifier)
        .resolveEvent(choice);
    if (resolution != null) setState(() => _resolution = resolution);
  }

  Character? _characterById(List<Character> characters, String id) {
    for (final character in characters) {
      if (character.id == id) return character;
    }
    return null;
  }
}

/// Tek bir olay seçeneği butonu.
///
/// Etiket + etkinin sayısal özeti. Oyuncu bedeli önceden görüyor; bu
/// bilinçli bir tasarım kararı — oyun sürpriz ceza üzerine kurulu değil,
/// bilinçli ödün verme üzerine kurulu.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.choice, required this.onTap});

  final EventChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(AppDimens.gapMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(choice.label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppDimens.gapSm),
          EffectSummary(choice.effect),
        ],
      ),
    );
  }
}

/// Olay kartı sheet'ini açar.
///
/// Kapatılamaz: oyuncu karar vermek zorunda.
Future<void> showEventSheet(BuildContext context, EventCard card) {
  return showAppSheet<void>(
    context: context,
    dismissible: false,
    builder: (context) => EventSheet(card: card),
  );
}
