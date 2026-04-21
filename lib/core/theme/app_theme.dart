import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _accent = Color(0xFF15D8FF);
  static const _surface = Color(0xFF101316);
  static const _surfaceAlt = Color(0xFF151A1E);
  static const _background = Color(0xFF090B0D);
  static const _divider = Color(0xFF1E2A31);
  static const _success = Color(0xFF18C37E);
  static const _danger = Color(0xFFFF5E7A);

  static ThemeData dark() {
    final scheme = const ColorScheme.dark(
      primary: _accent,
      secondary: _accent,
      surface: _surface,
      onSurface: Color(0xFFF2F7FA),
      error: _danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
      dividerColor: _divider,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _divider),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceAlt,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: Color(0xFF8A9BA6)),
        hintStyle: const TextStyle(color: Color(0xFF61717B)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          backgroundColor: _accent,
          foregroundColor: _background,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          side: const BorderSide(color: _divider),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceAlt,
        selectedColor: _surfaceAlt,
        disabledColor: _surfaceAlt,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        side: const BorderSide(color: _divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        collapsedIconColor: _accent,
        iconColor: _accent,
        childrenPadding: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: _divider, thickness: 0.8),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
      iconTheme: const IconThemeData(color: _accent),
      extensions: const <ThemeExtension<dynamic>>[
        AppThemeColors(
          accent: _accent,
          surfaceAlt: _surfaceAlt,
          divider: _divider,
          success: _success,
          danger: _danger,
        ),
      ],
    );
  }
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.accent,
    required this.surfaceAlt,
    required this.divider,
    required this.success,
    required this.danger,
  });

  final Color accent;
  final Color surfaceAlt;
  final Color divider;
  final Color success;
  final Color danger;

  @override
  AppThemeColors copyWith({
    Color? accent,
    Color? surfaceAlt,
    Color? divider,
    Color? success,
    Color? danger,
  }) {
    return AppThemeColors(
      accent: accent ?? this.accent,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      success: Color.lerp(success, other.success, t) ?? success,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}
