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
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bg,
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
                      decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(999)),
                      child: Icon(Icons.chevron_left, size: 18, color: fg),
                    ),
                  ),
                  const VcWordmark(),
                  PopupMenuButton<String>(
                    icon: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(999)),
                      child: Icon(Icons.more_horiz, size: 18, color: fg),
                    ),
                    color: bg,
                    onSelected: (value) {
                      if (value == 'photo') ctrl.updatePetPhoto();
                      if (value == 'delete') _confirmDelete(context);
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'photo',
                        child: Row(children: [
                          Icon(Icons.photo_camera_outlined, size: 18, color: fg),
                          const SizedBox(width: 10),
                          Text('change_photo'.tr, style: GoogleFonts.spaceGrotesk(color: fg)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          const SizedBox(width: 10),
                          Text('delete_pet'.tr, style: GoogleFonts.spaceGrotesk(color: Colors.red)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: fg,
                backgroundColor: bg,
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
                            color: fg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
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
                              Positioned(
                                top: 14, left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(999)),
                                  child: Text('${pet.ageYears}Y',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.white)),
                                ),
                              ),
                              Positioned(
                                left: 16, right: 16, bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pet.name,
                                        style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700,
                                            letterSpacing: -0.04 * 28, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('${pet.speciesName ?? ''} · ${pet.sexId ?? '?'}',
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
                          decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              _StatCell(value: '${pet.ageYears}Y', label: 'AGE', isLast: false, fg: fg),
                              _StatCell(value: pet.weightKg != null ? '${pet.weightKg!.toStringAsFixed(1)} KG' : '—', label: 'WEIGHT', isLast: false, fg: fg),
                              _StatCell(value: pet.breedName ?? '—', label: 'BREED', isLast: true, fg: fg),
                            ],
                          ),
                        ),

                        // ── Consultation history ─────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                          child: Text('CONSULTATION HISTORY',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
                        ),

                        Obx(() {
                          if (ctrl.isLoading.value) {
                            return Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator(color: fg, strokeWidth: 1.5)),
                            );
                          }
                          if (ctrl.consultations.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(child: Text('No consultations yet.',
                                  style: GoogleFonts.spaceGrotesk(fontSize: 13, color: fg.withValues(alpha: 0.45)))),
                            );
                          }
                          return Column(
                            children: ctrl.consultations.map((c) => _ConsultationRow(c: c, fg: fg, bg: bg)).toList(),
                          );
                        }),

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

  void _confirmDelete(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        title: Text('confirm_delete'.tr, style: GoogleFonts.spaceGrotesk(color: fg, fontWeight: FontWeight.w700)),
        content: Text('confirm_delete_pet_msg'.tr, style: GoogleFonts.spaceGrotesk(color: fg.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: GoogleFonts.spaceGrotesk(color: fg)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.deletePet();
            },
            child: Text('delete_pet'.tr, style: GoogleFonts.spaceGrotesk(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  final bool isLast;
  final Color fg;
  const _StatCell({required this.value, required this.label, required this.isLast, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(right: isLast ? BorderSide.none : BorderSide(color: fg)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.03 * 16,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, letterSpacing: 0.16,
                color: fg.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

class _ConsultationRow extends StatelessWidget {
  final Consultation c;
  final Color fg;
  final Color bg;
  const _ConsultationRow({required this.c, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/clinical-history', arguments: c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: fg))),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.scheduledAt.day.toString().padLeft(2, '0')} ${_monthName(c.scheduledAt.month)} ${c.scheduledAt.year}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.12, color: fg.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 4),
                Text(c.diagnosis ?? c.reason ?? 'Consultation',
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500, color: fg)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: c.status == 'completed' ? fg : bg,
                border: Border.all(color: fg),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(c.status.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.16,
                      color: c.status == 'completed' ? bg : fg)),
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