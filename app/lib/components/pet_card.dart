import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetCard extends StatelessWidget {
  final String name;
  final String species;
  final String breed;
  final String sex;
  final int ageYears;
  final int ageMonths;
  final String status; // 'active', 'vaccinating', 'pending'
  final VoidCallback onTap;
  final String? photoUrl;

  const PetCard({
    super.key,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.ageYears,
    required this.ageMonths,
    this.status = 'active',
    required this.onTap,
    this.photoUrl,
  });

  Color _getStatusColor(Color fallback) {
    switch (status) {
      case 'vaccinating':
        return const Color(0xFFFF9500);
      case 'pending':
        return const Color(0xFFFF3B30);
      default:
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: fg, width: 1),
          borderRadius: BorderRadius.circular(12),
          color: bg,
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Photo or icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: fg, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: fg.withValues(alpha: 0.08),
                    ),
                    child: photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(photoUrl!, fit: BoxFit.cover),
                          )
                        : const Center(child: Icon(Icons.pets, size: 28)),
                  ),
                  const SizedBox(width: 12),

                  // Pet info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$breed · $sex',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: fg.withValues(alpha: 0.55),
                            letterSpacing: 0.08,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: fg, width: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ageYears > 0 ? '$ageYears y' : '${ageMonths}mo',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),

            // Age tag (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: fg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ageYears > 0 ? '$ageYears' : '${ageMonths}m',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: bg,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),

            // Status pulse (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(fg),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(fg).withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: status != 'active' ? _buildPulseAnimation(fg) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseAnimation(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.scale(
            scale: 1 + value * 0.5,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Loop animation
      },
    );
  }
}
