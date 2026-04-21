import 'package:flutter/material.dart';

/// Modern dark theme with cyan/purple accents
class AppTheme {
  AppTheme._();

  // Colors
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF141419);
  static const Color surfaceLight = Color(0xFF1E1E26);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color purple = Color(0xFF9D4EDD);
  static const Color pink = Color(0xFFFF006E);
  static const Color green = Color(0xFF00F5D4);
  static const Color yellow = Color(0xFFFFBE0B);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF8B8B9E);
  static const Color greyDark = Color(0xFF4A4A5A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: cyan,
        secondary: purple,
        onPrimary: background,
        onSecondary: white,
        onBackground: white,
        onSurface: white,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.5,
        ),
      ),
      // Cards with glassmorphism
      cardTheme: CardThemeData(
        color: surface.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: cyan.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyan, width: 2),
        ),
        hintStyle: const TextStyle(color: grey),
        labelStyle: const TextStyle(color: grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: background,
          minimumSize: const Size(120, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          minimumSize: const Size(120, 56),
          side: const BorderSide(color: greyDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cyan,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: white,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: white,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: grey,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: grey,
          letterSpacing: 0.5,
        ),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: greyDark.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }

  // Gradient decorations
  static BoxDecoration get gradientBackground {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          background,
          surface,
          background,
        ],
      ),
    );
  }

  static Gradient get cyanGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cyan, Color(0xFF00A8CC)],
    );
  }

  static Gradient get purpleGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [purple, Color(0xFF7B2CBF)],
    );
  }

  static BoxDecoration get cyanGradientBox {
    return BoxDecoration(
      gradient: cyanGradient,
    );
  }

  static BoxDecoration get purpleGradientBox {
    return BoxDecoration(
      gradient: purpleGradient,
    );
  }

  // Glow effects
  static List<BoxShadow> get cyanGlow {
    return [
      BoxShadow(
        color: cyan.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }

  static List<BoxShadow> get purpleGlow {
    return [
      BoxShadow(
        color: purple.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }
}
