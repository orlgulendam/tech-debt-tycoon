import 'package:material_ui/material_ui.dart';

import '../models/models.dart';
import '../theme/theme.dart';
import 'typewriter_text.dart';

/// Bir karakterin konuşma balonu.
///
/// Avatar + ad/unvan + replik. Oyunun anlatı sesi bu widget'tan geliyor:
/// ofis ekranında durum yorumu, olay kartlarında anlatım, sonuç
/// ekranlarında kapanış repliği hep burada görünür.
class CharacterBubble extends StatelessWidget {
  const CharacterBubble({
    required this.character,
    required this.line,
    super.key,
    this.accentColor,
    this.dense = false,
    this.animate = true,
  });

  /// Konuşan karakter. `null` ise anlatıcı konuşuyor sayılır.
  final Character? character;

  /// Replik metni.
  final String line;

  /// Avatar çerçevesinin rengi. Verilmezse olayın tonuna göre nötr durur.
  final Color? accentColor;

  /// `true` ise daha sıkışık yerleşim (bottom sheet içi).
  final bool dense;

  /// Replik daktilo efektiyle yazılsın mı?
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = accentColor ?? AppColors.info;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: dense ? 34 : 40,
          height: dense ? 34 : 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Icon(
            character == null
                ? Icons.terminal
                : AppIcons.forId(character!.iconId),
            size: dense ? 18 : 22,
            color: accent,
          ),
        ),
        const SizedBox(width: AppDimens.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (character != null)
                Row(
                  children: [
                    Text(
                      character!.name,
                      style: textTheme.titleSmall?.copyWith(color: accent),
                    ),
                    const SizedBox(width: AppDimens.gapSm),
                    Expanded(
                      child: Text(
                        character!.title,
                        style: textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (character != null) const SizedBox(height: AppDimens.gapXs),
              TypewriterText(
                line,
                enabled: animate,
                style: dense ? textTheme.bodySmall : textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
