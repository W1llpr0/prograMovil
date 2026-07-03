import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/vc_wordmark.dart';
import '../../models/consultation.dart';
import 'clinical_history_controller.dart';

class ClinicalHistoryPage extends StatelessWidget {
  ClinicalHistoryPage({super.key});

  final ClinicalHistoryController ctrl = Get.put(ClinicalHistoryController());

  @override
  Widget build(BuildContext context) {
    final Consultation? c = Get.arguments as Consultation?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header nav ─────────────────────────────────
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Appointment eyebrow ─────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c != null
                                ? 'APPOINTMENT · ${c.scheduledAt.day.toString().padLeft(2, '0')} ${_monthName(c.scheduledAt.month).toUpperCase()} ${c.scheduledAt.year} · ${c.status.toUpperCase()}'
                                : 'APPOINTMENT · 14 MAY 2026 · COMPLETED',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                                color: Colors.black.withValues(alpha: 0.55)),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: c?.diagnosis != null ? _firstWord(c!.diagnosis!) : 'Atopic\ndermatitis.',
                                style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                                    letterSpacing: -0.04 * 38, height: 0.95, color: Colors.black),
                              ),
                              TextSpan(
                                text: c?.diagnosis != null && c!.diagnosis!.split(' ').length > 1
                                    ? ' ${c.diagnosis!.split(' ').skip(1).join(' ')}.'
                                    : ' flare-up.',
                                style: GoogleFonts.instrumentSerif(fontSize: 32, fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400, letterSpacing: -0.02 * 32, color: Colors.black),
                              ),
                            ]),
                          ),

                          // Tag chips
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (c?.petName != null) _Chip(c!.petName!.toUpperCase()),
                              const _Chip('CHRONIC'),
                              const _Chip('GRADE II'),
                              const _Chip('FOLLOW-UP · 14 D'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Doctor card ────────────────────────────────
                    Container(
                      margin: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                c?.vetName != null ? c!.vetName![0].toUpperCase() : 'RP',
                                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c?.vetName != null ? 'Dr. ${c!.vetName}' : 'Dr. Rodrigo Paz',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                const SizedBox(height: 4),
                                Text('Exotics & Small Animals · Lic. BO-08214',
                                    style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.08,
                                        color: Colors.black.withValues(alpha: 0.55))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
                            child: Text('SIGNED', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.16, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),

                    // ── Diagnosis text ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DIAGNOSIS', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                          const SizedBox(height: 8),
                          Text(
                            c?.diagnosis ??
                                'Bilateral pododermatitis with secondary Malassezia infection. Score 4/10 on the canine atopic dermatitis extent index. Triggered by new environmental allergen exposure during March–April.',
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, height: 1.55, color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                    // Hair line
                    Container(height: 1, color: Colors.black, margin: const EdgeInsets.fromLTRB(22, 22, 22, 22)),

                    // ── Treatment list ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Text('PRESCRIBED TREATMENT · 06 ITEMS',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                    ),
                    const SizedBox(height: 12),

                    const _RxRow(code: 'RX 01', name: 'Apoquel 16 mg', regime: '1 tab / 24 h · 14 days', isFirst: true),
                    const _RxRow(code: 'RX 02', name: 'Malaseb shampoo', regime: 'Bathe / 72 h · 4 weeks', isFirst: false),
                    const _RxRow(code: 'RX 03', name: 'Omega-3 (EPA/DHA)', regime: '1 ml / 24 h · ongoing', isFirst: false),
                    const _RxRow(code: 'RX 04', name: 'Hypoallergenic diet', regime: 'Replace kibble · 60 days', isFirst: false),
                    Container(height: 1, color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 22)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m];
  }

  String _firstWord(String s) => s.split(' ').first;
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.16, color: Colors.black)),
    );
  }
}

class _RxRow extends StatelessWidget {
  final String code, name, regime;
  final bool isFirst;
  const _RxRow({required this.code, required this.name, required this.regime, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black))),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(code, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.16, color: Colors.black)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 3),
                Text(regime, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.04,
                    color: Colors.black.withValues(alpha: 0.55))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.black),
        ],
      ),
    );
  }
}
