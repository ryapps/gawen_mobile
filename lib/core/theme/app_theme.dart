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
  static const warningSoft = Color(0xFFFFF3E4);
  static const error = Color(0xFFD94F4F);
  static const errorSoft = Color(0xFFFFF0F0);
  static const info = Color(0xFF3478D4);
  static const surface = Colors.white;
}

abstract final class GawenSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class GawenRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

abstract final class GawenTextStyles {
  static const title = TextStyle(
    color: GawenColors.text,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
  static const sectionTitle = TextStyle(
    color: GawenColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
  static const body = TextStyle(
    color: GawenColors.text,
    fontSize: 14,
    height: 1.5,
  );
  static const caption = TextStyle(
    color: GawenColors.muted,
    fontSize: 12,
    height: 1.4,
  );
  static const label = TextStyle(
    color: GawenColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
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
