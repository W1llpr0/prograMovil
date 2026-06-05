import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../models/consultation.dart';
import 'register_medical_controller.dart';

class RegisterMedicalPage extends StatelessWidget {
  RegisterMedicalPage({super.key});

  final RegisterMedicalController ctrl = Get.put(RegisterMedicalController());

  @override
  Widget build(BuildContext context) {
    final Consultation? c = Get.arguments as Consultation?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top nav ───────────────────────────────────────
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
                  Text('MEDICAL RECORD', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('REGISTER', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                        color: Colors.black.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: c?.petName != null ? '${c!.petName}·\n' : 'Record·\n',
                          style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                              letterSpacing: -0.04 * 38, height: 0.92, color: Colors.black),
                        ),
                        TextSpan(text: 'new entry.',
                            style: GoogleFonts.instrumentSerif(fontSize: 36, fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400, letterSpacing: -0.02 * 36, height: 1.0, color: Colors.black)),
                      ]),
                    ),

                    // ── Vitals grid ─────────────────────────────
                    const SizedBox(height: 28),
                    Text('VITALS', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _VitalCard(label: 'TEMP °C', ctrl: ctrl.tempCtrl, hint: '38.5')),
                        const SizedBox(width: 12),
                        Expanded(child: _VitalCard(label: 'WEIGHT KG', ctrl: ctrl.weightCtrl, hint: '12.4')),
                        const SizedBox(width: 12),
                        Expanded(child: _VitalCard(label: 'HR BPM', ctrl: ctrl.hrCtrl, hint: '90')),
                        const SizedBox(width: 12),
                        Expanded(child: _VitalCard(label: 'RR /MIN', ctrl: ctrl.rrCtrl, hint: '22')),
                      ],
                    ),

                    Container(height: 1, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 22)),

                    // ── Diagnosis ────────────────────────────────
                    LineInput(
                      label: 'DIAGNOSIS',
                      hint: 'Primary diagnosis...',
                      controller: ctrl.diagnosisCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),
                    LineInput(
                      label: 'TREATMENT',
                      hint: 'Prescribed treatment...',
                      controller: ctrl.treatmentCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),
                    LineInput(
                      label: 'NOTES',
                      hint: 'Additional observations...',
                      controller: ctrl.notesCtrl,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 22),

                    // Contagious toggle
                    Obx(() => GestureDetector(
                      onTap: () => ctrl.isContagious.toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black), bottom: BorderSide(color: Colors.black))),
                        child: Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CONTAGIOUS', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                                const SizedBox(height: 2),
                                Text('Mark if this condition is contagious', style: GoogleFonts.spaceGrotesk(fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.55))),
                              ],
                            )),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              width: 50, height: 28,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: ctrl.isContagious.value ? Colors.black : Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOut,
                                alignment: ctrl.isContagious.value ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: ctrl.isContagious.value ? Colors.white : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 32),

                    Obx(() => MonochromeButton(
                      label: ctrl.isLoading.value ? 'SAVING...' : 'SAVE & GENERATE HASH →',
                      filled: true,
                      onPressed: ctrl.isLoading.value ? null : () => ctrl.save(),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  const _VitalCard({required this.label, required this.ctrl, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, letterSpacing: 0.16,
              color: Colors.black.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.25)),
            ),
          ),
        ],
      ),
    );
  }
}
