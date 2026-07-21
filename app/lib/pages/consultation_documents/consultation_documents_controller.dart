import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../configs/app_routes.dart';
import '../../models/consultation.dart';
import '../../models/consultation_completion_draft.dart';
import '../../models/consultation_document.dart';
import '../../services/consultation_service.dart';
import '../../services/document_service.dart';

class ConsultationDocumentsController extends GetxController {
  final DocumentService service;
  final ConsultationService consultationService;
  ConsultationDocumentsController({
    DocumentService? service,
    ConsultationService? consultationService,
  })  : service = service ?? DocumentService(),
        consultationService = consultationService ?? ConsultationService();

  final documents = <ConsultationDocument>[].obs;
  final isLoading = false.obs;
  final message = ''.obs;
  Consultation? consultation;
  ConsultationCompletionDraft? completionDraft;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is ConsultationCompletionDraft) {
      completionDraft = argument;
      consultation = argument.consultation;
    } else if (argument is Consultation) {
      consultation = argument;
    }
    load();
  }

  Future<void> load() async {
    if (consultation?.id == null) return;
    final result = await service.fetchForConsultation(consultation!.id!);
    if (result.success) documents.assignAll(result.data ?? []);
  }

  Future<void> pickAndUpload() async {
    if (consultation?.id == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;
    if (file.size > 10 * 1024 * 1024) {
      message.value = 'El archivo supera el máximo de 10 MB.';
      return;
    }
    isLoading.value = true;
    message.value = '';
    final response = await service.uploadConsultationDocument(
      consultationId: consultation!.id!,
      fileName: file.name,
      bytes: file.bytes!,
      contentType: _contentType(file.extension),
    );
    isLoading.value = false;
    if (response.success && response.data != null) {
      documents.add(response.data!);
    } else {
      message.value = response.message;
    }
  }

  Future<void> remove(ConsultationDocument document) async {
    final result = await service.delete(document);
    if (result.success) documents.remove(document);
  }

  Future<void> finish() async {
    final draft = completionDraft;
    if (draft == null) {
      if (consultation?.status == 'completed') {
        Get.offAllNamed(AppRoutes.vetDashboard);
      } else {
        message.value = 'Faltan los datos clínicos de la consulta.';
      }
      return;
    }
    final id = draft.consultation.id;
    if (id == null) {
      message.value = 'Consulta no encontrada.';
      return;
    }
    isLoading.value = true;
    message.value = '';
    final result = await consultationService.completeConsultation(
      consultationId: id,
      diagnosis: draft.diagnosis,
      treatment: draft.treatment,
      notes: draft.notes,
      isContagious: draft.isContagious,
      vitals: draft.vitals,
      medications: draft.medications,
    );
    isLoading.value = false;
    if (result.success) {
      Get.offAllNamed(AppRoutes.vetDashboard);
    } else {
      message.value = result.message;
    }
  }

  String? _contentType(String? extension) => switch (extension?.toLowerCase()) {
        'pdf' => 'application/pdf',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        _ => null,
      };
}
