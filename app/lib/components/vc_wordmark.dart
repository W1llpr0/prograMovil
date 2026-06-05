import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VetCare wordmark — logo + "VetCare" text side by side.
/// Use [dark] = true for white on black backgrounds.
class VcWordmark extends StatelessWidget {
  final bool dark;
  final double size;

  const VcWordmark({super.key, this.dark = false, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/vetcare_logo.png',
          width: size,
          height: size,
          color: fg,
        ),
        const SizedBox(width: 8),
        Text(
          'VetCare',
          style: GoogleFonts.spaceGrotesk(fontSize: size * 0.82,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.04 * size,
            color: fg,
            height: 1,
          ),
        ),
      ],
    );
  }
}
