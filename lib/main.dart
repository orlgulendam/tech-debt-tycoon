import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/l10n.dart';
import 'providers/providers.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/hive_storage_service.dart';
import 'services/platform_haptics_service.dart';
import 'services/platform_share_service.dart';
import 'services/storage_service.dart';
import 'theme/theme.dart';

/// Uygulamanın giriş noktası.
///
/// Kalıcı kayıt burada **bir kez** hazırlanıp provider'a enjekte edilir:
/// depolamayı açmak asenkron, ama oyun açıldığında kaydın hazır olması
/// gerekiyor. Böylece `GameController` kayıtlı oyunu senkron okuyabiliyor
/// ve UI "yükleniyor" durumu göstermek zorunda kalmıyor.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Oyun dikey modda, tek elle oynanmak üzere tasarlandı.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = await _openStorage();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        hapticsProvider.overrideWithValue(const PlatformHapticsService()),
        shareServiceProvider.overrideWithValue(const PlatformShareService()),
      ],
      child: const TechDebtTycoonApp(),
    ),
  );
}

/// Kalıcı kaydı açar; açılamazsa belleğe yazan yedeğe düşer.
///
/// Hive bozuk bir dosya ya da izin sorunu yüzünden açılamazsa oyunun hiç
/// başlamaması en kötü sonuç olur. Bu durumda oyun oynanabilir kalır,
/// yalnızca kayıt tutulmaz.
Future<StorageService> _openStorage() async {
  final hive = HiveStorageService();
  try {
    await hive.init();
    return hive;
  } on Object {
    final fallback = InMemoryStorageService();
    await fallback.init();
    return fallback;
  }
}

/// Kök uygulama widget'ı.
class TechDebtTycoonApp extends ConsumerWidget {
  const TechDebtTycoonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return MaterialApp(
      title: strings[StringKey.appTitle],
      debugShowCheckedModeBanner: false,
      // Yalnızca koyu tema: IDE/terminal estetiği açık temada anlamını
      // yitiriyor (bkz. `lib/theme/app_theme.dart`).
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const _AppEntry(),
    );
  }
}

/// İlk açılışta tanıtımı, sonrasında oyunu gösterir.
class _AppEntry extends ConsumerWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingProvider);

    return onboardingCompleted ? const HomeShell() : const OnboardingScreen();
  }
}
