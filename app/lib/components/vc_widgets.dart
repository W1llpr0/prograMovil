import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Section header with the VetCare typography — MONO EYEBROW label above
/// a large display title.
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(fontSize: 9,
                    letterSpacing: 0.32,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04,
                    height: 0.95,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 1px bordered card tile
class BorderTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const BorderTile({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1),
        ),
        child: child,
      ),
    );
  }
}

/// Mono eyebrow + value row
class VcDataRow extends StatelessWidget {
  final String label;
  final String value;

  const VcDataRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(fontSize: 9,
              letterSpacing: 0.22,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.02,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small monochrome badge chip
class MonoBadge extends StatelessWidget {
  final String label;
  const MonoBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: cs.onSurface, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(fontSize: 9,
          letterSpacing: 0.22,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
    );
  }
}
