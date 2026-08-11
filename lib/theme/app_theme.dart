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
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.verde,
        foregroundColor: AppColors.fondo,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.verde,
        foregroundColor: AppColors.fondo,
      ),
    );
  }
}