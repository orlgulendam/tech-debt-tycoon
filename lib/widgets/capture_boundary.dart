import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Çocuğunu PNG'ye çevirebilen sarmalayıcı.
///
/// Skor karnesini paylaşmak için: ekranda görünen widget'ın **aynısı**
/// görsele dönüşüyor, ayrıca bir "paylaşım görseli" tasarlamak
/// gerekmiyor. İkisinin ayrı kodlanması ergeç birinin diğerinden
/// sapmasına yol açardı.
class CaptureBoundary extends StatelessWidget {
  const CaptureBoundary({
    required this.controller,
    required this.child,
    super.key,
  });

  /// Yakalamayı tetikleyen denetleyici.
  final CaptureController controller;

  /// Görsele dönüştürülecek içerik.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: controller.boundaryKey, child: child);
  }
}

/// [CaptureBoundary] içeriğini PNG'ye çevirir.
class CaptureController {
  /// Yakalanacak sınırın anahtarı.
  final GlobalKey boundaryKey = GlobalKey();

  /// İçeriği PNG baytlarına çevirir.
  ///
  /// [pixelRatio] paylaşılan görselin çözünürlüğünü belirler; 3 değeri
  /// sosyal medyada bulanık görünmeyecek bir boyut veriyor.
  ///
  /// Widget henüz çizilmemişse ya da yakalama başarısız olursa `null`
  /// döner — çağıran taraf o zaman yalnızca metin paylaşıyor.
  Future<Uint8List?> capturePng({double pixelRatio = 3}) async {
    try {
      final context = boundaryKey.currentContext;
      if (context == null) return null;

      final boundary = context.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      return data?.buffer.asUint8List();
    } on Object {
      return null;
    }
  }
}
