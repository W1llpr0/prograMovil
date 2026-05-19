import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../components/vc_widgets.dart';
import 'register_medical_controller.dart';

class RegisterMedicalPage extends StatelessWidget {
  RegisterMedicalPage({super.key});

  final RegisterMedicalController ctrl = Get.put(RegisterMedicalController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEDICAL RECORD'),
        leading: IconButton(icon: Icon(Icons.close, color: cs.onSurface), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Consultation info
              if (ctrl.consultation != null) ...[
                Text('CONSULTATION', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                const SizedBox(height: 8),
                if (ctrl.consultation!.petName != null)
                  VcDataRow(label: 'Pet', value: ctrl.consultation!.petName!),
                VcDataRow(
                  label: 'Scheduled',
                  value: '${ctrl.consultation!.scheduledAt.day}/${ctrl.consultation!.scheduledAt.month}/${ctrl.consultation!.scheduledAt.year} '
                      '${ctrl.consultation!.scheduledAt.hour.toString().padLeft(2, '0')}:${ctrl.consultation!.scheduledAt.minute.toString().padLeft(2, '0')}',
                ),
                const Divider(height: 32),
              ],
              LineInput(
                controller: ctrl.diagnosisCtrl,
                label: 'DIAGNOSIS',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              LineInput(
                controller: ctrl.treatmentCtrl,
                label: 'TREATMENT',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              LineInput(
                controller: ctrl.notesCtrl,
                label: 'NOTES (optional)',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              // Contagious toggle
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CONTAGIOUS DISEASE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface)),
                          Text('Will trigger an epidemiological alert', style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45))),
                        ],
                      ),
                      Switch(value: ctrl.isContagious.value, onChanged: (v) => ctrl.isContagious.value = v),
                    ],
                  )),
              const SizedBox(height: 24),
              // SHA-256 note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: cs.onSurface.withValues(alpha: 0.2), width: 1)),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: cs.onSurface.withValues(alpha: 0.55)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A SHA-256 integrity hash will be generated and stored with this record.',
                        style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 10, color: cs.onSurface.withValues(alpha: 0.55), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => ctrl.message.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(ctrl.message.value, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.7))),
                    )),
              Obx(() => MonochromeButton(
                    label: 'SAVE RECORD',
                    onPressed: ctrl.save,
                    isLoading: ctrl.isLoading.value,
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
