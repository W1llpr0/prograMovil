import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primary action button — pill shaped (radius 999), monochrome.
/// filled = true  → black fill, white label (primary)
/// filled = false → outlined, transparent fill (secondary)
class MonochromeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isLoading;

  const MonochromeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: filled ? cs.onPrimary : cs.primary,
            ),
          )
        : Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.26,
            ),
          );

    if (filled) {
      return SizedBox(
        width: double.infinity,
        height: 62,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary, width: 1),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
