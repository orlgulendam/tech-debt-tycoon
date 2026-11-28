import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';
import 'sheet_scaffold.dart';

/// Sözlük terimi detay sheet'i.
///
/// Üç bölüm: nedir, gerçek hayatta neye benzer, oyunda hangi sayıya
/// dokunur. Üçüncüsü oyunun eğitici tarafını mekaniğe bağlayan parça —
/// terim soyut bir tanım olarak kalmıyor.
class GlossarySheet extends ConsumerWidget {
  const GlossarySheet({required this.term, super.key});

  /// Gösterilecek terim.
  final GlossaryTerm term;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return SheetScaffold(
      title: term.name,
      icon: AppIcons.forGlossaryCategory(term.category),
      accentColor: AppColors.accent,
      footer: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(strings[StringKey.commonClose]),
      ),
      children: [
        _Section(
          label: strings[StringKey.glossaryDefinitionLabel],
          text: term.shortDefinition,
        ),
        _Section(
          label: strings[StringKey.glossaryRealLifeLabel],
          text: term.realLifeExample,
        ),
        _Section(
          label: strings[StringKey.glossaryGameEffectLabel],
          text: term.gameEffect,
          accent: AppColors.good,
        ),
      ],
    );
  }
}

/// Etiketli metin bölümü.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.text, this.accent});

  final String label;
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: accent),
          ),
          const SizedBox(height: AppDimens.gapXs),
          Text(text, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Sözlük terimi sheet'ini açar.
Future<void> showGlossarySheet(BuildContext context, GlossaryTerm term) {
  return showAppSheet<void>(
    context: context,
    builder: (context) => GlossarySheet(term: term),
  );
}
