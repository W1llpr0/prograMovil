import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import 'add_pet_controller.dart';

class AddPetPage extends StatelessWidget {
  AddPetPage({super.key});

  final AddPetController ctrl = Get.put(AddPetController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('add_pet'.tr),
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo picker
              Center(child: _PhotoPicker(ctrl: ctrl, cs: cs)),
              const SizedBox(height: 28),
              LineInput(controller: ctrl.nameCtrl, label: 'pet_name'.tr, textCapitalization: TextCapitalization.words),
              // Species dropdown
              _SpeciesDropdown(ctrl: ctrl, cs: cs),
              const SizedBox(height: 16),
              // Sex selector
              _SexSelector(ctrl: ctrl, cs: cs),
              const SizedBox(height: 16),
              // Birth date
              _BirthDatePicker(ctrl: ctrl, cs: cs),
              const SizedBox(height: 16),
              LineInput(controller: ctrl.weightCtrl, label: 'weight'.tr, keyboardType: TextInputType.number),
              LineInput(controller: ctrl.microchipCtrl, label: 'microchip'.tr),
              // Exotic toggle
              Obx(() => _ExoticToggle(ctrl: ctrl, cs: cs)),
              // Exotic morphological section (AnimatedSize)
              Obx(() => AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ctrl.isExotic.value
                        ? _ExoticNote(cs: cs)
                        : const SizedBox.shrink(),
                  )),
              const SizedBox(height: 16),
              Obx(() => ctrl.message.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(ctrl.message.value,
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.7))),
                    )),
              Obx(() => MonochromeButton(
                    label: 'save'.tr,
                    onPressed: ctrl.savePet,
                    isLoading: ctrl.isLoading.value,
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final AddPetController ctrl;
  final ColorScheme cs;
  const _PhotoPicker({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ctrl.pickPhoto,
      child: Obx(() => Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.3), width: 1),
              image: ctrl.photoFile.value != null
                  ? DecorationImage(image: FileImage(ctrl.photoFile.value!), fit: BoxFit.cover)
                  : null,
            ),
            child: ctrl.photoFile.value == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 24, color: cs.onSurface.withValues(alpha: 0.45)),
                      const SizedBox(height: 4),
                      Text('PHOTO', style: TextStyle(fontSize: 9, letterSpacing: 0.22, color: cs.onSurface.withValues(alpha: 0.45))),
                    ],
                  )
                : null,
          )),
    );
  }
}

class _SpeciesDropdown extends StatelessWidget {
  final AddPetController ctrl;
  final ColorScheme cs;
  const _SpeciesDropdown({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SPECIES', style: TextStyle(fontSize: 9, letterSpacing: 0.22, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55))),
            DropdownButton<int>(
              value: ctrl.selectedSpecies.value?.id,
              isExpanded: true,
              dropdownColor: cs.surface,
              underline: Container(height: 1, color: cs.onSurface),
              icon: Icon(Icons.expand_more, color: cs.onSurface),
              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 16, color: cs.onSurface),
              hint: Text('Select species', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.35))),
              items: ctrl.speciesList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (id) {
                ctrl.selectedSpecies.value = ctrl.speciesList.firstWhere((s) => s.id == id);
                if (ctrl.selectedSpecies.value?.isExotic == true) ctrl.isExotic.value = true;
              },
            ),
          ],
        ));
  }
}

class _SexSelector extends StatelessWidget {
  final AddPetController ctrl;
  final ColorScheme cs;
  const _SexSelector({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SEX', style: TextStyle(fontSize: 9, letterSpacing: 0.22, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55))),
            const SizedBox(height: 8),
            Row(
              children: ['M', 'F'].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => ctrl.selectedSex.value = s,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: ctrl.selectedSex.value == s ? cs.onSurface : Colors.transparent,
                          border: Border.all(color: cs.onSurface, width: 1),
                        ),
                        child: Text(
                          s == 'M' ? 'MALE' : 'FEMALE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.22,
                            fontWeight: FontWeight.w700,
                            color: ctrl.selectedSex.value == s ? cs.surface : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
            ),
          ],
        ));
  }
}

class _BirthDatePicker extends StatelessWidget {
  final AddPetController ctrl;
  final ColorScheme cs;
  const _BirthDatePicker({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ctrl.pickDate(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BIRTH DATE', style: TextStyle(fontSize: 9, letterSpacing: 0.22, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55))),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.onSurface, width: 1))),
            child: Obx(() => Text(
                  ctrl.birthDate.value != null
                      ? '${ctrl.birthDate.value!.year}-${ctrl.birthDate.value!.month.toString().padLeft(2, '0')}-${ctrl.birthDate.value!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16,
                    color: ctrl.birthDate.value != null ? cs.onSurface : cs.onSurface.withValues(alpha: 0.35),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class _ExoticToggle extends StatelessWidget {
  final AddPetController ctrl;
  final ColorScheme cs;
  const _ExoticToggle({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('EXOTIC SPECIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: cs.onSurface)),
        Switch(
          value: ctrl.isExotic.value,
          onChanged: (v) => ctrl.isExotic.value = v,
        ),
      ],
    );
  }
}

class _ExoticNote extends StatelessWidget {
  final ColorScheme cs;
  const _ExoticNote({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: cs.onSurface, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXOTIC / CITES', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          Text(
            'Morphological tracking and CITES legal documents will be available in the pet profile once saved.',
            style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 12, color: cs.onSurface.withValues(alpha: 0.8), height: 1.5),
          ),
        ],
      ),
    );
  }
}
