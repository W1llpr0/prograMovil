import 'package:flutter/material.dart';

/// Strictly monochrome theme — inspired by the VetCare design system.
/// Light: white background, black text/borders.
/// Dark : black background, white text/borders.
class AppTheme {
  static const _fontFamily = 'SpaceGrotesk';

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: Colors.white,
        surface: Colors.white,
        onBackground: Colors.black,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: Colors.black,
        surface: Colors.black,
        onBackground: Colors.white,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onBackground,
  }) {
    final border = BorderSide(color: onBackground, width: 1);

    return ThemeData(
      brightness: brightness,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: onBackground,
        onPrimary: background,
        secondary: onBackground,
        onSecondary: background,
        error: onBackground,
        onError: background,
        surface: surface,
        onSurface: onBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.03,
          color: onBackground,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: onBackground,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.22,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBackground,
          side: border,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.22,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: border),
        enabledBorder: UnderlineInputBorder(borderSide: border),
        focusedBorder: UnderlineInputBorder(borderSide: border),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 10,
          letterSpacing: 0.22,
          color: onBackground.withValues(alpha: 0.55),
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: onBackground.withValues(alpha: 0.35),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, letterSpacing: -0.04, color: onBackground),
        titleLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, letterSpacing: -0.03, color: onBackground),
        bodyLarge: TextStyle(fontFamily: _fontFamily, color: onBackground),
        bodyMedium: TextStyle(fontFamily: _fontFamily, color: onBackground),
        labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 10, letterSpacing: 0.22, color: onBackground.withValues(alpha: 0.55)),
      ),
      dividerTheme: DividerThemeData(color: onBackground.withValues(alpha: 0.12), thickness: 1, space: 0),
      cardTheme: CardThemeData(
        color: background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: onBackground.withValues(alpha: 0.12), width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: onBackground,
        unselectedItemColor: onBackground.withValues(alpha: 0.35),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 0.22, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 0.22),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? background : onBackground),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onBackground : onBackground.withValues(alpha: 0.2)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onBackground : Colors.transparent),
        checkColor: WidgetStateProperty.all(background),
        side: BorderSide(color: onBackground, width: 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}
