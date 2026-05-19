import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/vc_widgets.dart';
import '../../models/epidemiological_alert.dart';
import 'epidemiological_map_controller.dart';

class EpidemiologicalMapPage extends StatelessWidget {
  EpidemiologicalMapPage({super.key});

  final EpidemiologicalMapController ctrl = Get.put(EpidemiologicalMapController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('epidemiological_alerts'.tr),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Get.back()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: ctrl.loadAlerts,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: cs.onSurface, strokeWidth: 1.5));
          }
          if (ctrl.alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: cs.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No active epidemiological alerts\nin your area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: cs.onSurface.withValues(alpha: 0.55), height: 1.6),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: cs.onSurface,
            backgroundColor: cs.surface,
            onRefresh: ctrl.loadAlerts,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                Text(
                  '${ctrl.alerts.length} ACTIVE ALERT${ctrl.alerts.length > 1 ? 'S' : ''}',
                  style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45)),
                ),
                const SizedBox(height: 12),
                ...ctrl.alerts.map((a) => _AlertCard(alert: a, cs: cs)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final EpidemiologicalAlert alert;
  final ColorScheme cs;
  const _AlertCard({required this.alert, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: cs.onSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, size: 16, color: cs.onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.disease.toUpperCase(),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ),
              MonoBadge(label: '${alert.radiusKm.toStringAsFixed(0)} km'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reported ${_relativeDate(alert.createdAt)}',
            style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55)),
          ),
          if (alert.latitude != null && alert.longitude != null) ...[
            const SizedBox(height: 4),
            Text(
              'Lat ${alert.latitude!.toStringAsFixed(4)}, Lng ${alert.longitude!.toStringAsFixed(4)}',
              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 10, letterSpacing: 0.05, color: cs.onSurface.withValues(alpha: 0.45)),
            ),
          ],
        ],
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
