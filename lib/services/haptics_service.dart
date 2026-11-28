/// Dokunsal geri bildirim.
///
/// Soyut tutulmasının nedeni testler: widget testlerinde gerçek titreşim
/// kanalı yok ve her dokunuşta platform çağrısı yapmak testleri
/// gürültülendiriyor. Testler [NoopHapticsService] kullanıyor.
///
/// Kullanım kuralı: titreşim **bilgi taşımalı**, süs olmamalı. Oyunda üç
/// ayrı anlam var — seçim yapıldı, bir şey kazanıldı, bir şey ters gitti.
///
/// Bu dosya bilinçli olarak Flutter'a bağımlı değil: provider katmanı saf
/// Dart kalsın ve `dart test` ile koşabilsin diye. Platformun titreşim
/// motorunu kullanan uygulama `platform_haptics_service.dart` içinde ve
/// yalnızca `main()` tarafından bağlanıyor.
abstract interface class HapticsService {
  /// Hafif dokunuş: bir seçim yapıldı (sekme, kart, seçenek).
  Future<void> selection();

  /// Orta dokunuş: bir hafta kapandı, kayda değer bir şey oldu.
  Future<void> impact();

  /// Başarı: kriz çözüldü, işe alım yapıldı, ödül kazanıldı.
  Future<void> success();

  /// Uyarı/hata: bütçe yetmedi, kritik eşik aşıldı, oyun kaybedildi.
  Future<void> warning();
}

/// Hiçbir şey yapmayan uygulama (testler ve titreşimin kapalı olduğu
/// durumlar için).
class NoopHapticsService implements HapticsService {
  const NoopHapticsService();

  @override
  Future<void> selection() async {}

  @override
  Future<void> impact() async {}

  @override
  Future<void> success() async {}

  @override
  Future<void> warning() async {}
}
