import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/app_routes.dart';
import '../../configs/theme.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';

class PreConsultationPage extends StatefulWidget {
  const PreConsultationPage({super.key});

  @override
  State<PreConsultationPage> createState() => _PreConsultationPageState();
}

class _PreConsultationPageState extends State<PreConsultationPage> {
  final service = ConsultationService();
  bool loading = false;
  String? error;

  Consultation? get consultation => Get.arguments as Consultation?;

  Future<void> start() async {
    final item = consultation;
    if (item?.id == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    final result = await service.startConsultation(item!.id!);
    if (!mounted) return;
    setState(() => loading = false);
    if (result.success && result.data != null) {
      Get.offNamed(AppRoutes.registerMedical, arguments: result.data);
    } else {
      setState(() => error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = consultation;
    if (item == null) {
      return const Scaffold(
          body: Center(child: Text('Consulta no encontrada.')));
    }
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back)),
        title: const Text('Expediente clínico'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFFFE0B2),
                child: Icon(Icons.pets, color: Colors.deepOrange, size: 42),
              ),
              const SizedBox(height: 10),
              Text(item.petName ?? 'Paciente',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text([
                item.petBreed,
                item.petSex == 'M'
                    ? 'Macho'
                    : item.petSex == 'F'
                        ? 'Hembra'
                        : null,
              ].whereType<String>().join(' · ')),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        icon: Icons.monitor_weight_outlined,
                        value: item.petWeightKg == null
                            ? 'Sin dato'
                            : '${item.petWeightKg!.toStringAsFixed(1)} kg',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        icon: Icons.coronavirus_outlined,
                        value: item.petAllergies?.trim().isNotEmpty == true
                            ? item.petAllergies!
                            : 'Sin alergias',
                        danger: item.petAllergies?.trim().isNotEmpty == true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Motivo escrito por el cliente:',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  border: Border.all(color: const Color(0xFFFFD966)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('“${item.reason ?? 'Sin motivo especificado.'}”'),
              ),
              const Spacer(),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(error!,
                      style: const TextStyle(color: AppColors.error)),
                ),
              ElevatedButton.icon(
                onPressed: loading ? null : start,
                icon: loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle),
                label: const Text('Iniciar consulta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool danger;
  const _Metric({required this.icon, required this.value, this.danger = false});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: danger ? AppColors.error : AppColors.outline),
          const SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: danger ? AppColors.error : AppColors.onSurface,
              )),
        ],
      );
}
