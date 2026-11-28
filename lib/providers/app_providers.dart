import 'dart:math';

import 'package:riverpod/riverpod.dart';

import '../data/game_content.dart';
import '../l10n/l10n.dart';
import '../services/ad_service.dart';
import '../services/haptics_service.dart';
import '../services/hint_service.dart';
import '../services/storage_service.dart';

/// Uygulama genelindeki altyapı provider'ları.
///
/// Oyunun durumu [gameControllerProvider] içinde; burada onun ihtiyaç
/// duyduğu servisler ve ayarlar var.

/// Kalıcı kayıt servisi.
///
/// `main()` içinde hazırlanmış gerçek servisle **override edilmek zorunda**:
/// depolamanın açılması asenkron olduğu için uygulama başlamadan bir kez
/// yapılır, sonra senkron okunur. Override edilmezse (ör. testte) belleğe
/// yazan yedek uygulama kullanılır.
final storageServiceProvider = Provider<StorageService>((ref) {
  return InMemoryStorageService();
});

/// Seçili dil.
///
/// Başlangıç değeri kayıttan gelir; değiştiğinde kayda yazılır.
final languageProvider = NotifierProvider<LanguageController, AppLanguage>(
  LanguageController.new,
);

/// Dil seçimini tutan ve kaydeden controller.
class LanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => ref.read(storageServiceProvider).language;

  /// Dili değiştirir ve kaydeder.
  Future<void> setLanguage(AppLanguage language) async {
    if (language == state) return;
    state = language;
    await ref.read(storageServiceProvider).setLanguage(language);
  }
}

/// Seçili dile göre metin tablosu.
///
/// UI metinlere **yalnızca** buradan erişir; widget içine düz metin yazılmaz.
final stringsProvider = Provider<AppStrings>((ref) {
  return AppStrings.of(ref.watch(languageProvider));
});

/// Seçili dile göre statik oyun içeriği (karakterler, aksiyonlar, olaylar).
final contentProvider = Provider<GameContent>((ref) {
  return GameContent.of(ref.watch(languageProvider));
});

/// Akıllı ipucu servisi. Dil değişince metinleri de değişir.
final hintServiceProvider = Provider<HintService>((ref) {
  return HintService(ref.watch(stringsProvider));
});

/// Ödüllü reklam servisi. Şimdilik sahte; mağaza sürümünde buraya gerçek
/// bir ağ takılacak.
final adServiceProvider = Provider<AdService>((ref) {
  return FakeAdService(random: ref.watch(randomProvider));
});

/// Dokunsal geri bildirim.
///
/// Varsayılan sessiz: bu katman saf Dart olduğu için platformun titreşim
/// motorunu tanımıyor. `main()` gerçek uygulamayı (
/// `PlatformHapticsService`) enjekte ediyor; testler varsayılanı olduğu
/// gibi kullanıyor.
final hapticsProvider = Provider<HapticsService>((ref) {
  return const NoopHapticsService();
});

/// Oyunun rastgele sayı üreteci.
///
/// Tek bir yerden gelmesi önemli: testler bunu sabit tohumlu bir [Random]
/// ile override edip bütün oyunu deterministik hâle getirebiliyor.
final randomProvider = Provider<Random>((ref) => Random());

/// Onboarding daha önce tamamlandı mı?
final onboardingProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

/// Onboarding durumunu tutan ve kaydeden controller.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.read(storageServiceProvider).onboardingCompleted;

  /// Onboarding'i tamamlandı olarak işaretler ve kaydeder.
  Future<void> complete() async {
    if (state) return;
    state = true;
    await ref.read(storageServiceProvider).setOnboardingCompleted(true);
  }

  /// Onboarding'i sıfırlar (ayarlardan "tanıtımı tekrar göster" için).
  Future<void> reset() async {
    state = false;
    await ref.read(storageServiceProvider).setOnboardingCompleted(false);
  }
}
