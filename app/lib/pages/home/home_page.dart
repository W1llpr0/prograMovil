import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/swipe_to_confirm.dart';
import '../../components/pet_card.dart';
import '../../configs/app_routes.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/epidemiological_map/epidemiological_map_page.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController ctrl;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildDashboardTab(context),
            _buildPetsListTab(context),
            _buildAppointmentTab(context),
            EpidemiologicalMapPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Builder(builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.onSurface, width: 1)),
            color: scheme.surface,
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedTabIndex,
            onTap: (index) => setState(() => _selectedTabIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: scheme.surface,
            selectedItemColor: scheme.onSurface,
            unselectedItemColor: scheme.onSurface.withValues(alpha: 0.45),
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: 'dashboard'.tr),
              BottomNavigationBarItem(icon: const Icon(Icons.pets), label: 'my_pets'.tr),
              BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: 'book'.tr),
              BottomNavigationBarItem(icon: const Icon(Icons.location_on_outlined), label: 'map'.tr),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: 'profile'.tr),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Obx(() {
      final user = ctrl.appCtrl.currentUser.value;
      final error = ctrl.errorMessage.value;
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE · d MMM', Get.locale?.toLanguageTag() == 'es' ? 'es_ES' : 'en_US')
                    .format(DateTime.now()),
                style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 8),
              if (user != null) Text('${'good_morning'.tr}, ${user.firstName}.', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.04 * 32, color: fg)),
              const SizedBox(height: 20),
              if (error.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(8)), child: Text('⚠️ $error')),
              Obx(() {
                final med = ctrl.nextDoseMedication.value;
                final medEmpty = med == 'No active medications' || med == 'No pets registered yet';
                return Container(
                  decoration: BoxDecoration(border: Border.all(color: fg, width: 1), borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${'next_dose'.tr} · ${ctrl.nextDoseTime.value}', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18)),
                          const SizedBox(height: 10),
                          Text(
                            med == 'No active medications' ? 'no_active_meds'.tr
                              : med == 'No pets registered yet' ? 'no_pets_meds'.tr
                              : med,
                            style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(ctrl.nextDoseDetails.value, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: fg.withValues(alpha: 0.6))),
                        ])),
                        const SizedBox(width: 12),
                        Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: fg, width: 1), borderRadius: BorderRadius.circular(999)), child: Icon(Icons.medication_outlined, size: 20, color: fg)),
                      ]),
                      if (!medEmpty) ...[
                        const SizedBox(height: 18),
                        SizedBox(height: 28, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          for (final h in [0.6, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.0, 0.8, 1.0, 1.0, 1.0, 1.0, 0.7]) ...[
                            Expanded(child: Align(alignment: Alignment.bottomCenter, child: FractionallySizedBox(heightFactor: h < 0.06 ? 0.06 : h, child: Container(decoration: BoxDecoration(color: h == 0 ? Colors.transparent : fg, border: h == 0 ? Border.all(color: fg, width: 1) : null, borderRadius: BorderRadius.circular(1)))))),          
                            const SizedBox(width: 3),
                          ]
                        ])),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('adherence_14'.tr, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55))),
                          Text('92%', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.06)),
                        ]),
                        const SizedBox(height: 18),
                        SwipeToConfirm(onConfirmed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Dose recorded successfully')))),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text('upcoming'.tr, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55))),
              const SizedBox(height: 12),
              Obx(() {
                if (ctrl.upcomingAppointments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text('no_appointments'.tr, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: fg.withValues(alpha: 0.5))),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (int i = 0; i < ctrl.upcomingAppointments.length; i++)
                      _buildAppointmentRow(
                        context: context,
                        date: ctrl.upcomingAppointments[i]['date'],
                        time: ctrl.upcomingAppointments[i]['time'],
                        title: '${ctrl.upcomingAppointments[i]['title']} · ${ctrl.upcomingAppointments[i]['petName']}',
                        doctor: ctrl.upcomingAppointments[i]['vetName'],
                        isLast: i == ctrl.upcomingAppointments.length - 1,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPetsListTab(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Obx(() => Text('${ctrl.pets.length.toString().padLeft(2, '0')} / ${ctrl.pets.length.toString().padLeft(2, '0')}', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55)))),
                Text('your_pets'.tr, style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.04 * 28, color: fg)),
              ]),
              GestureDetector(onTap: ctrl.goToAddPet, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(border: Border.all(color: fg, width: 1), borderRadius: BorderRadius.circular(999)), child: Row(children: [Text('add'.tr, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.12, color: fg)), const SizedBox(width: 6), Icon(Icons.add, size: 12, color: fg)]))),
            ]),
            const SizedBox(height: 20),
            Obx(() {
              if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (ctrl.pets.isEmpty) return Container(padding: const EdgeInsets.all(40), child: Center(child: Text('no_pets_yet'.tr, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 13, height: 1.6, color: fg.withValues(alpha: 0.45)))));
              return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: ctrl.pets.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (ctx, i) {
                final pet = ctrl.pets[i];
                final birthDate = pet.birthDate ?? DateTime.now();
                final ageYears = DateTime.now().year - birthDate.year;
                final ageMonths = (DateTime.now().month - birthDate.month).abs();
                return PetCard(
                  name: pet.name ?? 'Unknown',
                  species: pet.speciesName ?? 'Unknown',
                  breed: (pet.breedName ?? pet.speciesName ?? 'Unknown'),
                  sex: pet.sexCode ?? '?',
                  ageYears: ageYears,
                  ageMonths: ageMonths > 0 ? ageMonths : 0,
                  status: 'active',
                  onTap: () => ctrl.goToPetProfile(pet),
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentTab(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('book_appointment'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04 * 28,
                    color: fg,
                  )),
              const SizedBox(height: 20),
              if (ctrl.pets.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.pets_outlined, size: 64, color: fg.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('no_pets_yet_appt'.tr,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.6))),
                        const SizedBox(height: 8),
                        Text('no_pets_appt_hint'.tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: fg.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                if (ctrl.vets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.medical_services_outlined, size: 64, color: fg.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text('no_vets_available'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Text('select_pet_appointment'.tr,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10, letterSpacing: 0.18, color: fg.withValues(alpha: 0.55))),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctrl.pets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final pet = ctrl.pets[i];
                      final birthDate = pet.birthDate ?? DateTime.now();
                      final ageYears = DateTime.now().year - birthDate.year;
                      final ageMonths = (DateTime.now().month - birthDate.month).abs();
                      return GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.bookAppointment,
                          arguments: pet,
                        )?.then((_) => ctrl.loadUpcomingAppointments()),
                        child: PetCard(
                          name: pet.name,
                          species: pet.speciesName ?? '',
                          breed: pet.breedName ?? pet.speciesName ?? '',
                          sex: pet.sexCode ?? '?',
                          ageYears: ageYears,
                          ageMonths: ageMonths > 0 ? ageMonths : 0,
                          status: 'active',
                          onTap: () => Get.toNamed(
                            AppRoutes.bookAppointment,
                            arguments: pet,
                          )?.then((_) => ctrl.loadUpcomingAppointments()),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppointmentRow({required BuildContext context, required String date, required String time, required String title, required String doctor, bool isLast = false}) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: fg), bottom: isLast ? BorderSide(color: fg) : BorderSide.none)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(date, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.12, color: fg.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          Text(time, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
        ]),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
          const SizedBox(height: 4),
          Text(doctor, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: fg.withValues(alpha: 0.55))),
        ]))),
        Icon(Icons.chevron_right, size: 16, color: fg),
      ]),
    );
  }
}
