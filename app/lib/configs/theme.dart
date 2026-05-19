import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Strictly monochrome theme — inspired by the VetCare design system.
/// Light: white background, black text/borders.
/// Dark : black background, white text/borders.
class AppTheme {
  // Keep this for any legacy,references
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
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.03 * 15,
          color: onBackground,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: onBackground,
          foregroundColor: background,
          elevation: 0,
          minimumSize: const Size(double.infinity, 62),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.26,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBackground,
          side: border,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.22,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: border),
        enabledBorder: UnderlineInputBorder(borderSide: border),
        focusedBorder: UnderlineInputBorder(borderSide: border),
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          letterSpacing: 0.22,
          color: onBackground.withValues(alpha: 0.55),
        ),
        hintStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: onBackground.withValues(alpha: 0.35),
        ),
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.04 * 50, color: onBackground),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.03 * 22, color: onBackground),
        bodyLarge: TextStyle(color: onBackground),
        bodyMedium: TextStyle(color: onBackground),
        labelSmall: TextStyle(fontSize: 10, letterSpacing: 0.22, color: onBackground.withValues(alpha: 0.55)),
      )),
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
        selectedLabelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.22, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.22),
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
