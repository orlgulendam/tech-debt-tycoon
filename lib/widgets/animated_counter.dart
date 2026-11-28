import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Değeri değiştiğinde yeni sayıya "koşan" metin.
///
/// Oyunlaştırmanın en ucuz ve en etkili parçası: bir hafta kapandığında
/// bütçenin 15.000'den 17.200'e **sayarak** çıkması, sayının birden
/// değişmesinden çok daha fazla şey anlatıyor. Oyuncu hem değiştiğini
/// hem ne kadar değiştiğini görüyor.
///
/// Sayı büyürken kısa süre yeşil, küçülürken kırmızı parlıyor; renk
/// animasyon bitince normale dönüyor.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    required this.value,
    required this.format,
    super.key,
    this.style,
    this.baseColor,
    this.inverted = false,
    this.flash = true,
  });

  /// Gösterilecek güncel değer.
  final int value;

  /// Sayıyı metne çeviren biçimlendirici (bkz. `lib/l10n/formatters.dart`).
  final String Function(int) format;

  /// Metin stili.
  final TextStyle? style;

  /// Değişim olmadığındaki renk.
  final Color? baseColor;

  /// `true` ise artış kötüdür (teknik borç): renkler ters çalışır.
  final bool inverted;

  /// Değişimde renk parlaması olsun mu?
  final bool flash;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _from;
  late int _to;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _to = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.counter,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;

    // Animasyon ortasında yeni bir değişim gelirse o anki görünen
    // sayıdan devam et; yoksa sayı geriye sıçrıyor.
    _from = _currentValue;
    _to = widget.value;
    _controller
      ..reset()
      ..forward();
  }

  /// Animasyonun o anki ara değeri.
  int get _currentValue {
    final t = Curves.easeOutCubic.transform(_controller.value);
    return (_from + (_to - _from) * t).round();
  }

  /// Değişim yönüne göre parlama rengi.
  Color? get _flashColor {
    if (!widget.flash || _to == _from) return null;
    final increased = _to > _from;
    final good = widget.inverted ? !increased : increased;
    return good ? AppColors.good : AppColors.danger;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.textPrimary;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // Hareket azaltma açıkken sayı koşmadan doğrudan yazılır.
    if (reduceMotion) {
      return Text(
        widget.format(widget.value),
        style: (widget.style ?? const TextStyle()).copyWith(
          color: base,
          fontFeatures: AppTypography.tabularFigures,
        ),
        maxLines: 1,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final flash = _flashColor;
        // Parlama animasyonun başında güçlü, sonunda yok.
        final color = flash == null
            ? base
            : Color.lerp(flash, base, _controller.value) ?? base;

        return Text(
          widget.format(_currentValue),
          style: (widget.style ?? const TextStyle()).copyWith(
            color: color,
            fontFeatures: AppTypography.tabularFigures,
          ),
          maxLines: 1,
        );
      },
    );
  }
}
