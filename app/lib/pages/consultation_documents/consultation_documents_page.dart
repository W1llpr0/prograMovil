import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/theme.dart';
import 'consultation_documents_controller.dart';

class ConsultationDocumentsPage extends StatelessWidget {
  ConsultationDocumentsPage({super.key});

  final controller = Get.put(ConsultationDocumentsController());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: Get.back, icon: const Icon(Icons.arrow_back)),
          title: const Text('Resultados clínicos'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Sube resultados de laboratorio, rayos X o recetas firmadas (PDF).'),
                const SizedBox(height: 18),
                InkWell(
                  onTap: controller.pickAndUpload,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload,
                            size: 48, color: AppColors.primary),
                        SizedBox(height: 10),
                        Text('Tocar para examinar',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                        Text('PDF, JPG, PNG (máx. 10 MB)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text('Archivos listos',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() => ListView.separated(
                        itemCount: controller.documents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final item = controller.documents[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                item.contentType == 'application/pdf'
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: item.contentType == 'application/pdf'
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                              title: Text(item.fileName),
                              subtitle: Text(item.sizeBytes == null
                                  ? 'Archivo clínico'
                                  : '${(item.sizeBytes! / 1024).ceil()} KB'),
                              trailing: IconButton(
                                onPressed: () => controller.remove(item),
                                icon: const Icon(Icons.delete,
                                    color: AppColors.error),
                              ),
                            ),
                          );
                        },
                      )),
                ),
                Obx(() => controller.message.value.isEmpty
                    ? const SizedBox.shrink()
                    : Text(controller.message.value,
                        style: const TextStyle(color: AppColors.error))),
                const SizedBox(height: 10),
                Obx(() => ElevatedButton.icon(
                      onPressed:
                          controller.isLoading.value ? null : controller.finish,
                      icon: controller.isLoading.value
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.task_alt),
                      label: const Text('Guardar y finalizar cita'),
                    )),
              ],
            ),
          ),
        ),
      );
}
