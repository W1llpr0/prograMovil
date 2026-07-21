import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/line_input.dart';
import '../../configs/theme.dart';
import 'register_medical_controller.dart';

class RegisterMedicalPage extends StatelessWidget {
  RegisterMedicalPage({super.key});

  final RegisterMedicalController ctrl = Get.put(RegisterMedicalController());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryContainer,
          leading:
              IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
          title:
              Text('Atendiendo: ${ctrl.consultation?.petName ?? 'Paciente'}'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 18),
              child: Icon(Icons.timer),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(30, 18, 30, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LineInput(
                        controller: ctrl.diagnosisCtrl,
                        label: 'Diagnóstico clínico',
                        prefixIcon: Icons.medical_services,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      LineInput(
                        controller: ctrl.treatmentCtrl,
                        label: 'Tratamiento prescrito',
                        prefixIcon: Icons.medical_information,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Signos vitales y medicación'),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child:
                                      _NumberField(ctrl.tempCtrl, 'Temp. °C')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child:
                                      _NumberField(ctrl.weightCtrl, 'Peso kg')),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: _NumberField(ctrl.hrCtrl, 'FC bpm')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _NumberField(ctrl.rrCtrl, 'FR /min')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LineInput(
                            controller: ctrl.medicationNameCtrl,
                            label: 'Medicamento (opcional)',
                            prefixIcon: Icons.medication,
                          ),
                          LineInput(
                            controller: ctrl.dosageCtrl,
                            label: 'Dosis',
                            hint: 'Ej. 3 gotas',
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _NumberField(
                                    ctrl.frequencyHoursCtrl, 'Cada N horas'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _NumberField(
                                    ctrl.durationDaysCtrl, 'Duración días'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LineInput(
                        controller: ctrl.notesCtrl,
                        label: 'Notas adicionales',
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Obx(() => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Diagnóstico contagioso'),
                            subtitle: const Text(
                                'Generará una alerta epidemiológica zonal.'),
                            value: ctrl.isContagious.value,
                            onChanged: (value) =>
                                ctrl.isContagious.value = value,
                          )),
                      Obx(() => ctrl.message.value.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(ctrl.message.value,
                                  style: TextStyle(
                                    color:
                                        ctrl.message.value.contains('guardado')
                                            ? AppColors.primary
                                            : AppColors.error,
                                  )),
                            )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: ctrl.saveDraft,
                        icon: const Icon(Icons.save),
                        label: const Text('Borrador'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: ctrl.isLoading.value
                                ? null
                                : ctrl.continueToDocuments,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Adjuntar'),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _NumberField(this.controller, this.label);

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      );
}
