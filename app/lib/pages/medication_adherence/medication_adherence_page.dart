import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'medication_adherence_controller.dart';

class MedicationAdherencePage extends StatelessWidget {
  MedicationAdherencePage({super.key});

  final MedicationAdherenceController ctrl = Get.put(MedicationAdherenceController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('medication_adherence'.tr),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet selector
            Obx(() => ctrl.pets.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.pets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final pet = ctrl.pets[i];
                        final sel = ctrl.selectedPet.value?.id == pet.id;
                        return GestureDetector(
                          onTap: () => ctrl.selectPet(pet),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: sel ? cs.onSurface : Colors.transparent,
                              border: Border.all(color: sel ? cs.onSurface : cs.onSurface.withValues(alpha: 0.2), width: 1),
                            ),
                            child: Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: sel ? cs.surface : cs.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
            const SizedBox(height: 16),
            // Schedules list
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: cs.onSurface, strokeWidth: 1.5));
                }
                if (ctrl.schedules.isEmpty) {
                  return Center(
                    child: Text(
                      'No active medication schedules.',
                      style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: ctrl.schedules.length,
                  itemBuilder: (_, i) {
                    final s = ctrl.schedules[i];
                    final taken = ctrl.loggedToday.contains(s.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.medicationName,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                                if (s.dosage != null)
                                  Text(s.dosage!, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
                                if (s.frequency != null)
                                  Text(s.frequency!, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: taken ? null : () => ctrl.markTaken(s.id!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: taken ? cs.onSurface : Colors.transparent,
                                border: Border.all(color: cs.onSurface, width: 1),
                              ),
                              child: Text(
                                taken ? '✓ TAKEN' : 'MARK TAKEN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.22,
                                  color: taken ? cs.surface : cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
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
