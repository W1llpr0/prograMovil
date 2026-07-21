import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../models/consultation_completion_draft.dart';
import '../../services/consultation_service.dart';

class RegisterMedicalController extends GetxController {
  final ConsultationService consultationService;
  RegisterMedicalController({ConsultationService? consultationService})
      : consultationService = consultationService ?? ConsultationService();

  final diagnosisCtrl = TextEditingController();
  final treatmentCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final tempCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final hrCtrl = TextEditingController();
  final rrCtrl = TextEditingController();
  final medicationNameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final frequencyHoursCtrl = TextEditingController(text: '8');
  final durationDaysCtrl = TextEditingController(text: '7');

  final isContagious = false.obs;
  final isLoading = false.obs;
  final message = ''.obs;
  Consultation? consultation;

  @override
  void onInit() {
    super.onInit();
    consultation = Get.arguments as Consultation?;
    diagnosisCtrl.text = consultation?.diagnosis ?? '';
    treatmentCtrl.text = consultation?.treatment ?? '';
    notesCtrl.text = consultation?.notes ?? '';
    final vitals = consultation?.vitals ?? const {};
    tempCtrl.text = vitals['temperature_c']?.toString() ?? '';
    weightCtrl.text = vitals['weight_kg']?.toString() ?? '';
    hrCtrl.text = vitals['heart_rate_bpm']?.toString() ?? '';
    rrCtrl.text = vitals['respiratory_rate']?.toString() ?? '';
  }

  Map<String, dynamic> get vitals => {
        if (double.tryParse(tempCtrl.text.trim()) case final value?)
          'temperature_c': value,
        if (double.tryParse(weightCtrl.text.trim()) case final value?)
          'weight_kg': value,
        if (int.tryParse(hrCtrl.text.trim()) case final value?)
          'heart_rate_bpm': value,
        if (int.tryParse(rrCtrl.text.trim()) case final value?)
          'respiratory_rate': value,
      };

  List<Map<String, dynamic>> get medications {
    final name = medicationNameCtrl.text.trim();
    if (name.isEmpty) return const [];
    final hours = int.tryParse(frequencyHoursCtrl.text.trim());
    final days = int.tryParse(durationDaysCtrl.text.trim()) ?? 1;
    final start = DateTime.now();
    final end = start.add(Duration(days: days));
    return [
      {
        'name': name,
        'dosage': dosageCtrl.text.trim(),
        'frequency': hours == null ? null : 'Cada $hours horas',
        'frequency_hours': hours,
        'start_date': start.toIso8601String().split('T').first,
        'end_date': end.toIso8601String().split('T').first,
        'next_dose_at': start.toIso8601String(),
      }
    ];
  }

  Future<void> saveDraft() async {
    if (consultation?.id == null) return;
    isLoading.value = true;
    final result = await consultationService.saveDraft(
      consultationId: consultation!.id!,
      diagnosis: diagnosisCtrl.text,
      treatment: treatmentCtrl.text,
      notes: notesCtrl.text,
      vitals: vitals,
    );
    isLoading.value = false;
    message.value = result.message;
  }

  Future<void> continueToDocuments() async {
    if (consultation?.id == null) return;
    if (diagnosisCtrl.text.trim().isEmpty ||
        treatmentCtrl.text.trim().isEmpty) {
      message.value = 'Diagnóstico y tratamiento son obligatorios.';
      return;
    }
    isLoading.value = true;
    message.value = '';
    final GenericResponse<void> result = await consultationService.saveDraft(
      consultationId: consultation!.id!,
      diagnosis: diagnosisCtrl.text,
      treatment: treatmentCtrl.text,
      notes: notesCtrl.text.trim(),
      vitals: vitals,
    );
    isLoading.value = false;
    if (result.success) {
      Get.toNamed(
        AppRoutes.consultationDocuments,
        arguments: ConsultationCompletionDraft(
          consultation: consultation!,
          diagnosis: diagnosisCtrl.text.trim(),
          treatment: treatmentCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          isContagious: isContagious.value,
          vitals: vitals,
          medications: medications,
        ),
      );
    } else {
      message.value = result.message;
    }
  }

  Future<void> finishAndContinue() => continueToDocuments();

  Future<void> save() => continueToDocuments();

  @override
  void onClose() {
    for (final controller in [
      diagnosisCtrl,
      treatmentCtrl,
      notesCtrl,
      tempCtrl,
      weightCtrl,
      hrCtrl,
      rrCtrl,
      medicationNameCtrl,
      dosageCtrl,
      frequencyHoursCtrl,
      durationDaysCtrl,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }
}
