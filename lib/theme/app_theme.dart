import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final textTheme = ThemeData(fontFamily: 'Segoe UI').textTheme.apply(
      bodyColor: AppColors.textoPrincipal,
      displayColor: AppColors.textoPrincipal,
    );
    return ThemeData(
      fontFamily: 'Segoe UI',
      brightness: AppColors.brillo,
      scaffoldBackgroundColor: AppColors.fondo,
      colorSchemeSeed: AppColors.verde,
      useMaterial3: true,
      textTheme: textTheme,
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