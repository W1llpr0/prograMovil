import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/vc_wordmark.dart';
import '../../models/consultation.dart';
import '../profile/profile_page.dart';
import 'vet_dashboard_controller.dart';

class VetDashboardPage extends StatefulWidget {
  VetDashboardPage({super.key});

  @override
  State<VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<VetDashboardPage> {
  int _tab = 0;
  late VetDashboardController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.isRegistered<VetDashboardController>()
        ? Get.find<VetDashboardController>()
        : Get.put(VetDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _tab,
        children: [
          _buildAgendaTab(context, fg, bg),
          _buildPatientsTab(context, fg, bg),
          _buildReportsTab(context, fg, bg),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(fg, bg),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────
  Widget _buildBottomNav(Color fg, Color bg) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: fg, width: 1))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.calendar_today_outlined, 'AGENDA', 0, fg),
              _navItem(Icons.pets_outlined, 'PATIENTS', 1, fg),
              _navItem(Icons.bar_chart_outlined, 'REPORTS', 2, fg),
              _navItem(Icons.person_outline, 'PROFILE', 3, fg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, Color fg) {
    final selected = _tab == index;
    final color = selected ? fg : fg.withValues(alpha: 0.35);
    return GestureDetector(
      onTap: () {
        if (index == 2 && _tab != 2) ctrl.loadAvailability();
        setState(() => _tab = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  letterSpacing: 0.18,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }

  // ── AGENDA TAB ────────────────────────────────────────────────────
  Widget _buildAgendaTab(BuildContext context, Color fg, Color bg) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      border: Border.all(color: fg),
                      borderRadius: BorderRadius.circular(999)),
                  child: Icon(Icons.menu, size: 18, color: fg),
                ),
                const VcWordmark(),
                Obx(() {
                  final u = ctrl.appCtrl.currentUser.value;
                  final fn = u?.firstName ?? '';
                  final ln = u?.lastName ?? '';
                  final initials = fn.isNotEmpty && ln.isNotEmpty
                      ? '${fn[0]}${ln[0]}'.toUpperCase()
                      : fn.isNotEmpty ? fn[0].toUpperCase() : 'V';
                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                    child: Center(
                      child: Text(initials,
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600, fontSize: 12, color: bg)),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: fg,
              backgroundColor: bg,
              onRefresh: ctrl.loadAgenda,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vet header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE · d MMM · yyyy').format(DateTime.now()).toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                letterSpacing: 0.18,
                                color: fg.withValues(alpha: 0.55)),
                          ),
                          const SizedBox(height: 10),
                          Obx(() {
                            final lastName =
                                ctrl.appCtrl.currentUser.value?.lastName ?? '';
                            return RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Dr. $lastName·\n',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.04 * 38,
                                      height: 0.92,
                                      color: fg),
                                ),
                                TextSpan(
                                  text: 'agenda.',
                                  style: GoogleFonts.instrumentSerif(
                                      fontSize: 38,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.02 * 38,
                                      height: 1.0,
                                      color: fg),
                                ),
                              ]),
                            );
                          }),
                          const SizedBox(height: 10),
                          Obx(() {
                            final cmp = ctrl.licenseNumber.value.isNotEmpty
                                ? 'CMP-${ctrl.licenseNumber.value}'
                                : '';
                            final exp = ctrl.yearsExperience.value > 0
                                ? '${ctrl.yearsExperience.value}Y experience'
                                : '';
                            final subtitle =
                                [cmp, exp].where((s) => s.isNotEmpty).join(' · ');
                            return subtitle.isNotEmpty
                                ? Text(subtitle,
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        color: fg.withValues(alpha: 0.55)))
                                : const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),

                    // KPI stats strip
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: fg),
                                bottom: BorderSide(color: fg)),
                          ),
                          child: Row(
                            children: [
                              _statCell(ctrl.todayTotal.toString().padLeft(2, '0'),
                                  'TODAY', fg, false),
                              _statCell(
                                  ctrl.completedCount.toString().padLeft(2, '0'),
                                  'COMPLETED',
                                  fg,
                                  false),
                              _statCell(
                                  ctrl.inProgressCount.toString().padLeft(2, '0'),
                                  'IN PROGRESS',
                                  fg,
                                  false),
                              _statCell(
                                  ctrl.pendingCount.toString().padLeft(2, '0'),
                                  'PENDING',
                                  fg,
                                  true),
                            ],
                          ),
                        )),

                    // Date strip (current week)
                    Obx(() {
                      final today = DateTime.now();
                      final monday = today.subtract(Duration(days: today.weekday - 1));
                      final days = List.generate(7, (i) => monday.add(Duration(days: i)));
                      final selectedD = ctrl.selectedDate.value;
                      return SizedBox(
                        height: 88,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                          itemCount: days.length,
                          itemBuilder: (_, i) {
                            final d = days[i];
                            final isSelected = d.day == selectedD.day &&
                                d.month == selectedD.month &&
                                d.year == selectedD.year;
                            final isToday = d.day == today.day &&
                                d.month == today.month &&
                                d.year == today.year;
                            return GestureDetector(
                              onTap: () => ctrl.selectedDate.value = d,
                              child: Container(
                                width: 52,
                                height: 64,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? fg : Colors.transparent,
                                  border: Border.all(
                                    color: isToday ? fg : fg.withValues(alpha: 0.3),
                                    width: isToday ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(d).toUpperCase(),
                                      style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          letterSpacing: 0.14,
                                          color: (isSelected ? bg : fg)
                                              .withValues(alpha: 0.7)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${d.day}',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? bg : fg),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),

                    // Day summary card
                    Obx(() {
                      final d = ctrl.selectedDate.value;
                      final dayC = ctrl.selectedDateConsultations;
                      final completed =
                          dayC.where((c) => c.status == 'completed').length;
                      final inProg =
                          dayC.where((c) => c.status == 'in_progress').length;
                      final pending = dayC
                          .where((c) =>
                              c.status == 'scheduled' || c.status == 'pending')
                          .length;
                      final today = DateTime.now();
                      final isToday =
                          d.day == today.day && d.month == today.month;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: fg),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _kpiItem(
                                  isToday ? 'TODAY' : DateFormat('d MMM').format(d),
                                  '${dayC.length}',
                                  'appts',
                                  fg),
                              _kpiItem('✓', '$completed', 'done', fg),
                              _kpiItem('●', '$inProg', 'active', fg),
                              _kpiItem('○', '$pending', 'pending', fg),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Timeline header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                      child: Obx(() {
                        final today = DateTime.now();
                        final d = ctrl.selectedDate.value;
                        final isToday = d.day == today.day && d.month == today.month;
                        return Text(
                          isToday
                              ? 'TODAY\'S AGENDA'
                              : '${DateFormat('d MMM yyyy').format(d).toUpperCase()} AGENDA',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              letterSpacing: 0.18,
                              color: fg.withValues(alpha: 0.55)),
                        );
                      }),
                    ),

                    // Timeline
                    Obx(() {
                      final consultations = ctrl.selectedDateConsultations;
                      if (ctrl.isLoading.value) {
                        return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()));
                      }
                      if (consultations.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                          child: Center(
                            child: Text(
                              'No consultations for this day.',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13, color: fg.withValues(alpha: 0.5)),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 7,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                  width: 2, color: fg.withValues(alpha: 0.2)),
                            ),
                            Column(
                              children: [
                                for (int i = 0; i < consultations.length; i++)
                                  _buildTimelineItem(
                                      consultations[i],
                                      i == consultations.length - 1,
                                      fg,
                                      bg),
                              ],
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
    );
  }

  Widget _statCell(String value, String label, Color fg, bool isLast) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border(right: isLast ? BorderSide.none : BorderSide(color: fg)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04 * 22,
                    color: fg)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    letterSpacing: 0.14,
                    color: fg.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }

  Widget _kpiItem(String icon, String value, String label, Color fg) {
    return Column(
      children: [
        Text(icon,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 8, color: fg.withValues(alpha: 0.55), letterSpacing: 0.08)),
      ],
    );
  }

  Widget _buildTimelineItem(
      Consultation c, bool isLast, Color fg, Color bg) {
    final isCompleted = c.status == 'completed';
    final isInProgress = c.status == 'in_progress';
    final time =
        '${c.scheduledAt.hour.toString().padLeft(2, '0')}:${c.scheduledAt.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node
          SizedBox(
            width: 16,
            height: 60,
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isCompleted ? fg : bg,
                  border: Border.all(color: fg),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: isCompleted
                    ? Icon(Icons.check, size: 9, color: bg)
                    : isInProgress
                        ? Center(
                            child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: fg, shape: BoxShape.circle)))
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Card
          Expanded(
            child: GestureDetector(
              onTap: () => ctrl.goToRegister(c),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isInProgress ? fg : Colors.transparent,
                  border: Border.all(color: fg),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(time,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isInProgress ? bg : fg)),
                        _statusBadge(c.status, isInProgress, fg, bg),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.petName ?? 'Unknown pet',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isInProgress ? bg : fg)),
                    if (c.ownerName != null && c.ownerName!.isNotEmpty)
                      Text(c.ownerName!,
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              letterSpacing: 0.06,
                              color:
                                  (isInProgress ? bg : fg).withValues(alpha: 0.55))),
                    if (c.reason != null && c.reason!.isNotEmpty)
                      Text(c.reason!,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color:
                                  (isInProgress ? bg : fg).withValues(alpha: 0.7))),
                    if (isInProgress) ...[
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: bg,
                              side: BorderSide(color: bg),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text('NOTES',
                                style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    letterSpacing: 0.18,
                                    color: bg)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ctrl.goToRegister(c),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bg,
                              foregroundColor: fg,
                              shape: const StadiumBorder(),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text('OPEN RECORD',
                                style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    letterSpacing: 0.18,
                                    color: fg)),
                          ),
                        ),
                      ]),
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

  Widget _statusBadge(String status, bool inProgress, Color fg, Color bg) {
    final label = switch (status) {
      'completed' => 'COMPLETED',
      'in_progress' => 'IN PROGRESS',
      _ => 'PENDING',
    };
    final filled = status == 'completed';
    final textColor = inProgress ? bg : fg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled && !inProgress ? fg : Colors.transparent,
        border: Border.all(color: textColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (!filled)
          Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  color: status == 'in_progress' ? bg : fg,
                  shape: BoxShape.circle)),
        Text(label,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 0.18,
                color: filled && !inProgress ? bg : textColor)),
      ]),
    );
  }

  // ── PATIENTS TAB ──────────────────────────────────────────────────
  Widget _buildPatientsTab(BuildContext context, Color fg, Color bg) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PATIENTS',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        letterSpacing: 0.18,
                        color: fg.withValues(alpha: 0.55))),
                const SizedBox(height: 8),
                Obx(() {
                  final count = ctrl.patients.length;
                  return Text(
                    '$count patient${count == 1 ? '' : 's'}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.04 * 30,
                        color: fg),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: fg.withValues(alpha: 0.2)),
          Expanded(
            child: Obx(() {
              final patients = ctrl.patients;
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (patients.isEmpty) {
                return Center(
                  child: Text('No patients yet.',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13, color: fg.withValues(alpha: 0.5))),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 100),
                itemCount: patients.length,
                separatorBuilder: (_, __) =>
                    Divider(color: fg.withValues(alpha: 0.15), height: 1),
                itemBuilder: (_, i) {
                  final p = patients[i];
                  final lastDate = p['lastDate'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: fg.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: fg.withValues(alpha: 0.2)),
                          ),
                          child: Center(
                            child: Text(
                              (p['petName'] as String).isNotEmpty
                                  ? (p['petName'] as String)[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: fg),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['petName'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: fg)),
                              Text('${p['ownerName']}',
                                  style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: fg.withValues(alpha: 0.55))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${p['consultationCount']} visit${(p['consultationCount'] as int) == 1 ? '' : 's'}',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9, color: fg.withValues(alpha: 0.55)),
                            ),
                            Text(
                              DateFormat('d MMM').format(lastDate),
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9, color: fg.withValues(alpha: 0.55)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── REPORTS TAB ───────────────────────────────────────────────────
  Widget _buildReportsTab(BuildContext context, Color fg, Color bg) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REPORTS & SCHEDULE',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        letterSpacing: 0.18,
                        color: fg.withValues(alpha: 0.55))),
                const SizedBox(height: 8),
                Text('My practice.',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.04 * 30,
                        color: fg)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats grid
                  Obx(() {
                    final total = ctrl.totalConsultations;
                    final completed = ctrl.totalCompleted;
                    final rate =
                        total > 0 ? (completed / total * 100).round() : 0;
                    return Column(
                      children: [
                        Row(
                          children: [
                            _reportCard('TOTAL', '$total', 'consultations', fg, bg),
                            const SizedBox(width: 12),
                            _reportCard('COMPLETED', '$completed', 'all time', fg, bg),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _reportCard('RATE', '$rate%', 'completion', fg, bg),
                            const SizedBox(width: 12),
                            _reportCard(
                                'PATIENTS', '${ctrl.patients.length}', 'unique', fg, bg),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 32),

                  // Schedule management
                  Text('WEEKLY SCHEDULE',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          letterSpacing: 0.18,
                          color: fg.withValues(alpha: 0.55))),
                  const SizedBox(height: 8),
                  Text('Set your available hours for each day.',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13, color: fg.withValues(alpha: 0.7))),
                  const SizedBox(height: 16),
                  Obx(() => _buildScheduleGrid(context, fg, bg)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(
      String title, String value, String subtitle, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: fg.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    letterSpacing: 0.18,
                    color: fg.withValues(alpha: 0.55))),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04 * 28,
                    color: fg)),
            Text(subtitle,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9, color: fg.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleGrid(BuildContext context, Color fg, Color bg) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const dayValues = [1, 2, 3, 4, 5, 6, 0];
    return Column(
      children: [
        for (int i = 0; i < 7; i++) ...[
          _buildDayRow(context, days[i], dayValues[i], fg, bg),
          if (i < 6) Divider(color: fg.withValues(alpha: 0.1), height: 1),
        ],
      ],
    );
  }

  Widget _buildDayRow(
      BuildContext context, String day, int dayOfWeek, Color fg, Color bg) {
    final slot = ctrl.availability.firstWhere(
        (s) => s['day_of_week'] == dayOfWeek,
        orElse: () => {});
    final isActive = slot.isNotEmpty && slot['is_active'] == true;
    final start =
        slot['start_time']?.toString().substring(0, 5) ?? '09:00';
    final end = slot['end_time']?.toString().substring(0, 5) ?? '18:00';
    return GestureDetector(
      onTap: () => _showAvailabilityEditor(context, day, dayOfWeek, fg, bg,
          currentStart: isActive ? start : '09:00',
          currentEnd: isActive ? end : '18:00'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(day,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      letterSpacing: 0.18,
                      fontWeight: FontWeight.w700,
                      color: fg)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: fg.withValues(alpha: 0.2)),
                      ),
                      child: Text('$start — $end',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 11, letterSpacing: 0.18, color: fg)),
                    )
                  : Text('Not available',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12, color: fg.withValues(alpha: 0.35))),
            ),
            const SizedBox(width: 12),
            Icon(Icons.edit_outlined, size: 16, color: fg.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityEditor(
      BuildContext context, String day, int dayOfWeek, Color fg, Color bg,
      {required String currentStart, required String currentEnd}) {
    final startCtrl = TextEditingController(text: currentStart);
    final endCtrl = TextEditingController(text: currentEnd);
    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$day SCHEDULE',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, letterSpacing: 0.18, color: fg)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('START',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              letterSpacing: 0.18,
                              color: fg.withValues(alpha: 0.55))),
                      TextField(
                        controller: startCtrl,
                        style: GoogleFonts.spaceGrotesk(fontSize: 18, color: fg),
                        decoration: InputDecoration(
                          hintText: '09:00',
                          hintStyle: GoogleFonts.spaceGrotesk(
                              fontSize: 18, color: fg.withValues(alpha: 0.3)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: fg.withValues(alpha: 0.3))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: fg)),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('END',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              letterSpacing: 0.18,
                              color: fg.withValues(alpha: 0.55))),
                      TextField(
                        controller: endCtrl,
                        style: GoogleFonts.spaceGrotesk(fontSize: 18, color: fg),
                        decoration: InputDecoration(
                          hintText: '18:00',
                          hintStyle: GoogleFonts.spaceGrotesk(
                              fontSize: 18, color: fg.withValues(alpha: 0.3)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: fg.withValues(alpha: 0.3))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: fg)),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fg,
                      side: BorderSide(color: fg.withValues(alpha: 0.3)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('CANCEL',
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 11, letterSpacing: 0.18, color: fg)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ctrl.saveAvailabilitySlot(
                        dayOfWeek: dayOfWeek,
                        startTime: startCtrl.text.trim(),
                        endTime: endCtrl.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fg,
                      foregroundColor: bg,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('SAVE',
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 11, letterSpacing: 0.18, color: bg)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


