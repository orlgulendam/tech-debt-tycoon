import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Bölüm başlığı.
///
/// Terminal çıktısındaki bölüm ayırıcılarına benzesin diye küçük, aralıklı
/// ve soluk; yanında ince bir çizgi var.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  /// Başlık metni. Çağıran taraf `l10n`'dan okuyup verir.
  final String text;

  /// Başlığın sağ ucuna konacak isteğe bağlı widget (sayaç, buton).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(width: AppDimens.gapSm),
          const Expanded(child: Divider()),
          if (trailing != null) ...[
            const SizedBox(width: AppDimens.gapSm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
