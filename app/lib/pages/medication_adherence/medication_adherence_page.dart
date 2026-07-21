import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'medication_adherence_controller.dart';

class MedicationAdherencePage extends StatelessWidget {
  MedicationAdherencePage({super.key});

  final MedicationAdherenceController ctrl =
      Get.put(MedicationAdherenceController());

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('medication_adherence'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final selectedPetId = ctrl.selectedPet.value?.id;
              return ctrl.pets.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrl.pets.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final pet = ctrl.pets[index];
                          final selected = selectedPetId == pet.id;
                          return ChoiceChip(
                            selected: selected,
                            showCheckmark: true,
                            avatar: const Icon(Icons.pets, size: 16),
                            label: Text(pet.name),
                            onSelected: (_) => ctrl.selectPet(pet),
                          );
                        },
                      ),
                    );
            }),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final marking = ctrl.marking.toSet();
                final messages = Map<int, String>.from(ctrl.scheduleMessages);
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.schedules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        ctrl.pageMessage.value.isNotEmpty
                            ? ctrl.pageMessage.value
                            : 'No hay tratamientos activos para esta mascota.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: ctrl.schedules.length,
                  itemBuilder: (_, index) {
                    final schedule = ctrl.schedules[index];
                    final id = schedule.id!;
                    final due = schedule.nextDoseAt?.toLocal();
                    final canMark = due == null ||
                        !due.isAfter(
                          DateTime.now().add(const Duration(minutes: 30)),
                        );
                    final isMarking = marking.contains(id);
                    final feedback = messages[id];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule.medicationName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (schedule.dosage != null)
                                    Text(schedule.dosage!),
                                  if (schedule.frequency != null)
                                    Text(
                                      schedule.frequency!,
                                      style: TextStyle(
                                        color: colors.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  if (due != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        canMark
                                            ? 'Dosis pendiente desde ${DateFormat('dd/MM, hh:mm a').format(due)}'
                                            : 'Próxima dosis: ${DateFormat('dd/MM, hh:mm a').format(due)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: canMark
                                              ? colors.error
                                              : colors.primary,
                                        ),
                                      ),
                                    ),
                                  if (feedback != null)
                                    Text(
                                      feedback,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: feedback == 'Dosis registrada'
                                            ? colors.primary
                                            : colors.error,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.tonalIcon(
                              onPressed: canMark && !isMarking
                                  ? () => ctrl.markTaken(id)
                                  : null,
                              icon: isMarking
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(canMark
                                      ? Icons.medication_liquid
                                      : Icons.schedule),
                              label: Text(isMarking
                                  ? 'Guardando'
                                  : canMark
                                      ? 'Marcar dosis'
                                      : 'Aún no'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
