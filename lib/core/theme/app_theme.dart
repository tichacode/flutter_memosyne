import 'package:flutter/material.dart';

/// Colors estimated from the Figma prototype. Adjust freely.
class AppColors {
  AppColors._();

  static const cream = Color(0xFFEFE6DC);
  static const paper = Color(0xFFFAF8F4);
  static const maroon = Color(0xFF5A1209);
  static const maroonSoft = Color(0xFF8A5A4F);
  static const yellow = Color(0xFFFDEBB0);
  static const green = Color(0xFF4F6B2A);
  static const danger = Color(0xFF7A1212);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.maroon,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.maroon,
      onPrimary: AppColors.paper,
      secondary: AppColors.yellow,
      onSecondary: AppColors.maroon,
      surface: AppColors.cream,
      onSurface: AppColors.maroon,
      error: AppColors.danger,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    // Font: default for now. Set `fontFamily` here when you pick a Thai+English font.
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.maroon,
        displayColor: AppColors.maroon,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.maroon,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.cream),
    );
  }
}
