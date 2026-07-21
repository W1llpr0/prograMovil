import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/theme.dart';
import '../../models/consultation.dart';
import '../../models/consultation_document.dart';
import '../../services/consultation_service.dart';
import '../../services/document_service.dart';
import '../../services/review_service.dart';

class ClinicalHistoryPage extends StatefulWidget {
  const ClinicalHistoryPage({super.key});

  @override
  State<ClinicalHistoryPage> createState() => _ClinicalHistoryPageState();
}

class _ClinicalHistoryPageState extends State<ClinicalHistoryPage> {
  final documentService = DocumentService();
  final consultationService = ConsultationService();
  final reviewService = ReviewService();
  List<ConsultationDocument> documents = const [];
  bool reviewExists = false;
  bool reviewStateLoaded = false;
  bool canReview = false;

  Consultation? get consultation => Get.arguments as Consultation?;

  @override
  void initState() {
    super.initState();
    loadDocuments();
    loadReview();
  }

  Future<void> loadReview() async {
    final item = consultation;
    final isClient = Get.find<AppController>().isClient;
    if (item?.id == null || item?.status != 'completed' || !isClient) {
      if (mounted) {
        setState(() {
          reviewStateLoaded = true;
          canReview = false;
        });
      }
      return;
    }
    final result = await reviewService.fetchForConsultation(item!.id!);
    if (mounted) {
      setState(() {
        reviewStateLoaded = true;
        reviewExists = result.success && result.data != null;
        canReview = result.success && result.data == null;
      });
    }
  }

  Future<void> openReview(Consultation item) async {
    final submitted = await Get.toNamed(
      AppRoutes.reviewConsultation,
      arguments: item,
    );
    if (mounted && submitted == true) {
      setState(() {
        reviewExists = true;
        canReview = false;
      });
    }
  }

  Future<void> loadDocuments() async {
    final id = consultation?.id;
    if (id == null) return;
    final result = await documentService.fetchForConsultation(id);
    if (mounted && result.success) {
      setState(() => documents = result.data ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = consultation;
    if (item == null) {
      return const Scaffold(
          body: Center(child: Text('Consulta no encontrada.')));
    }
    final verified = consultationService.verifyIntegrity(item);
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back)),
        title: const Text('Historia clínica'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 40),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFFFFE0B2),
                  child: Icon(Icons.pets, color: Colors.deepOrange, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.petName ?? 'Paciente',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                          '${item.specialtyName ?? 'Consulta'} · ${DateFormat('dd MMM yyyy', 'es_ES').format(item.scheduledAt)}'),
                      Text('Dr. ${item.vetName ?? 'Veterinario'}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _Section(
                title: 'Diagnóstico', content: item.diagnosis ?? 'Pendiente'),
            _Section(
                title: 'Tratamiento prescrito',
                content: item.treatment ?? 'Pendiente'),
            if (item.notes?.isNotEmpty == true)
              _Section(title: 'Observaciones', content: item.notes!),
            if (item.vitals.isNotEmpty) ...[
              Text('Signos vitales',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: item.vitals.entries
                    .map((entry) =>
                        Chip(label: Text('${entry.key}: ${entry.value}')))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            Text('Documentos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (documents.isEmpty)
              const Text('Sin documentos adjuntos.')
            else
              ...documents.map((document) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.description,
                          color: AppColors.primary),
                      title: Text(document.fileName),
                      subtitle: Text(document.docType),
                    ),
                  )),
            const SizedBox(height: 20),
            if (item.integrityHash != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: verified
                      ? AppColors.primaryContainer
                      : const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(verified ? Icons.verified_user : Icons.gpp_bad,
                        color: verified ? AppColors.primary : AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(verified
                          ? 'Registro íntegro · firma SHA-256 verificada'
                          : 'La firma de este registro no coincide.'),
                    ),
                  ],
                ),
              ),
            if (reviewStateLoaded && reviewExists) ...[
              const SizedBox(height: 20),
              const Chip(
                avatar: Icon(Icons.check_circle, size: 18),
                label: Text('Esta atención ya fue evaluada'),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: reviewStateLoaded && canReview
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(30, 10, 30, 18),
              child: ElevatedButton.icon(
                onPressed: () => openReview(item),
                icon: const Icon(Icons.star),
                label: const Text('Evaluar atención'),
              ),
            )
          : null,
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(content),
            ),
          ],
        ),
      );
}
