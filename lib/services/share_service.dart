import 'dart:typed_data';

/// Oyun sonucunu paylaşma.
///
/// Soyut tutulmasının nedeni testler: gerçek paylaşım sayfası platform
/// kanalı açıyor ve widget testinde sistem arayüzü açılamıyor. Testler
/// [RecordingShareService] kullanıp ne paylaşıldığını doğruluyor.
abstract interface class ShareService {
  /// Metin ve (varsa) PNG görsel paylaşır.
  ///
  /// [imageBytes] verilmezse yalnızca metin paylaşılır — görsel üretimi
  /// başarısız olduğunda oyuncunun eli boş kalmasın.
  ///
  /// Paylaşım sayfası açılabildiyse `true` döner.
  Future<bool> shareScore({
    required String text,
    required String subject,
    required String fileName,
    Uint8List? imageBytes,
  });
}

/// Testlerde kullanılan, paylaşılanı kaydeden uygulama.
class RecordingShareService implements ShareService {
  RecordingShareService({this.succeeds = true});

  /// Çağrı başarılı sayılsın mı?
  final bool succeeds;

  /// Son paylaşılan metin.
  String? lastText;

  /// Son paylaşılan görselin bayt sayısı; görsel yoksa `null`.
  int? lastImageByteCount;

  /// Kaç kez paylaşıldı.
  int shareCount = 0;

  @override
  Future<bool> shareScore({
    required String text,
    required String subject,
    required String fileName,
    Uint8List? imageBytes,
  }) async {
    shareCount++;
    lastText = text;
    lastImageByteCount = imageBytes?.length;
    return succeeds;
  }
}
