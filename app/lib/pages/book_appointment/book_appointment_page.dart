import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import 'book_appointment_controller.dart';

class BookAppointmentPage extends StatelessWidget {
  BookAppointmentPage({super.key});

  final BookAppointmentController ctrl = Get.put(BookAppointmentController());

  static const List<String> _steps = ['PET', 'VET', 'DATE & TIME', 'CONFIRM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top nav ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: ctrl.step.value > 0 ? ctrl.prevStep : () => Get.back(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
                      child: const Icon(Icons.chevron_left, size: 18, color: Colors.black),
                    ),
                  ),
                  Text(
                    'STEP ${(ctrl.step.value + 1).toString().padLeft(2, '0')} / 04',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black),
                  ),
                  const SizedBox(width: 38),
                ],
              )),
            ),

            // Progress bar
            const SizedBox(height: 12),
            Obx(() => Row(
              children: [
                for (int i = 0; i < 4; i++)
                  Expanded(
                    child: Container(
                      height: 1,
                      color: i <= ctrl.step.value ? Colors.black : Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            )),

            Expanded(
              child: Obx(() => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_steps[ctrl.step.value],
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                            color: Colors.black.withValues(alpha: 0.55))),
                    const SizedBox(height: 10),
                    ..._stepContent(ctrl),
                  ],
                ),
              )),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Obx(() => MonochromeButton(
                label: ctrl.step.value < 3
                    ? 'CONTINUE →'
                    : (ctrl.isLoading.value ? 'BOOKING...' : 'CONFIRM BOOKING →'),
                filled: true,
                onPressed: ctrl.isLoading.value ? null : () {
                  if (ctrl.step.value < 3) {
                    ctrl.nextStep();
                  } else {
                    ctrl.submit();
                  }
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _stepContent(BookAppointmentController ctrl) {
    switch (ctrl.step.value) {
      case 0:
        return [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'Select\nyour ', style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700,
                letterSpacing: -0.04 * 36, height: 0.92, color: Colors.black)),
            TextSpan(text: 'pet.', style: GoogleFonts.instrumentSerif(fontSize: 34, fontStyle: FontStyle.italic,
                color: Colors.black, fontWeight: FontWeight.w400)),
          ])),
          const SizedBox(height: 28),
          if (ctrl.pets.isEmpty)
            Text('No pets found.', style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.black.withValues(alpha: 0.5)))
          else
            ...ctrl.pets.map((pet) => GestureDetector(
              onTap: () => ctrl.selectedPetId.value = pet.id ?? 0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ctrl.selectedPetId.value == (pet.id ?? 0) ? Colors.black : Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(pet.name, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600,
                        color: ctrl.selectedPetId.value == (pet.id ?? 0) ? Colors.white : Colors.black)),
                    Text(pet.speciesName ?? '', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.06,
                        color: (ctrl.selectedPetId.value == (pet.id ?? 0) ? Colors.white : Colors.black).withValues(alpha: 0.55))),
                  ])),
                  Icon(ctrl.selectedPetId.value == (pet.id ?? 0) ? Icons.check : Icons.chevron_right,
                      size: 18, color: ctrl.selectedPetId.value == (pet.id ?? 0) ? Colors.white : Colors.black),
                ]),
              ),
            )),
        ];

      case 1:
        return [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'Choose\nyour ', style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700,
                letterSpacing: -0.04 * 36, height: 0.92, color: Colors.black)),
            TextSpan(text: 'vet.', style: GoogleFonts.instrumentSerif(fontSize: 34, fontStyle: FontStyle.italic,
                color: Colors.black, fontWeight: FontWeight.w400)),
          ])),
          const SizedBox(height: 28),
          LineInput(label: 'REASON FOR VISIT', hint: 'Describe the reason...', controller: ctrl.reasonCtrl, maxLines: 3),
        ];

      case 2:
        return [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'Pick a\n', style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700,
                letterSpacing: -0.04 * 36, height: 0.92, color: Colors.black)),
            TextSpan(text: 'date & time.', style: GoogleFonts.instrumentSerif(fontSize: 34, fontStyle: FontStyle.italic,
                color: Colors.black, fontWeight: FontWeight.w400)),
          ])),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: ctrl.selectedDate.value ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(primary: Colors.black),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) ctrl.selectedDate.value = picked;
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DATE', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18,
                      color: Colors.black.withValues(alpha: 0.55))),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    ctrl.selectedDate.value != null
                        ? '${ctrl.selectedDate.value!.day.toString().padLeft(2,'0')} / ${ctrl.selectedDate.value!.month.toString().padLeft(2,'0')} / ${ctrl.selectedDate.value!.year}'
                        : 'Tap to select',
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  )),
                ])),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          LineInput(label: 'PREFERRED TIME', hint: 'e.g. 10:00 AM', controller: ctrl.timeCtrl),
        ];

      case 3:
        return [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'Review &\n', style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700,
                letterSpacing: -0.04 * 36, height: 0.92, color: Colors.black)),
            TextSpan(text: 'confirm.', style: GoogleFonts.instrumentSerif(fontSize: 34, fontStyle: FontStyle.italic,
                color: Colors.black, fontWeight: FontWeight.w400)),
          ])),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              _SummaryRow(label: 'PET', value: ctrl.pets.isNotEmpty
                  ? (ctrl.pets.firstWhereOrNull((p) => p.id == ctrl.selectedPetId.value)?.name ?? '—')
                  : '—'),
              const SizedBox(height: 12),
              _SummaryRow(label: 'DATE', value: ctrl.selectedDate.value != null
                  ? '${ctrl.selectedDate.value!.day.toString().padLeft(2,'0')} / ${ctrl.selectedDate.value!.month.toString().padLeft(2,'0')} / ${ctrl.selectedDate.value!.year}'
                  : '—'),
              const SizedBox(height: 12),
              _SummaryRow(label: 'REASON', value: ctrl.reasonCtrl.text.isEmpty ? '—' : ctrl.reasonCtrl.text),
            ]),
          ),
        ];

      default:
        return [];
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18,
              color: Colors.black.withValues(alpha: 0.55))),
        ),
        Expanded(child: Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black))),
      ],
    );
  }
}
