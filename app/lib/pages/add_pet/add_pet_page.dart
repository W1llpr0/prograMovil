import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../models/species.dart';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: fg),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(Icons.chevron_left, size: 18, color: fg),
                    ),
                  ),
                  Text('new_pet'.tr,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10, letterSpacing: 0.18, color: fg)),
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
                    Text('add_pet_title'.tr,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            letterSpacing: 0.18,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'tell_about_pet'.tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.04 * 38,
                              height: 0.92,
                              color: fg),
                        ),
                        TextSpan(
                          text: 'your_pet'.tr,
                          style: GoogleFonts.instrumentSerif(
                              fontSize: 36,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.02 * 36,
                              height: 1.0,
                              color: fg),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 28),

                    // Photo upload
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
                                    child: Image.file(ctrl.imageFile.value!,
                                        fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 32,
                                          color: fg.withValues(alpha: 0.4)),
                                      const SizedBox(height: 10),
                                      Text('tap_upload_photo'.tr,
                                          style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              letterSpacing: 0.22,
                                              color:
                                                  fg.withValues(alpha: 0.4))),
                                    ],
                                  ),
                          )),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    LineInput(
                        label: 'pet_name'.tr,
                        hint: 'e.g. Luna',
                        controller: ctrl.nameCtrl),
                    const SizedBox(height: 22),

                    // Species autocomplete
                    Text('species'.tr,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 0.22,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (ctrl.speciesList.isEmpty) {
                        return Text('loading_species'.tr,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 12, color: Colors.grey));
                      }
                      return _SearchDropdown<Species>(
                        hint: 'search_species'.tr,
                        options: ctrl.speciesList.toList(),
                        displayString: (s) => s.name,
                        onSelected: (s) => ctrl.selectedSpecies.value = s,
                        fg: fg,
                        bg: bg,
                      );
                    }),
                    const SizedBox(height: 22),

                    // Sex
                    Text('sex'.tr,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 0.22,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          children: [
                            for (final s in ['Unknown', 'Male', 'Female'])
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: s != 'Female' ? 4 : 0),
                                  child: GestureDetector(
                                    onTap: () => ctrl.selectedSex.value = s,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: ctrl.selectedSex.value == s
                                            ? fg
                                            : bg,
                                        border: Border.all(color: fg),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Center(
                                        child: Text(
                                          s == 'Unknown'
                                              ? 'N/A'
                                              : s == 'Male'
                                                  ? 'MACHO'
                                                  : 'HEMBRA',
                                          style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              letterSpacing: 0.16,
                                              color: ctrl.selectedSex.value == s
                                                  ? bg
                                                  : fg),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )),
                    const SizedBox(height: 22),

                    // Breed autocomplete
                    Text('breed'.tr,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 0.22,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (ctrl.selectedSpecies.value == null) {
                        return Text('select_species_first'.tr,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 12, color: Colors.grey));
                      }
                      final sid = ctrl.selectedSpecies.value!.id;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SearchDropdown<Breed>(
                            key: ValueKey('breeds_$sid'),
                            hint: 'search_breed'.tr,
                            options: ctrl.breedsList.toList(),
                            displayString: (b) => b.name,
                            onSelected: (b) {
                              ctrl.selectedBreed.value = b;
                              ctrl.showCustomBreed.value = false;
                            },
                            fg: fg,
                            bg: bg,
                          ),
                          const SizedBox(height: 8),
                          Obx(() => GestureDetector(
                                onTap: () {
                                  ctrl.showCustomBreed.value =
                                      !ctrl.showCustomBreed.value;
                                  if (ctrl.showCustomBreed.value) {
                                    ctrl.selectedBreed.value = null;
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: ctrl.showCustomBreed.value ? fg : bg,
                                    border: Border.all(color: fg),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text('other'.tr,
                                      style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          letterSpacing: 0.18,
                                          color: ctrl.showCustomBreed.value
                                              ? bg
                                              : fg)),
                                ),
                              )),
                          Obx(() => ctrl.showCustomBreed.value
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: TextField(
                                    controller: ctrl.customBreedCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'write_breed'.tr,
                                      hintStyle: GoogleFonts.spaceGrotesk(
                                          fontSize: 13, color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(color: fg)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: fg)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: fg, width: 2)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                    ),
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14, color: fg),
                                  ),
                                )
                              : const SizedBox.shrink()),
                        ],
                      );
                    }),
                    const SizedBox(height: 22),

                    // Birth date
                    Text('birth_date'.tr,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 0.22,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    Obx(() => GestureDetector(
                          onTap: () => ctrl.pickDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
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
                                        : 'select_birth_date'.tr,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      color: ctrl.birthDate.value != null
                                          ? fg
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                Icon(Icons.calendar_today, size: 18, color: fg),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 22),

                    // Weight
                    Text('weight'.tr,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 0.22,
                            color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 4),
                    Text('optional'.tr,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    LineInput(
                        label: '',
                        hint: '0.0',
                        controller: ctrl.weightCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 22),

                    LineInput(
                        label: 'microchip'.tr,
                        hint: 'Optional',
                        controller: ctrl.microchipCtrl),
                    const SizedBox(height: 40),

                    // Error
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
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13, color: Colors.red)),
                            ),
                          )
                        : const SizedBox.shrink()),

                    Obx(() => MonochromeButton(
                          label: ctrl.isLoading.value
                              ? 'uploading'.tr
                              : 'register_pet_btn'.tr,
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

/// Generic searchable autocomplete dropdown — no extra packages needed.
class _SearchDropdown<T extends Object> extends StatelessWidget {
  final String hint;
  final List<T> options;
  final String Function(T) displayString;
  final void Function(T) onSelected;
  final Color fg;
  final Color bg;

  const _SearchDropdown({
    super.key,
    required this.hint,
    required this.options,
    required this.displayString,
    required this.onSelected,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      optionsBuilder: (TextEditingValue tv) {
        if (tv.text.isEmpty) return options;
        final q = tv.text.toLowerCase();
        return options.where((o) => displayString(o).toLowerCase().contains(q));
      },
      displayStringForOption: displayString,
      onSelected: onSelected,
      fieldViewBuilder: (ctx, fieldCtrl, focusNode, onSubmit) => TextField(
        controller: fieldCtrl,
        focusNode: focusNode,
        style: GoogleFonts.spaceGrotesk(fontSize: 14, color: fg),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.grey),
          border: OutlineInputBorder(borderSide: BorderSide(color: fg)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: fg)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: fg, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon:
              Icon(Icons.search, size: 18, color: fg.withValues(alpha: 0.5)),
        ),
      ),
      optionsViewBuilder: (ctx, onSel, opts) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: fg.withValues(alpha: 0.15)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: opts.length,
              itemBuilder: (ctx, i) {
                final opt = opts.elementAt(i);
                return InkWell(
                  onTap: () => onSel(opt),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Text(displayString(opt),
                        style:
                            GoogleFonts.spaceGrotesk(fontSize: 14, color: fg)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
