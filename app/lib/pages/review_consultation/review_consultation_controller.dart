import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_controller.dart';
import '../../models/consultation.dart';
import '../../services/review_service.dart';

class ReviewConsultationController extends GetxController {
  final ReviewService service;
  ReviewConsultationController({ReviewService? service})
      : service = service ?? ReviewService();

  final commentCtrl = TextEditingController();
  final rating = 0.obs;
  final isLoading = false.obs;
  final message = ''.obs;
  Consultation? consultation;

  @override
  void onInit() {
    super.onInit();
    consultation = Get.arguments as Consultation?;
    if (!Get.find<AppController>().isClient) {
      message.value = 'Solo el dueño de la mascota puede evaluar la atención.';
    }
  }

  Future<void> submit() async {
    if (!Get.find<AppController>().isClient) {
      message.value = 'Solo el dueño de la mascota puede evaluar la atención.';
      return;
    }
    if (consultation?.id == null || rating.value == 0) {
      message.value = 'Selecciona una calificación.';
      return;
    }
    isLoading.value = true;
    final result = await service.submit(
      consultationId: consultation!.id!,
      rating: rating.value,
      comment: commentCtrl.text.trim(),
    );
    isLoading.value = false;
    if (result.success) {
      Get.back(result: true);
    } else {
      message.value = result.message;
    }
  }

  @override
  void onClose() {
    commentCtrl.dispose();
    super.onClose();
  }
}
