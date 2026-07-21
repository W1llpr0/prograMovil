import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/line_input.dart';
import '../../configs/theme.dart';
import '../../models/pet.dart';
import '../../models/specialty.dart';
import '../../models/veterinarian.dart';
import 'book_appointment_controller.dart';

class BookAppointmentPage extends GetView<BookAppointmentController> {
  const BookAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(controller.currentStep.value == 0
                ? Icons.close
                : Icons.arrow_back),
            onPressed: controller.currentStep.value == 0
                ? Get.back
                : controller.prevStep,
          ),
          title: Text(controller.currentStep.value == 0
              ? 'Nueva cita'
              : 'Fecha y doctor'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: LinearProgressIndicator(
              value: controller.currentStep.value == 0 ? .5 : 1,
              minHeight: 3,
              backgroundColor: AppColors.surfaceContainer,
            ),
          ),
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: controller.currentStep.value == 0
                        ? _SelectionStep(controller: controller)
                        : _ScheduleStep(controller: controller),
                  ),
                  if (controller.message.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        controller.message.value,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 12, 30, 24),
                    child: ElevatedButton.icon(
                      onPressed: controller.currentStep.value == 0
                          ? controller.nextStep
                          : controller.book,
                      icon: Icon(controller.currentStep.value == 0
                          ? Icons.arrow_forward
                          : Icons.check_circle),
                      label: Text(controller.currentStep.value == 0
                          ? 'Continuar'
                          : 'Confirmar'),
                    ),
                  ),
                ],
              ),
      ));
}

class _SelectionStep extends StatelessWidget {
  final BookAppointmentController controller;
  const _SelectionStep({required this.controller});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecciona la mascota',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            if (controller.clientPets.isEmpty)
              const _EmptyCard(message: 'Primero registra una mascota.')
            else
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.clientPets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) => Obx(() {
                    final pet = controller.clientPets[index];
                    return _PetChoice(
                      pet: pet,
                      selected: controller.pet.value?.id == pet.id,
                      onTap: () => controller.selectPet(pet),
                    );
                  }),
                ),
              ),
            const SizedBox(height: 28),
            Text('Especialidad',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...controller.specialties.map((item) => Obx(() => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SpecialtyChoice(
                    specialty: item,
                    selected: controller.specialty.value?.id == item.id,
                    onTap: () => controller.selectSpecialty(item),
                  ),
                ))),
          ],
        ),
      );
}

class _ScheduleStep extends StatelessWidget {
  final BookAppointmentController controller;
  const _ScheduleStep({required this.controller});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Veterinario asignado',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (controller.matchingVets.isEmpty)
              const _EmptyCard(
                  message: 'No hay veterinarios para esta especialidad.')
            else
              ...controller.matchingVets.map((vet) => Obx(() => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _VetChoice(
                      vet: vet,
                      selected: controller.selectedVet.value?.id == vet.id,
                      onTap: () => controller.selectVet(vet),
                    ),
                  ))),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fecha', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => controller.pickDate(context),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Ver calendario'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  return Obx(() => ChoiceChip(
                        selected: DateUtils.isSameDay(
                            controller.selectedDate.value, date),
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(DateFormat('EEE', 'es_ES')
                                .format(date)
                                .toUpperCase()),
                            Text('${date.day}',
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        onSelected: (_) {
                          controller.selectedDate.value = date;
                          controller.selectedSlot.value = null;
                          controller.loadSlots();
                        },
                      ));
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Horas disponibles',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.selectedVet.value == null) {
                return const Text('Selecciona un veterinario.');
              }
              if (controller.isLoadingSlots.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.availableSlots.isEmpty) {
                return const _EmptyCard(
                    message: 'No hay horarios libres en esta fecha.');
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.availableSlots
                    .map((slot) => ChoiceChip(
                          selected: controller.selectedSlot.value == slot,
                          label: Text(DateFormat('hh:mm a').format(slot)),
                          onSelected: (_) =>
                              controller.selectedSlot.value = slot,
                        ))
                    .toList(),
              );
            }),
            const SizedBox(height: 24),
            LineInput(
              controller: controller.reasonCtrl,
              label: 'Motivo de la consulta',
              hint: 'Describe brevemente el motivo de la visita',
              prefixIcon: Icons.format_quote,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      );
}

class _PetChoice extends StatelessWidget {
  final Pet pet;
  final bool selected;
  final VoidCallback onTap;
  const _PetChoice(
      {required this.pet, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 145,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : AppColors.surface,
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  selected ? Icons.check_circle : Icons.pets,
                  key: ValueKey(selected),
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 6),
              Text(pet.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (selected)
                const Text(
                  'Seleccionada',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      );
}

class _SpecialtyChoice extends StatelessWidget {
  final Specialty specialty;
  final bool selected;
  final VoidCallback onTap;
  const _SpecialtyChoice(
      {required this.specialty, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Icon(
          specialty.name.toLowerCase().contains('cirug')
              ? Icons.content_cut
              : Icons.medical_services,
          color: selected ? AppColors.primary : AppColors.outline,
        ),
        title: Text(specialty.name),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.primary : AppColors.outline,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.outline),
          borderRadius: BorderRadius.circular(14),
        ),
      );
}

class _VetChoice extends StatelessWidget {
  final Veterinarian vet;
  final bool selected;
  final VoidCallback onTap;
  const _VetChoice(
      {required this.vet, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        tileColor: selected ? AppColors.surfaceContainer : null,
        leading: CircleAvatar(child: Text(_initials(vet.fullName))),
        title: Text('Dr. ${vet.fullName}'),
        subtitle: Text(vet.reviewCount == 0
            ? 'Sin reseñas todavía'
            : '⭐ ${vet.rating.toStringAsFixed(1)} (${vet.reviewCount} reseñas)'),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message),
      );
}
