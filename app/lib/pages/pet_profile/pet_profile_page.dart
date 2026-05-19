import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/vc_wordmark.dart';
import '../../models/consultation.dart';
import 'pet_profile_controller.dart';

class PetProfilePage extends StatelessWidget {
  PetProfilePage({super.key});

  final PetProfileController ctrl = Get.put(PetProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top nav ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
                      child: const Icon(Icons.chevron_left, size: 18, color: Colors.black),
                    ),
                  ),
                  const VcWordmark(),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
                    child: const Icon(Icons.more_horiz, size: 18, color: Colors.black),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
                onRefresh: ctrl.loadConsultations,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Obx(() {
                    final pet = ctrl.pet.value;
                    if (pet == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hero / photo area ────────────────────
                        Container(
                          height: 260,
                          margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              // Pet image or diagonal stripes bg
                              if (pet.photoUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(pet.photoUrl!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                )
                              else
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 260),
                                    painter: _StripePainter(),
                                  ),
                                ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                                    stops: const [0.4, 1.0],
                                  ),
                                ),
                              ),
                              // Age tag
                              Positioned(
                                top: 14, left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(999)),
                                  child: Text('${pet.ageYears}Y',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.white)),
                                ),
                              ),
                              // Name + species at bottom
                              Positioned(
                                left: 16, right: 16, bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pet.name,
                                        style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700,
                                            letterSpacing: -0.04 * 28, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('${pet.speciesName ?? ''} · ${pet.sexCode ?? '?'}',
                                        style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.1,
                                            color: Colors.white.withValues(alpha: 0.7))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Stats row ────────────────────────────
                        Container(
                          margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              _StatCell(value: '${pet.ageYears}Y', label: 'AGE', isLast: false),
                              _StatCell(value: pet.weightKg != null ? '${pet.weightKg!.toStringAsFixed(1)} KG' : '—', label: 'WEIGHT', isLast: false),
                              _StatCell(value: pet.isExotic ? 'EXOTIC' : 'DOMESTIC', label: 'TYPE', isLast: true),
                            ],
                          ),
                        ),

                        // ── Consultation history ─────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                          child: Text('CONSULTATION HISTORY',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                        ),

                        if (ctrl.isLoading.value)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5)),
                          )
                        else if (ctrl.consultations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(child: Text('No consultations yet.',
                                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.black.withValues(alpha: 0.45)))),
                          )
                        else
                          ...ctrl.consultations.map((c) => _ConsultationRow(c: c)),

                        const SizedBox(height: 40),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  final bool isLast;
  const _StatCell({required this.value, required this.label, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(right: isLast ? BorderSide.none : const BorderSide(color: Colors.black)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700,
                letterSpacing: -0.03 * 18, color: Colors.black)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, letterSpacing: 0.16,
                color: Colors.black.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

class _ConsultationRow extends StatelessWidget {
  final Consultation c;
  const _ConsultationRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/clinical-history', arguments: c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black))),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.scheduledAt.day.toString().padLeft(2, '0')} ${_monthName(c.scheduledAt.month)} ${c.scheduledAt.year}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.12, color: Colors.black.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 4),
                Text(c.diagnosis ?? c.reason ?? 'Consultation',
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: c.status == 'completed' ? Colors.black : Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(c.status.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.16,
                      color: c.status == 'completed' ? Colors.white : Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[m];
  }
}

// Diagonal stripe painter
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    const spacing = 22.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
