import 'package:city_guide_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final colorScheme = generatedScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
