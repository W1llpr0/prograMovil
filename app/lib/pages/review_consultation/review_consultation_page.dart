import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/line_input.dart';
import '../../configs/theme.dart';
import 'review_consultation_controller.dart';

class ReviewConsultationPage extends StatelessWidget {
  ReviewConsultationPage({super.key});

  final controller = Get.put(ReviewConsultationController());

  @override
  Widget build(BuildContext context) {
    final consultation = controller.consultation;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
        title: const Text('Evaluar atención'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      child:
                          Text((consultation?.vetName ?? 'V')[0].toUpperCase()),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. ${consultation?.vetName ?? 'Veterinario'}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                              'Paciente: ${consultation?.petName ?? 'Mascota'}'),
                        ],
                      ),
                    ),
                    Text(consultation == null
                        ? ''
                        : DateFormat('dd MMM yyyy', 'es_ES')
                            .format(consultation.scheduledAt)),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Text('¿Qué tal te pareció el servicio?',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const Text('Tu opinión ayuda a mejorar la clínica.'),
              const SizedBox(height: 20),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        onPressed: () => controller.rating.value = value,
                        iconSize: 44,
                        icon: Icon(
                          value <= controller.rating.value
                              ? Icons.star
                              : Icons.star_border,
                          color: value <= controller.rating.value
                              ? AppColors.warning
                              : AppColors.outline,
                        ),
                      );
                    }),
                  )),
              const SizedBox(height: 8),
              Obx(() => Text(
                    _ratingLabel(controller.rating.value),
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
              const SizedBox(height: 34),
              LineInput(
                controller: controller.commentCtrl,
                label: 'Escribe una reseña (opcional)',
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              Obx(() => controller.message.value.isEmpty
                  ? const SizedBox.shrink()
                  : Text(controller.message.value,
                      style: const TextStyle(color: AppColors.error))),
              const SizedBox(height: 28),
              Obx(() => ElevatedButton.icon(
                    onPressed:
                        controller.isLoading.value ? null : controller.submit,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar reseña'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(int rating) => switch (rating) {
        1 => 'Malo (1/5)',
        2 => 'Regular (2/5)',
        3 => 'Bueno (3/5)',
        4 => '¡Muy bueno! (4/5)',
        5 => '¡Excelente! (5/5)',
        _ => 'Selecciona de 1 a 5 estrellas',
      };
}
