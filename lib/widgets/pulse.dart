import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Çocuğunu yavaşça yanıp söndürür.
///
/// Yalnızca **kritik** durumlarda kullanılıyor: teknik borç tehlikeli
/// seviyedeyken, moral dibe yaklaşırken, bütçe tükenmek üzereyken.
/// Sürekli bir şey yanıp sönerse uyarı olmaktan çıkıp gürültü olur, bu
/// yüzden [active] bayrağı dikkatli veriliyor.
class Pulse extends StatefulWidget {
  const Pulse({
    required this.child,
    super.key,
    this.active = true,
    this.minOpacity = 0.45,
  });

  /// Yanıp sönecek içerik.
  final Widget child;

  /// `false` ise içerik sabit durur.
  final bool active;

  /// Sönük anındaki opaklık.
  final double minOpacity;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
  );

  /// Kullanıcı sistem ayarlarından hareketi azaltmayı seçmiş mi?
  ///
  /// Sürekli yanıp sönen bir öğe vestibüler rahatsızlığı olan kullanıcılar
  /// için ciddi bir sorun; ayrıca sonsuz animasyon widget testlerinde
  /// `pumpAndSettle`'ı kilitliyor. İkisini birden çözen doğru yer bu ayar.
  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(Pulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Denetleyiciyi istenen duruma getirir.
  void _sync() {
    final shouldRun = widget.active && !_reduceMotion;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!shouldRun && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active || _reduceMotion) return widget.child;

    return FadeTransition(
      opacity: Tween<double>(
        begin: widget.minOpacity,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Dokunulduğunda hafifçe küçülen sarmalayıcı.
///
/// Oyun hissi için: kart "basılmış" gibi tepki veriyor. Material'ın
/// kendi dalga efekti koyu temada neredeyse görünmüyor, bu yüzden
/// ölçek değişimi ekliyoruz.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    required this.onTap,
    super.key,
    this.scale = 0.97,
  });

  /// İçerik.
  final Widget child;

  /// Dokunma eylemi. `null` ise tepki verilmez.
  final VoidCallback? onTap;

  /// Basılıyken uygulanacak ölçek.
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale:
            _pressed &&
                !(MediaQuery.maybeOf(context)?.disableAnimations ?? false)
            ? widget.scale
            : 1,
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        child: widget.child,
      ),
    );
  }
}
