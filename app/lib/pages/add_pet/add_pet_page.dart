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
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
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
                  Text('NEW PET · 03 / 03', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
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
                        color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'Tell us\nabout ', style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                            letterSpacing: -0.04 * 38, height: 0.92, color: fg)),
                        TextSpan(text: 'your pet.', style: GoogleFonts.instrumentSerif(fontSize: 36, fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400, letterSpacing: -0.02 * 36, height: 1.0, color: fg)),
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
                          border: Border.all(color: fg),
                          borderRadius: BorderRadius.circular(16),
                          color: fg.withValues(alpha: 0.04),
                        ),
                        child: ctrl.imageFile.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(ctrl.imageFile.value!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 32, color: fg.withValues(alpha: 0.4)),
                                  const SizedBox(height: 10),
                                  Text('TAP TO UPLOAD PHOTO', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.22,
                                      color: fg.withValues(alpha: 0.4))),
                                ],
                              ),
                      )),
                    ),

                    const SizedBox(height: 24),

                    // Name field
                    LineInput(label: 'PET NAME', hint: 'e.g. Luna', controller: ctrl.nameCtrl),
                    const SizedBox(height: 22),

                    // Species selector
                    Text('ESPECIE', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                        color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (ctrl.speciesList.isEmpty) {
                        return Text('Cargando especies...', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.grey));
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final species in ctrl.speciesList)
                            _SelectChip(
                              label: species.name.toUpperCase(),
                              selected: ctrl.selectedSpecies.value?.id == species.id,
                              onTap: () => ctrl.selectedSpecies.value = species,
                              fg: fg, bg: bg,
                            ),
                        ],
                      );
                    }),

                    const SizedBox(height: 22),

                    // Sex selector - with Unknown option
                    Text('SEXO', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                        color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                      children: [
                        for (final s in ['Unknown', 'Male', 'Female'])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: s != 'Female' ? 4 : 0),
                              child: GestureDetector(
                                onTap: () => ctrl.selectedSex.value = s,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: ctrl.selectedSex.value == s ? fg : bg,
                                    border: Border.all(color: fg),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(s == 'Unknown' ? 'N/A' : s == 'Male' ? 'MACHO' : 'HEMBRA',
                                        style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.16,
                                            color: ctrl.selectedSex.value == s ? bg : fg)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),

                    const SizedBox(height: 22),

                    // Breed selector
                    Text('RAZA', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                        color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (ctrl.selectedSpecies.value == null) {
                        return Text('Selecciona una especie primero', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.grey));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ctrl.breedsList.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final breed in ctrl.breedsList)
                                  _SelectChip(
                                    label: breed.name.toUpperCase(),
                                    selected: ctrl.selectedBreed.value?.id == breed.id && !ctrl.showCustomBreed.value,
                                    onTap: () {
                                      ctrl.selectedBreed.value = breed;
                                      ctrl.showCustomBreed.value = false;
                                    },
                                    fg: fg, bg: bg,
                                  ),
                                _SelectChip(
                                  label: 'OTRO',
                                  selected: ctrl.showCustomBreed.value,
                                  onTap: () {
                                    ctrl.showCustomBreed.value = true;
                                    ctrl.selectedBreed.value = null;
                                  },
                                  fg: fg, bg: bg,
                                ),
                              ],
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _SelectChip(
                                  label: 'OTRO / ESCRIBIR',
                                  selected: ctrl.showCustomBreed.value,
                                  onTap: () => ctrl.showCustomBreed.value = true,
                                  fg: fg, bg: bg,
                                ),
                              ],
                            ),
                          if (ctrl.showCustomBreed.value) ...
                            [
                              const SizedBox(height: 10),
                              TextField(
                                controller: ctrl.customBreedCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Escribe la raza...',
                                  hintStyle: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.grey),
                                  border: OutlineInputBorder(borderSide: BorderSide(color: fg)),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: fg)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: fg, width: 2)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: fg),
                              ),
                            ],
                        ],
                      );
                    }),

                    const SizedBox(height: 22),
                    
                    // Date picker instead of text input
                    Text('FECHA DE NACIMIENTO',
                        style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() => GestureDetector(
                      onTap: () => ctrl.pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: fg),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ctrl.birthDate.value != null
                                    ? '${ctrl.birthDate.value!.month}/${ctrl.birthDate.value!.year}'
                                    : 'Seleccionar fecha',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: ctrl.birthDate.value != null ? fg : Colors.grey,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today, size: 18, color: fg),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 22),

                    // Weight - optional
                      Text('PESO (KG)',
                          style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.22,
                              color: fg.withValues(alpha: 0.55))),
                      const SizedBox(height: 4),
                      Text('Opcional',
                        style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    LineInput(label: '', hint: '0.0', controller: ctrl.weightCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 22),
                    
                    LineInput(label: 'MICROCHIP / ID', hint: 'Optional', controller: ctrl.microchipCtrl),

                    const SizedBox(height: 40),

                      Obx(() => ctrl.message.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(ctrl.message.value,
                                    style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.red)),
                              ),
                            )
                          : const SizedBox.shrink()),

                      Obx(() => MonochromeButton(
                        label: ctrl.isLoading.value ? 'REGISTRANDO...' : 'REGISTRAR MASCOTA →',
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
  final Color fg;
  final Color bg;
  const _SelectChip({required this.label, required this.selected, required this.onTap, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? fg : bg,
          border: Border.all(color: fg),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                color: selected ? bg : fg)),
      ),
    );
  }
}
