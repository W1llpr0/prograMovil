import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/vc_wordmark.dart';
import '../../models/consultation.dart';
import 'vet_dashboard_controller.dart';

class VetDashboardPage extends StatelessWidget {
  VetDashboardPage({super.key});

  final VetDashboardController ctrl = Get.put(VetDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
                    child: const Icon(Icons.menu, size: 18, color: Colors.black),
                  ),
                  const VcWordmark(),
                  Container(
                    width: 38, height: 38,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: Center(
                      child: Obx(() {
                        final u = ctrl.appCtrl.currentUser.value;
                        final initials = u != null ? '${u.firstName[0]}${u.lastName[0]}'.toUpperCase() : 'RP';
                        return Text(initials, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white));
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
                onRefresh: ctrl.loadAgenda,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Vet header ──────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TUESDAY · 19 MAY · LIMA',
                                style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                                    color: Colors.black.withValues(alpha: 0.55))),
                            const SizedBox(height: 10),
                            Obx(() {
                              final lastName = ctrl.appCtrl.currentUser.value?.lastName ?? 'Paz';
                              return RichText(
                                text: TextSpan(children: [
                                  TextSpan(text: 'Dr. $lastName·\n',
                                      style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                                          letterSpacing: -0.04 * 38, height: 0.92, color: Colors.black)),
                                  TextSpan(text: 'agenda.',
                                      style: GoogleFonts.instrumentSerif(fontSize: 38, fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w400, letterSpacing: -0.02 * 38, height: 1.0, color: Colors.black)),
                                ]),
                              );
                            }),
                            const SizedBox(height: 10),
                            Text('CMP-8472 · Exotics · 14Y experience',
                                style: GoogleFonts.spaceGrotesk(fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.55))),
                          ],
                        ),
                      ),

                      // ── KPI stats strip ─────────────────
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.black), bottom: BorderSide(color: Colors.black)),
                        ),
                        child: Row(
                          children: [
                            _Stat(value: '07', label: 'TODAY', isLast: false),
                            _Stat(value: '02', label: 'COMPLETED', isLast: false),
                            _Stat(value: '01', label: 'IN PROGRESS', isLast: false),
                            _Stat(value: '04', label: 'PENDING', isLast: true),
                          ],
                        ),
                      ),

                      // ── Week strip ──────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                        child: Row(
                          children: [
                            _DayChip(day: 'MON', date: '18', active: false),
                            _DayChip(day: 'TUE', date: '19', active: true),
                            _DayChip(day: 'WED', date: '20', active: false),
                            _DayChip(day: 'THU', date: '21', active: false),
                            _DayChip(day: 'FRI', date: '22', active: false),
                            _DayChip(day: 'SAT', date: '23', active: false),
                            _DayChip(day: 'SUN', date: '24', active: false),
                          ],
                        ),
                      ),

                      // ── Timeline ────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 4),
                        child: Text('TIMELINE',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                                color: Colors.black.withValues(alpha: 0.55))),
                      ),

                      Obx(() {
                        if (ctrl.isLoading.value) {
                          return const SizedBox(height: 100,
                              child: Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5)));
                        }
                        if (ctrl.agenda.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(child: Text('No appointments scheduled.',
                                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.black.withValues(alpha: 0.45)))),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(22, 14, 22, 80),
                          child: Column(
                            children: [
                              for (int i = 0; i < ctrl.agenda.length; i++)
                                _TimelineSlot(
                                  c: ctrl.agenda[i],
                                  isLast: i == ctrl.agenda.length - 1,
                                  onTap: () => ctrl.goToRegister(ctrl.agenda[i]),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom nav ──────────────────────────────────
      bottomNavigationBar: _BottomNav(ctrl: ctrl),
    );
  }
}

// ── KPI stat cell ─────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String value, label;
  final bool isLast;
  const _Stat({required this.value, required this.label, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border(right: isLast ? BorderSide.none : const BorderSide(color: Colors.black)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700,
                letterSpacing: -0.04 * 22, color: Colors.black)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, letterSpacing: 0.14,
                color: Colors.black.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

// ── Day chip ─────────────────────────────────────────────────────
class _DayChip extends StatelessWidget {
  final String day, date;
  final bool active;
  const _DayChip({required this.day, required this.date, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 64,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.14,
              color: (active ? Colors.white : Colors.black).withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(date, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}

// ── Timeline appointment slot ──────────────────────────────────────
class _TimelineSlot extends StatelessWidget {
  final Consultation c;
  final VoidCallback onTap;
  final bool isLast;
  const _TimelineSlot({required this.c, required this.onTap, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isInProgress = c.status == 'in_progress';
    final isCompleted = c.status == 'completed';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.scheduledAt != null
                        ? '${c.scheduledAt!.hour.toString().padLeft(2, '0')}:${c.scheduledAt!.minute.toString().padLeft(2, '0')}'
                        : '--:--',
                    style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  Text('30 MIN', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.12, color: Colors.black.withValues(alpha: 0.55))),
                ],
              ),
            ),
          ),
          // Spine + node
          Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.black : Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 9, color: Colors.white)
                    : isInProgress
                        ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)))
                        : null,
              ),
              if (!isLast) Expanded(child: Container(width: 1, color: Colors.black)),
            ],
          ),
          const SizedBox(width: 14),
          // Card
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isInProgress ? Colors.black : Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.petName ?? 'Unknown',
                            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600,
                                color: isInProgress ? Colors.white : Colors.black)),
                        _StatusBadge(status: c.status ?? 'pending', inProgress: isInProgress),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.petName != null ? 'Owner · ${c.petName}' : '',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.06,
                            color: (isInProgress ? Colors.white : Colors.black).withValues(alpha: 0.55))),
                    if (isInProgress) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text('NOTES', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: const StadiumBorder(),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text('OPEN RECORD', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool inProgress;
  const _StatusBadge({required this.status, required this.inProgress});

  @override
  Widget build(BuildContext context) {
    final (label, filled, dashed) = switch (status) {
      'completed' => ('COMPLETED', true, false),
      'in_progress' => ('IN PROGRESS', false, false),
      _ => ('PENDING', false, true),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? Colors.white : Colors.transparent,
        border: Border.all(
          color: inProgress ? Colors.white : Colors.black,
          style: dashed ? BorderStyle.solid : BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18,
              color: inProgress ? Colors.white : (filled ? Colors.black : Colors.black))),
    );
  }
}

// ── Bottom navigation bar ──────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final VetDashboardController ctrl;
  const _BottomNav({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 1))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.calendar_today_outlined, label: 'AGENDA', selected: true),
              _NavItem(icon: Icons.pets_outlined, label: 'PATIENTS', selected: false, onTap: () {}),
              _NavItem(icon: Icons.bar_chart_outlined, label: 'REPORTS', selected: false, onTap: () {}),
              _NavItem(icon: Icons.person_outline, label: 'PROFILE', selected: false, onTap: ctrl.goToProfile),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.black.withValues(alpha: 0.35);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18, color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}
