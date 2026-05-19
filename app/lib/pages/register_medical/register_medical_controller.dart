import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';

class RegisterMedicalController extends GetxController {
  final ConsultationService _consultationService = ConsultationService();

  final diagnosisCtrl = TextEditingController();
  final treatmentCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final RxBool isContagious = false.obs;
  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  Consultation? consultation;

  @override
  void onInit() {
    super.onInit();
    consultation = Get.arguments as Consultation?;
  }

  Future<void> save() async {
    if (consultation == null) return;
    if (diagnosisCtrl.text.trim().isEmpty || treatmentCtrl.text.trim().isEmpty) {
      message.value = 'error_empty_fields'.tr;
      return;
    }
    isLoading.value = true;
    message.value = '';

    final GenericResponse<Consultation> res = await _consultationService.completeConsultation(
      consultationId: consultation!.id!,
      diagnosis: diagnosisCtrl.text.trim(),
      treatment: treatmentCtrl.text.trim(),
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      isContagious: isContagious.value,
    );

    isLoading.value = false;

    if (res.success) {
      Get.back(result: true);
    } else {
      message.value = res.message;
    }
  }

  @override
  void onClose() {
    diagnosisCtrl.dispose();
    treatmentCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}
