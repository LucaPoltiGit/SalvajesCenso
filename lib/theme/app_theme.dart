import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      fontFamily: 'Segoe UI',
      scaffoldBackgroundColor: AppColors.fondo,
      colorSchemeSeed: AppColors.verde,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.verde,
        foregroundColor: AppColors.fondo,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.verde,
        foregroundColor: AppColors.fondo,
      ),
    );
  }
}