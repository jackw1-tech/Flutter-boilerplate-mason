import 'package:flutter/material.dart';
import 'package:{{project_name}}/theme/AppTextStyles.dart';
import 'package:{{project_name}}/theme/ColorPalette.dart';
import 'package:{{project_name}}/theme/Dimensions.dart';

class AppTheme {
  // Tema chiaro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorPalette.primary,
        brightness: Brightness.light,
      ),
      textTheme: AppTextStyles.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
        elevation: Dimensions.appBarElevation,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            Dimensions.buttonMinWidth,
            Dimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
          ),
        ),
      ),
    );
  }

  // Tema scuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorPalette.primary,
        brightness: Brightness.dark,
      ),
      textTheme: AppTextStyles.textTheme,
      // Altri elementi del tema...
    );
  }
}
