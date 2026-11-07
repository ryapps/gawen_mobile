import 'package:flutter/material.dart';

abstract final class GawenColors {
  static const primary = Color(0xFF21865B);
  static const primaryDark = Color(0xFF176644);
  static const primarySoft = Color(0xFFE5F5EC);
  static const background = Color(0xFFF7F9F7);
  static const text = Color(0xFF202923);
  static const muted = Color(0xFF68756C);
  static const border = Color(0xFFE3E9E4);
  static const warning = Color(0xFFE8A23A);
  static const error = Color(0xFFD94F4F);
  static const info = Color(0xFF3478D4);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GawenColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: GawenColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: GawenColors.background,
        foregroundColor: GawenColors.text,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: GawenColors.text,
        displayColor: GawenColors.text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GawenColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GawenColors.primaryDark,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0xFFB8D7C6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GawenColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GawenColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GawenColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
      ),
    );
  }
}
