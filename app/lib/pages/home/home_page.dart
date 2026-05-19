import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/vc_wordmark.dart';
import '../../components/swipe_to_confirm.dart';
import '../../models/pet.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController ctrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const VcWordmark(),
                  GestureDetector(
                    onTap: ctrl.goToProfile,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Icons.person_outline, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
                onRefresh: ctrl.loadPets,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tuesday · 19 May',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10,
                                letterSpacing: 0.18,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() {
                              final name = ctrl.appCtrl.currentUser.value?.firstName ?? '';
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Good morning,\n',
                                      style: GoogleFonts.spaceGrotesk(fontSize: 38,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.04 * 38,
                                        height: 0.92,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: name.isEmpty ? 'there.' : '$name.',
                                      style: GoogleFonts.instrumentSerif(
                                        fontSize: 38,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.02 * 38,
                                        height: 0.92,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      // ── Adherence widget ──────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NEXT DOSE · IN 04:12',
                                        style: GoogleFonts.jetBrainsMono(fontSize: 10,
                                          letterSpacing: 0.18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Apoquel 16 mg',
                                        style: GoogleFonts.spaceGrotesk(fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.03 * 26,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Max · 1 tablet · with food',
                                        style: GoogleFonts.spaceGrotesk(fontSize: 12,
                                          color: Colors.black.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Icon(Icons.medication_outlined, size: 20, color: Colors.black),
                                  ),
                                ],
                              ),

                              // 14-day adherence bar ladder
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 28,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    for (final h in [0.6, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.0, 0.8, 1.0, 1.0, 1.0, 1.0, 0.7]) ...[
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: h < 0.06 ? 0.06 : h,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: h == 0 ? Colors.transparent : Colors.black,
                                                border: h == 0 ? Border.all(color: Colors.black, width: 1) : null,
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '14-DAY ADHERENCE',
                                    style: GoogleFonts.jetBrainsMono(fontSize: 9,
                                      letterSpacing: 0.18,
                                      color: Colors.black.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  Text(
                                    '92%',
                                    style: GoogleFonts.jetBrainsMono(fontSize: 9,
                                      letterSpacing: 0.06,
                                      color: Colors.black.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Swipe to confirm
                              Obx(() => SwipeToConfirm(
                                    label: 'SWIPE TO CONFIRM DOSE',
                                    done: ctrl.doseDone.value,
                                    onDone: () => ctrl.doseDone.value = true,
                                  )),
                            ],
                          ),
                        ),
                      ),

                      // ── Pets section header ───────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text(
                                      '${ctrl.pets.length.toString().padLeft(2, '0')} / ${ctrl.pets.length.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10,
                                        letterSpacing: 0.18,
                                        color: Colors.black.withValues(alpha: 0.55),
                                      ),
                                    )),
                                Text(
                                  'Your pets',
                                  style: GoogleFonts.spaceGrotesk(fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.04 * 28,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: ctrl.goToAddPet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'ADD',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10,
                                        letterSpacing: 0.12,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.add, size: 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Pet carousel (horizontal scroll, dark cards) ──
                      Obx(() {
                        if (ctrl.isLoading.value) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5)),
                          );
                        }
                        if (ctrl.pets.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'No pets yet.\nTap ADD to register your first pet.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(fontSize: 13,
                                  height: 1.6,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                            itemCount: ctrl.pets.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) => _DarkPetCard(
                              pet: ctrl.pets[i],
                              onTap: () => ctrl.goToPetProfile(ctrl.pets[i]),
                            ),
                          ),
                        );
                      }),

                      // ── Upcoming appointments ─────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPCOMING',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10,
                                letterSpacing: 0.18,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _AppointmentRow(
                              date: '21 MAY', time: '10:30',
                              title: 'Annual checkup · Max', who: 'Dr. R. Paz',
                            ),
                            _AppointmentRow(
                              date: '24 MAY', time: '17:00',
                              title: 'Consultation · Donatello', who: 'Dr. R. Paz',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Floating epidemic alert ──────────────────────
      floatingActionButton: _EpidemicAlert(onTap: ctrl.goToAlerts),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Dark pet card ───────────────────────────────────────────────────
class _DarkPetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  const _DarkPetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Diagonal stripe texture (BWphoto effect)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: pet.photoUrl != null
                    ? Image.network(pet.photoUrl!, fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.35),
                        colorBlendMode: BlendMode.darken)
                    : CustomPaint(painter: _StripePainter()),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Age tag top-left
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pet.birthDate != null ? _calcAge(pet.birthDate!) : '–',
                      style: GoogleFonts.jetBrainsMono(fontSize: 9,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    pet.name,
                    style: GoogleFonts.spaceGrotesk(fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.03 * 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.speciesName ?? 'Unknown'} · ${pet.sexCode ?? '?'}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.06,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ON TREATMENT',
                        style: GoogleFonts.jetBrainsMono(fontSize: 9,
                          letterSpacing: 0.14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calcAge(DateTime dob) {
    final now = DateTime.now();
    final years = now.year - dob.year;
    if (years > 0) return '${years.toString().padLeft(2, '0')} YRS';
    final months = now.month - dob.month + (now.year - dob.year) * 12;
    return '${months.toString().padLeft(2, '0')} MO';
  }
}

// Diagonal stripe painter for dark cards without photos
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2A2A2A)..strokeWidth = 2;
    for (double i = -size.height; i < size.width + size.height; i += 6) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter _) => false;
}

// ── Appointment row ─────────────────────────────────────────────────
class _AppointmentRow extends StatelessWidget {
  final String date, time, title, who;
  final bool isLast;
  const _AppointmentRow({
    required this.date, required this.time,
    required this.title, required this.who,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: Colors.black, width: 1),
          bottom: isLast ? const BorderSide(color: Colors.black, width: 1) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.12, color: Colors.black)),
                const SizedBox(height: 2),
                Text(time, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.03 * 18, color: Colors.black)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 2),
                Text(who, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.06, color: Colors.black.withValues(alpha: 0.55))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.black),
        ],
      ),
    );
  }
}

// ── Floating epidemic alert ─────────────────────────────────────────
class _EpidemicAlert extends StatelessWidget {
  final VoidCallback onTap;
  const _EpidemicAlert({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '● GEOFENCE · ACTIVE OUTBREAK · 1.2 KM',
                    style: GoogleFonts.jetBrainsMono(fontSize: 9,
                      letterSpacing: 0.14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Canine parvovirus reported nearby.',
                    style: GoogleFonts.spaceGrotesk(fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.03 * 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Limit walks · 14 cases / 72 h',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
