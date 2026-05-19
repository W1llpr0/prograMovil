import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/vc_widgets.dart';
import 'clinical_history_controller.dart';

class ClinicalHistoryPage extends StatelessWidget {
  ClinicalHistoryPage({super.key});

  final ClinicalHistoryController ctrl = Get.put(ClinicalHistoryController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('clinical_history'.tr),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Obx(() {
          final c = ctrl.consultation.value;
          if (c == null) return const SizedBox.shrink();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  '${c.scheduledAt.day.toString().padLeft(2, '0')} / ${c.scheduledAt.month.toString().padLeft(2, '0')} / ${c.scheduledAt.year}',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                MonoBadge(label: c.status),
                const SizedBox(height: 24),
                // Integrity badge
                if (ctrl.integrityChecked.value) _IntegrityBanner(ok: ctrl.integrityOk.value, cs: cs),
                const SizedBox(height: 16),
                // Details
                if (c.reason != null) ...[
                  _Field(label: 'REASON', value: c.reason!, cs: cs),
                  const SizedBox(height: 16),
                ],
                if (c.diagnosis != null) ...[
                  _Field(label: 'DIAGNOSIS', value: c.diagnosis!, cs: cs),
                  const SizedBox(height: 16),
                ],
                if (c.treatment != null) ...[
                  _Field(label: 'TREATMENT', value: c.treatment!, cs: cs),
                  const SizedBox(height: 16),
                ],
                if (c.notes != null) ...[
                  _Field(label: 'NOTES', value: c.notes!, cs: cs),
                  const SizedBox(height: 16),
                ],
                if (c.isContagious) ...[
                  const SizedBox(height: 8),
                  MonoBadge(label: '⚠ CONTAGIOUS'),
                ],
                if (c.integrityHash != null) ...[
                  const SizedBox(height: 24),
                  Text('SHA-256 HASH', style: TextStyle(fontSize: 9, letterSpacing: 0.22, color: cs.onSurface.withValues(alpha: 0.45))),
                  const SizedBox(height: 4),
                  Text(
                    c.integrityHash!,
                    style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 10, letterSpacing: 0.05, color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _IntegrityBanner extends StatelessWidget {
  final bool ok;
  final ColorScheme cs;
  const _IntegrityBanner({required this.ok, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? cs.onSurface : Colors.transparent,
        border: Border.all(color: cs.onSurface, width: 1),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.verified_outlined : Icons.warning_amber_outlined, size: 16, color: ok ? cs.surface : cs.onSurface),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok ? 'integrity_verified'.tr : 'integrity_failed'.tr,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.22,
                color: ok ? cs.surface : cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  const _Field({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9, letterSpacing: 0.22, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 15, color: cs.onSurface, height: 1.5)),
      ],
    );
  }
}
