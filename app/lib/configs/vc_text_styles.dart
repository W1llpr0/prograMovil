import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VetCare typography helpers — Space Grotesk + JetBrains Mono + Instrument Serif.
/// Use these instead of raw fontFamily strings throughout the app.
class VcT {
  VcT._();

  // ── Space Grotesk — main display font ──────────────────────────────
  static TextStyle display({double size = 50, Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.04 * size,
        height: 0.92,
        color: color,
      );

  static TextStyle hed({double size = 26, Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.03 * size,
        height: 1.0,
        color: color,
      );

  static TextStyle body({double size = 13, Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.01 * size,
        height: 1.4,
        color: color,
      );

  static TextStyle sg({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
        decoration: decoration,
      );

  // ── JetBrains Mono — eyebrows, labels, badges ──────────────────────
  static TextStyle eyebrow({double size = 10, Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.18,
        color: color,
      );

  static TextStyle mono({
    double size = 10,
    double letterSpacing = 0.06,
    FontWeight weight = FontWeight.w400,
    Color? color,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color,
        decoration: decoration,
      );

  // ── Instrument Serif — italic humanist accents ─────────────────────
  static TextStyle serif({double size = 38, Color? color}) => GoogleFonts.instrumentSerif(
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * size,
        height: 0.92,
        color: color,
      );
}
