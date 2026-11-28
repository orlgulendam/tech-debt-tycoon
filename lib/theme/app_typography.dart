import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Tipografi.
///
/// Oyunun tamamı monospace: IDE/terminal estetiğinin en belirleyici parçası
/// bu.
///
/// Font `assets/fonts/` altında **uygulamaya gömülü** ve `pubspec.yaml`
/// içindeki standart `fonts:` bildirimiyle kayıtlı. Çalışma anında hiçbir
/// şey indirilmiyor; oyun tamamen çevrimdışı çalışmak zorunda.
///
/// (`google_fonts` paketi bilinçli olarak kullanılmıyor: fontu varsayılan
/// olarak çalışma anında internetten indiriyor, gömülü varlıkla
/// kullanıldığında da yüklemeyi asenkron yaptığı için widget testlerinde
/// ağaç dağıtıldıktan sonra kare planlayıp uyarı üretiyordu. Standart
/// bildirim hem daha basit hem bir bağımlılık eksik.)
abstract final class AppTypography {
  /// Gömülü monospace font ailesi. `pubspec.yaml` ile aynı olmak zorunda.
  static const String fontFamily = 'JetBrains Mono';

  /// Monospace metin teması.
  static TextTheme textTheme() {
    final base = ThemeData.dark(useMaterial3: true).textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      // Büyük sayılar (değerleme, bütçe) için sıkı ve kalın.
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      // Bölüm başlıkları: terminal komutu gibi aralıklı ve küçük.
      labelSmall: base.labelSmall?.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Sayıları hizalı göstermek için tabular (sabit genişlikli) rakamlar.
  ///
  /// Metrikler her hafta değiştiği için rakam genişliği sabit olmazsa
  /// sayılar titrer.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];
}
