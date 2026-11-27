import 'package:material_ui/material_ui.dart';

import '../../theme/theme.dart';

/// Bütün bottom sheet'lerin ortak iskeleti.
///
/// Başlık, isteğe bağlı ikon ve kaydırılabilir gövde. Tek yerde durması
/// önemli: sheet'ler arasında dolgu/köşe/başlık farkı olursa arayüz
/// derme çatma görünür.
///
/// Yüksekliği içeriğe göre büyür ama ekranın %85'ini geçmez; uzun içerik
/// kendi içinde kayar.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    required this.title,
    required this.children,
    super.key,
    this.icon,
    this.accentColor,
    this.footer,
  });

  /// Sheet başlığı (`l10n`'dan gelir).
  final String title;

  /// Gövde içeriği.
  final List<Widget> children;

  /// Başlık yanındaki ikon.
  final IconData? icon;

  /// Başlık ve ikon rengi.
  final Color? accentColor;

  /// Gövdenin altına sabitlenen alan (eylem butonları).
  ///
  /// Kaydırma alanının dışında kalır; uzun içerikte buton hep görünür.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.textSecondary;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                0,
                AppDimens.screenPadding,
                AppDimens.gapMd,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimens.iconMd, color: accent),
                    const SizedBox(width: AppDimens.gapSm),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: accent),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  AppDimens.gapMd,
                  AppDimens.screenPadding,
                  AppDimens.gapSm,
                ),
                child: footer,
              ),
            const SizedBox(height: AppDimens.gapSm),
          ],
        ),
      ),
    );
  }
}

/// Uygulamadaki bütün bottom sheet'leri aynı ayarlarla açar.
///
/// `isScrollControlled` şart: içerik uzun olduğunda sheet ekranın yarısında
/// kesilmesin.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
  );
}
