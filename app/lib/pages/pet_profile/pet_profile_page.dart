import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/monochrome_button.dart';
import '../../components/vc_widgets.dart';
import '../../models/consultation.dart';
import 'pet_profile_controller.dart';

class PetProfilePage extends StatelessWidget {
  PetProfilePage({super.key});

  final PetProfileController ctrl = Get.put(PetProfileController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Get.back()),
        title: Obx(() => Text(ctrl.pet.value?.name ?? '')),
      ),
      body: SafeArea(
        child: Obx(() {
          final pet = ctrl.pet.value;
          if (pet == null) return const SizedBox.shrink();
          return RefreshIndicator(
            color: cs.onSurface,
            backgroundColor: cs.surface,
            onRefresh: ctrl.loadConsultations,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet hero
                      _PetHero(pet: pet, cs: cs),
                      // Data grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            if (pet.speciesName != null) VcDataRow(label: 'Species', value: pet.speciesName!),
                            if (pet.breedName != null) VcDataRow(label: 'Breed', value: pet.breedName!),
                            if (pet.sexCode != null) VcDataRow(label: 'Sex', value: pet.sexCode == 'M' ? 'Male' : 'Female'),
                            if (pet.weightKg != null) VcDataRow(label: 'Weight', value: '${pet.weightKg} kg'),
                            if (pet.ageYears > 0) VcDataRow(label: 'Age', value: '${pet.ageYears} yr${pet.ageYears > 1 ? 's' : ''}'),
                            if (pet.microchip != null) VcDataRow(label: 'Microchip', value: pet.microchip!),
                          ],
                        ),
                      ),
                      // Book appointment button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: MonochromeButton(label: 'book_appointment'.tr, onPressed: ctrl.goToBookAppointment),
                      ),
                      const SizedBox(height: 24),
                      // Exotic section
                      if (pet.isExotic) _ExoticSection(ctrl: ctrl, cs: cs),
                      // History label
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        child: Text('CLINICAL HISTORY',
                            style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                      ),
                    ],
                  ),
                ),
                // Consultations list
                Obx(() {
                  if (ctrl.isLoading.value) {
                    return SliverToBoxAdapter(
                      child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: cs.onSurface, strokeWidth: 1.5))),
                    );
                  }
                  if (ctrl.consultations.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('No consultations yet.', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.45))),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ConsultationTile(c: ctrl.consultations[i], onTap: () => ctrl.goToHistory(ctrl.consultations[i]), cs: cs),
                        childCount: ctrl.consultations.length,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PetHero extends StatelessWidget {
  final dynamic pet;
  final ColorScheme cs;
  const _PetHero({required this.pet, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.onSurface.withValues(alpha: 0.15), width: 1)),
        image: pet.photoUrl != null
            ? DecorationImage(image: NetworkImage(pet.photoUrl!), fit: BoxFit.cover)
            : null,
        color: cs.onSurface.withValues(alpha: 0.05),
      ),
      child: pet.photoUrl == null
          ? Center(child: Icon(Icons.pets, size: 60, color: cs.onSurface.withValues(alpha: 0.2)))
          : null,
    );
  }
}

class _ExoticSection extends StatelessWidget {
  final PetProfileController ctrl;
  final ColorScheme cs;
  const _ExoticSection({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXOTIC · CITES', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
          const SizedBox(height: 8),
          Obx(() {
            if (ctrl.morphological.isEmpty) {
              return Text('No morphological records.', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)));
            }
            final last = ctrl.morphological.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (last.lengthCm != null) VcDataRow(label: 'Length', value: '${last.lengthCm} cm'),
                if (last.weightKg != null) VcDataRow(label: 'Weight', value: '${last.weightKg} kg'),
                if (last.scaleCondition != null) VcDataRow(label: 'Scale condition', value: last.scaleCondition!),
                if (last.colorPattern != null) VcDataRow(label: 'Color pattern', value: last.colorPattern!),
              ],
            );
          }),
          const SizedBox(height: 8),
          Obx(() {
            if (ctrl.legalDocs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('LEGAL DOCUMENTS', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                const SizedBox(height: 8),
                ...ctrl.legalDocs.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          MonoBadge(label: d.docType),
                          const SizedBox(width: 8),
                          if (d.isExpired) MonoBadge(label: 'EXPIRED'),
                        ],
                      ),
                    )),
              ],
            );
          }),
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  final Consultation c;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _ConsultationTile({required this.c, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${c.scheduledAt.day.toString().padLeft(2, '0')}/${c.scheduledAt.month.toString().padLeft(2, '0')}/${c.scheduledAt.year}',
                    style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                  if (c.reason != null)
                    Text(c.reason!, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
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
