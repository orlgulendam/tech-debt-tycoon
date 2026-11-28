import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Metni harf harf yazan terminal efekti.
///
/// Oyunun estetiği bir terminal; karakter replikleri de oraya yazılıyormuş
/// gibi görünsün diye. Yan faydası: oyuncunun gözü metne kilitleniyor,
/// anlatı akıp gitmiyor.
///
/// Dokununca animasyon atlanıyor — ikinci okuyuşta kimse beklemek
/// istemez.
class TypewriterText extends StatefulWidget {
  const TypewriterText(
    this.text, {
    super.key,
    this.style,
    this.enabled = true,
    this.showCursor = true,
  });

  /// Yazılacak metin.
  final String text;

  /// Metin stili.
  final TextStyle? style;

  /// `false` ise metin anında tam gösterilir.
  ///
  /// Testlerde ve erişilebilirlik tercihlerinde kapatılıyor.
  final bool enabled;

  /// Yazarken sonda yanıp sönen imleç gösterilsin mi?
  final bool showCursor;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _visible = 0;

  /// Kullanıcı hareketi azaltmayı seçtiyse metin anında tam görünür.
  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visible == 0) _start();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Replik değiştiyse baştan yaz.
    if (oldWidget.text != widget.text) _start();
  }

  void _start() {
    _timer?.cancel();
    if (!widget.enabled || _reduceMotion) {
      setState(() => _visible = widget.text.length);
      return;
    }

    setState(() => _visible = 0);
    _timer = Timer.periodic(AppMotion.typewriterPerChar, (timer) {
      if (!mounted) return timer.cancel();
      if (_visible >= widget.text.length) return timer.cancel();
      setState(() => _visible++);
    });
  }

  /// Animasyonu atlayıp metnin tamamını gösterir.
  void _skip() {
    _timer?.cancel();
    setState(() => _visible = widget.text.length);
  }

  bool get _typing => _visible < widget.text.length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.bodyMedium;

    return GestureDetector(
      onTap: _typing ? _skip : null,
      // Metin kutusu yazarken büyüyüp küçülmesin diye tam metin görünmez
      // biçimde arkada duruyor; yükseklik baştan sabit kalıyor.
      child: Stack(
        children: [
          Opacity(opacity: 0, child: Text(widget.text, style: style)),
          Text.rich(
            TextSpan(
              text: widget.text.substring(0, _visible),
              children: [
                if (_typing && widget.showCursor)
                  TextSpan(
                    text: '▊',
                    style: style?.copyWith(color: AppColors.good),
                  ),
              ],
            ),
            style: style,
          ),
        ],
      ),
    );
  }
}
