import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import 'add_pet_controller.dart';

class AddPetPage extends StatelessWidget {
  AddPetPage({super.key});

  final AddPetController ctrl = Get.put(AddPetController());

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
                  Text('NEW PET · 03 / 03', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
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
                    Text('ADD PET', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                        color: Colors.black.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'Tell us\nabout ', style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                            letterSpacing: -0.04 * 38, height: 0.92, color: Colors.black)),
                        TextSpan(text: 'your pet.', style: GoogleFonts.instrumentSerif(fontSize: 36, fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400, letterSpacing: -0.02 * 36, height: 1.0, color: Colors.black)),
                      ]),
                    ),

                    const SizedBox(height: 28),

                    // ── Photo upload ─────────────────────────────
                    GestureDetector(
                      onTap: ctrl.pickPhoto,
                      child: Obx(() => Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, style: ctrl.imageFile.value == null ? BorderStyle.solid : BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade50,
                        ),
                        child: ctrl.imageFile.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(ctrl.imageFile.value!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.black.withValues(alpha: 0.4)),
                                  const SizedBox(height: 10),
                                  Text('TAP TO UPLOAD PHOTO', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.22,
                                      color: Colors.black.withValues(alpha: 0.4))),
                                ],
                              ),
                      )),
                    ),

                    const SizedBox(height: 24),

                    // Name field
                    LineInput(label: 'PET NAME', hint: 'e.g. Luna', controller: ctrl.nameCtrl),
                    const SizedBox(height: 22),

                    // Species selector
                    Text('SPECIES', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                        color: Colors.black.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in ['Dog', 'Cat', 'Bird', 'Exotic · Reptile', 'Aquatic', 'Other'])
                          _SelectChip(
                            label: s.toUpperCase(),
                            selected: ctrl.selectedSpecies.value?.name == s || (ctrl.speciesList.isEmpty && ctrl.selectedSpecies.value == null),
                            onTap: () {
                              try {
                                ctrl.selectedSpecies.value = ctrl.speciesList.firstWhere((sp) => sp.name == s);
                              } catch (_) {}
                            },
                          ),
                      ],
                    )),

                    const SizedBox(height: 22),

                    // Sex selector
                    Text('SEX', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                        color: Colors.black.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                      children: [
                        for (final s in ['Male', 'Female'])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: s == 'Male' ? 8 : 0),
                              child: GestureDetector(
                                onTap: () => ctrl.selectedSex.value = s,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: ctrl.selectedSex.value == s ? Colors.black : Colors.white,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(s.toUpperCase(),
                                        style: GoogleFonts.jetBrainsMono(fontSize: 11, letterSpacing: 0.22,
                                            color: ctrl.selectedSex.value == s ? Colors.white : Colors.black)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),

                    const SizedBox(height: 22),

                    LineInput(label: 'BREED', hint: 'e.g. Golden Retriever', controller: ctrl.breedCtrl),
                    const SizedBox(height: 22),
                    LineInput(label: 'DATE OF BIRTH', hint: 'MM / YYYY', controller: ctrl.birthDateCtrl),
                    const SizedBox(height: 22),
                    LineInput(label: 'WEIGHT (KG)', hint: '0.0', controller: ctrl.weightCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 22),
                    LineInput(label: 'MICROCHIP / ID', hint: 'Optional', controller: ctrl.microchipCtrl),

                    const SizedBox(height: 40),

                    Obx(() => MonochromeButton(
                      label: ctrl.isLoading.value ? 'REGISTERING...' : 'REGISTER PET →',
                      filled: true,
                      onPressed: ctrl.isLoading.value ? null : ctrl.submit,
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

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                color: selected ? Colors.white : Colors.black)),
      ),
    );
  }
}
