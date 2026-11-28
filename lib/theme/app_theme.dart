import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Uygulamanın tek teması.
///
/// Oyun yalnızca koyu temada çalışır: IDE/terminal estetiği açık temada
/// anlamını yitiriyor ve iki temayı birlikte iyi tutmak boşa bakım yükü
/// olurdu. `MaterialApp.theme` olarak verilir, `darkTheme` ayrıca
/// tanımlanmaz.
abstract final class AppTheme {
  /// Koyu tema.
  static ThemeData dark() {
    final textTheme = AppTypography.textTheme();

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.good,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.background,
          primary: AppColors.good,
          onPrimary: AppColors.textOnAccent,
          secondary: AppColors.info,
          error: AppColors.danger,
          onError: AppColors.textOnAccent,
          outline: AppColors.border,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppDimens.iconMd,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusSheet),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.good.withValues(alpha: 0.16),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: AppDimens.iconMd,
            color: selected ? AppColors.good : AppColors.textMuted,
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.good,
          foregroundColor: AppColors.textOnAccent,
          disabledBackgroundColor: AppColors.surfaceAlt,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.good,
          textStyle: textTheme.labelLarge,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.good,
        linearTrackColor: AppColors.surfaceAlt,
        linearMinHeight: AppDimens.progressHeight,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.good.withValues(alpha: 0.18),
        side: const BorderSide(color: AppColors.border),
        labelStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.gapMd,
          vertical: AppDimens.gapMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          borderSide: const BorderSide(color: AppColors.good),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textSecondary,
        titleTextStyle: textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.cardPadding,
          vertical: AppDimens.gapXs,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        ),
      ),
    );
  }
}
