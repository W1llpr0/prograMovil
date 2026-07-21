import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../configs/theme.dart';
import '../../models/consultation.dart';
import 'pet_profile_controller.dart';

class PetProfilePage extends StatelessWidget {
  PetProfilePage({super.key});

  final PetProfileController ctrl = Get.put(PetProfileController());

  @override
  Widget build(BuildContext context) => Obx(() {
        final pet = ctrl.pet.value;
        if (pet == null) {
          return const Scaffold(
              body: Center(child: Text('Mascota no encontrada.')));
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: Get.back, icon: const Icon(Icons.arrow_back)),
            title: Text('Expediente: ${pet.name}'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'photo') ctrl.updatePetPhoto();
                  if (value == 'delete') ctrl.deletePet();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'photo', child: Text('Cambiar foto')),
                  PopupMenuItem(
                      value: 'delete', child: Text('Eliminar mascota')),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: ctrl.loadConsultations,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 100),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFFFE0B2),
                      backgroundImage: pet.photoUrl == null
                          ? null
                          : NetworkImage(pet.photoUrl!),
                      child: pet.photoUrl == null
                          ? const Icon(Icons.pets,
                              size: 42, color: Colors.deepOrange)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                              label: Text(pet.breedName ??
                                  pet.speciesName ??
                                  'Mascota')),
                          Chip(
                            label: Text([
                              pet.sexCode == 'M'
                                  ? 'Macho'
                                  : pet.sexCode == 'F'
                                      ? 'Hembra'
                                      : null,
                              pet.weightKg == null
                                  ? null
                                  : '${pet.weightKg} kg',
                            ].whereType<String>().join(' · ')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: ctrl.goToBookAppointment,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Agendar cita'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Historial médico',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                if (ctrl.isLoading.value && ctrl.consultations.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (ctrl.consultations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: Text('Sin consultas registradas.')),
                  )
                else
                  ...List.generate(ctrl.consultations.length, (index) {
                    final consultation = ctrl.consultations[index];
                    return _TimelineItem(
                      consultation: consultation,
                      first: index == 0,
                      last: index == ctrl.consultations.length - 1,
                      onTap: () => ctrl.goToHistory(consultation),
                    );
                  }),
                if (pet.isExotic) ...[
                  const SizedBox(height: 26),
                  Text('Documentación de especie exótica',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Text(
                      '${ctrl.morphological.length} registros morfológicos · ${ctrl.legalDocs.length} documentos legales'),
                ],
              ],
            ),
          ),
        );
      });
}

class _TimelineItem extends StatelessWidget {
  final Consultation consultation;
  final bool first;
  final bool last;
  final VoidCallback onTap;
  const _TimelineItem({
    required this.consultation,
    required this.first,
    required this.last,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 54,
              child: Column(
                children: [
                  if (!first)
                    const Expanded(
                        child: VerticalDivider(color: AppColors.outline)),
                  CircleAvatar(
                    backgroundColor: consultation.status == 'completed'
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainer,
                    child: Icon(
                      consultation.status == 'completed'
                          ? Icons.medical_information
                          : Icons.schedule,
                      color: AppColors.primary,
                    ),
                  ),
                  if (!last)
                    const Expanded(
                        child: VerticalDivider(color: AppColors.outline)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: ListTile(
                    onTap: onTap,
                    title: Text(
                        consultation.specialtyName ?? 'Consulta veterinaria',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(consultation.diagnosis ??
                        consultation.reason ??
                        'Pendiente de atención'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('dd MMM', 'es_ES')
                            .format(consultation.scheduledAt)),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
