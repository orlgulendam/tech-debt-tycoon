import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'share_service.dart';

/// Sistemin paylaşım sayfasını açan gerçek uygulama.
///
/// Flutter ve platform eklentilerine bağımlı olduğu için [ShareService]
/// arayüzünden ayrı dosyada; `lib/providers` ve `lib/services` çekirdeği
/// saf Dart kalıyor ve `main()` bu uygulamayı enjekte ediyor.
class PlatformShareService implements ShareService {
  const PlatformShareService();

  @override
  Future<bool> shareScore({
    required String text,
    required String subject,
    required String fileName,
    Uint8List? imageBytes,
  }) async {
    try {
      if (imageBytes == null) {
        await SharePlus.instance.share(
          ShareParams(text: text, subject: subject),
        );
        return true;
      }

      // Görseli geçici dizine yaz: paylaşım eklentisi bayt dizisi değil
      // dosya istiyor. Geçici dizin sistem tarafından temizleniyor,
      // bizim ayrıca silmemiz gerekmiyor.
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          files: [XFile(file.path, mimeType: 'image/png')],
        ),
      );
      return true;
    } on Object {
      // Paylaşım açılamadıysa (eklenti hatası, disk dolu, kullanıcı
      // platformunda paylaşım yok) oyunu çökertmeyelim; çağıran taraf
      // kullanıcıya bilgi veriyor.
      return false;
    }
  }
}
