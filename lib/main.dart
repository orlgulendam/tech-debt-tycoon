import 'package:material_ui/material_ui.dart';

import 'l10n/l10n.dart';

/// Uygulamanın giriş noktası.
///
/// Aşama 1 yalnızca veri katmanını kapsıyor; bu dosya şimdilik iskelet bir
/// uygulama açar ve içeriğin yüklendiğini doğrular. Aşama 2'de `ProviderScope`
/// ve kayıt servisi, Aşama 3'te tema, navigasyon ve ekranlar buraya bağlanacak.
void main() {
  runApp(const TechDebtTycoonApp());
}

/// Kök uygulama widget'ı.
class TechDebtTycoonApp extends StatelessWidget {
  const TechDebtTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(AppLanguage.fallback);
    return MaterialApp(
      title: strings[StringKey.appTitle],
      debugShowCheckedModeBanner: false,
      // Gerçek tema Aşama 3'te `lib/theme/` altından gelecek.
      theme: ThemeData.dark(useMaterial3: true),
      home: _PlaceholderHome(strings: strings),
    );
  }
}

/// Aşama 3'te gerçek ekranlarla değiştirilecek geçici karşılama ekranı.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings[StringKey.appTitle],
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  strings[StringKey.appTagline],
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
