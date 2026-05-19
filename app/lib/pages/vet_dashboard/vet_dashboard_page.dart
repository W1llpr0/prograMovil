import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/vc_widgets.dart';
import '../../models/consultation.dart';
import 'vet_dashboard_controller.dart';

class VetDashboardPage extends StatelessWidget {
  VetDashboardPage({super.key});

  final VetDashboardController ctrl = Get.put(VetDashboardController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: cs.onSurface,
          backgroundColor: cs.surface,
          onRefresh: ctrl.loadAgenda,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('VetCare', style: TextStyle(fontSize: 11, letterSpacing: 0.32, color: cs.onSurface.withValues(alpha: 0.45))),
                              Text(
                                'Dr. ${ctrl.appCtrl.currentUser.value?.lastName ?? ''}',
                                style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.04, color: cs.onSurface),
                              ),
                            ],
                          )),
                      IconButton(
                        icon: Icon(Icons.person_outline, color: cs.onSurface),
                        onPressed: ctrl.goToProfile,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text('TODAY\'S AGENDA', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                ),
              ),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return SliverToBoxAdapter(
                    child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: cs.onSurface, strokeWidth: 1.5))),
                  );
                }
                if (ctrl.agenda.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Text('No appointments scheduled.', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.45)))),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AgendaTile(c: ctrl.agenda[i], onTap: () => ctrl.goToRegister(ctrl.agenda[i]), cs: cs),
                      childCount: ctrl.agenda.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  final Consultation c;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _AgendaTile({required this.c, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1)),
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${c.scheduledAt.hour.toString().padLeft(2, '0')}:${c.scheduledAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  Text(
                    '${c.scheduledAt.day}/${c.scheduledAt.month}',
                    style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45)),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: cs.onSurface.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.petName != null) Text(c.petName!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  if (c.reason != null) Text(c.reason!, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
            MonoBadge(label: c.status),
          ],
        ),
      ),
    );
  }
}
