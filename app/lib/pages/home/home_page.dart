import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/vc_widgets.dart';
import '../../models/pet.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController ctrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: cs.onSurface,
          backgroundColor: cs.surface,
          onRefresh: ctrl.loadPets,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VetCare',
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 11,
                                      letterSpacing: 0.32,
                                      color: cs.onSurface.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  Text(
                                    ctrl.appCtrl.currentUser.value?.firstName ?? '',
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.04,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              )),
                          Row(
                            children: [
                              IconButton(
                                onPressed: ctrl.goToAlerts,
                                icon: Icon(Icons.notifications_none_outlined, color: cs.onSurface),
                              ),
                              IconButton(
                                onPressed: ctrl.goToProfile,
                                icon: Icon(Icons.person_outline, color: cs.onSurface),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Quick actions row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Row(
                        children: [
                          _QuickAction(
                            icon: Icons.vaccines_outlined,
                            label: 'MEDICATION',
                            onTap: ctrl.goToMedication,
                            cs: cs,
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.warning_amber_outlined,
                            label: 'ALERTS',
                            onTap: ctrl.goToAlerts,
                            cs: cs,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // My Pets section label
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MY PETS',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 9,
                              letterSpacing: 0.32,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                          GestureDetector(
                            onTap: ctrl.goToAddPet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.onSurface, width: 1),
                              ),
                              child: Text(
                                '+ ADD',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 9,
                                  letterSpacing: 0.22,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator(color: cs.onSurface, strokeWidth: 1.5)),
                    ),
                  );
                }
                if (ctrl.pets.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Text(
                          'No pets yet.\nTap + ADD to register your first pet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.45),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _PetCard(pet: ctrl.pets[i], onTap: () => ctrl.goToPetProfile(ctrl.pets[i]), cs: cs),
                      childCount: ctrl.pets.length,
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _QuickAction({required this.icon, required this.label, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: cs.onSurface.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cs.onSurface),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10,
                  letterSpacing: 0.22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _PetCard({required this.pet, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: cs.onSurface.withValues(alpha: 0.2), width: 1),
                image: pet.photoUrl != null
                    ? DecorationImage(image: NetworkImage(pet.photoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: pet.photoUrl == null
                  ? Icon(Icons.pets, size: 22, color: cs.onSurface.withValues(alpha: 0.35))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.02,
                          color: cs.onSurface,
                        ),
                      ),
                      if (pet.isExotic) ...[
                        const SizedBox(width: 8),
                        MonoBadge(label: 'Exotic'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [pet.speciesName, pet.breedName].where((e) => e != null).join(' · '),
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  if (pet.ageYears > 0)
                    Text(
                      '${pet.ageYears} yr${pet.ageYears > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: cs.onSurface.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
