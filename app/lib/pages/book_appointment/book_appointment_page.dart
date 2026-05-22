import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'book_appointment_controller.dart';

class BookAppointmentPage extends GetView<BookAppointmentController> {
  const BookAppointmentPage({super.key});

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'select_vet'.tr;
      case 1:
        return 'select_date'.tr;
      case 2:
        return 'select_pet_appointment'.tr;
      default:
        return 'book_appointment'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fg),
          onPressed: () {
            if (controller.currentStep.value > 0) {
              controller.prevStep();
            } else {
              Get.back();
            }
          },
        ),
        title: Obx(() => Text(
              _stepTitle(controller.currentStep.value),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02 * 16,
                color: fg,
              ),
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: fg.withValues(alpha: 0.15)),
        ),
      ),
      body: Column(
        children: [
          _buildStepDots(fg),
          Expanded(
            child: Obx(() {
              switch (controller.currentStep.value) {
                case 0:
                  return _buildVetStep(fg);
                case 1:
                  return _buildDateTimeStep(context, fg);
                case 2:
                  return _buildPetStep(fg);
                default:
                  return const SizedBox.shrink();
              }
            }),
          ),
          _buildBottomBar(context, fg, bg),
        ],
      ),
    );
  }

  Widget _buildStepDots(Color fg) {
    return Obx(() {
      final step = controller.currentStep.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = i == step;
            final done = i < step;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (active || done) ? fg : fg.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildVetStep(Color fg) {
    return Obx(() {
      if (controller.vets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services_outlined, size: 64, color: fg.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('no_vets_available'.tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 16, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.6))),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(22),
        itemCount: controller.vets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final vet = controller.vets[i];
          return Obx(() {
            final isSelected = controller.selectedVet.value?.id == vet.id;
            return GestureDetector(
              onTap: () => controller.selectVet(vet),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? fg : fg.withValues(alpha: 0.25),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_outline, color: fg, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vet.fullName.trim().isEmpty ? 'Veterinario' : 'Dr. ${vet.fullName}',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 15, fontWeight: FontWeight.w600, color: fg),
                          ),
                          if (vet.licenseNumber != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Reg. ${vet.licenseNumber}',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  letterSpacing: 0.12,
                                  color: fg.withValues(alpha: 0.55)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_circle, color: fg, size: 22),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildDateTimeStep(BuildContext context, Color fg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('select_date'.tr,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55))),
          const SizedBox(height: 8),
          Obx(() => GestureDetector(
                onTap: () => controller.pickDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.selectedDate.value != null
                          ? fg
                          : fg.withValues(alpha: 0.3),
                      width: controller.selectedDate.value != null ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: fg, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        controller.selectedDate.value != null
                            ? DateFormat('EEEE, d MMM yyyy', 'es_ES')
                                .format(controller.selectedDate.value!)
                            : 'Seleccionar fecha',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: controller.selectedDate.value != null
                              ? fg
                              : fg.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Text('select_time'.tr,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55))),
          const SizedBox(height: 8),
          Obx(() => GestureDetector(
                onTap: () => controller.pickTime(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.selectedTime.value != null
                          ? fg
                          : fg.withValues(alpha: 0.3),
                      width: controller.selectedTime.value != null ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_outlined, color: fg, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        controller.selectedTime.value != null
                            ? controller.selectedTime.value!.format(context)
                            : 'Seleccionar hora',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: controller.selectedTime.value != null
                              ? fg
                              : fg.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Text('reason'.tr,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55))),
          const SizedBox(height: 8),
          TextField(
            controller: controller.reasonCtrl,
            style: GoogleFonts.spaceGrotesk(fontSize: 14, color: fg),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Motivo de consulta (opcional)',
              hintStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 13, color: fg.withValues(alpha: 0.35)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: fg.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: fg, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetStep(Color fg) {
    return Obx(() {
      if (controller.clientPets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets_outlined, size: 64, color: fg.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('no_pets_yet_appt'.tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 16, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Text('no_pets_appt_hint'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, color: fg.withValues(alpha: 0.4))),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(22),
        itemCount: controller.clientPets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final p = controller.clientPets[i];
          return Obx(() {
            final isSelected = controller.pet.value?.id == p.id;
            return GestureDetector(
              onTap: () => controller.selectPet(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? fg : fg.withValues(alpha: 0.25),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.pets, color: fg, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 15, fontWeight: FontWeight.w600, color: fg),
                          ),
                          if (p.speciesName != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              '${p.speciesName}${p.breedName != null ? ' · ${p.breedName}' : ''}',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  letterSpacing: 0.12,
                                  color: fg.withValues(alpha: 0.55)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_circle, color: fg, size: 22),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildBottomBar(BuildContext context, Color fg, Color bg) {
    return Obx(() {
      final step = controller.currentStep.value;
      final isLastStep = step == 2;
      final enabled = _buttonEnabled();
      return Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: fg.withValues(alpha: 0.15))),
          color: bg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.message.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(controller.message.value,
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.red)),
              ),
            GestureDetector(
              onTap: enabled
                  ? () {
                      controller.message.value = '';
                      if (isLastStep) {
                        controller.book();
                      } else {
                        controller.nextStep();
                      }
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: enabled ? fg : fg.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: bg, strokeWidth: 2))
                    : Text(
                        isLastStep ? 'confirm'.tr : 'next'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: bg,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  bool _buttonEnabled() {
    switch (controller.currentStep.value) {
      case 0:
        return controller.selectedVet.value != null;
      case 1:
        return controller.selectedDate.value != null && controller.selectedTime.value != null;
      case 2:
        return controller.pet.value != null;
      default:
        return false;
    }
  }
}

