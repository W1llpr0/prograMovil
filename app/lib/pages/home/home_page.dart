import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/epidemiological_map/epidemiological_map_page.dart';
import '../../pages/book_appointment/book_appointment_page.dart';
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
    debugPrint('🏠 HomePage.build() called - Tab: $_selectedTabIndex');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Tab 0: Dashboard
            _buildDashboardTab(),
            // Tab 1: Pets List
            _buildPetsListTab(),
            // Tab 2: Book Appointment
            BookAppointmentPage(),
            // Tab 3: Map/Alerts
            EpidemiologicalMapPage(),
            // Tab 4: Profile
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 1)),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined, size: 22),
              activeIcon: const Icon(Icons.home, size: 22),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.pets, size: 22),
              label: 'Pets',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today, size: 22),
              label: 'Book',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_on_outlined, size: 22),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Obx(() {
      final user = ctrl.appCtrl.currentUser.value;
      final error = ctrl.errorMessage.value;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tuesday · 19 May', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black.withValues(alpha: 0.55))),
              const SizedBox(height: 8),
              if (user != null) Text('Good morning, ${user.firstName}.', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.04 * 32)),
              const SizedBox(height: 20),
              if (error.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(8)), child: Text('⚠️ $error')),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1), borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('NEXT DOSE · IN 04:12', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18)),
                        const SizedBox(height: 10),
                        Text('Apoquel 16 mg', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Max · 1 tablet · with food', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.black.withValues(alpha: 0.6))),
                      ]),
                      Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1), borderRadius: BorderRadius.circular(999)), child: const Icon(Icons.medication_outlined, size: 20)),
                    ]),
                    const SizedBox(height: 18),
                    SizedBox(height: 28, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      for (final h in [0.6, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.0, 0.8, 1.0, 1.0, 1.0, 1.0, 0.7]) ...[
                        Expanded(child: Align(alignment: Alignment.bottomCenter, child: FractionallySizedBox(heightFactor: h < 0.06 ? 0.06 : h, child: Container(decoration: BoxDecoration(color: h == 0 ? Colors.transparent : Colors.black, border: h == 0 ? Border.all(color: Colors.black, width: 1) : null, borderRadius: BorderRadius.circular(1)))))),
                        const SizedBox(width: 3),
                      ]
                    ])),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('14-DAY ADHERENCE', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18, color: Colors.black.withValues(alpha: 0.55))),
                      Text('92%', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.06)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('UPCOMING', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black.withValues(alpha: 0.55))),
              const SizedBox(height: 12),
              _buildAppointmentRow(date: '21 MAY', time: '10:30', title: 'Annual checkup · Max', doctor: 'Dr. R. Paz'),
              _buildAppointmentRow(date: '24 MAY', time: '17:00', title: 'Consultation · Donatello', doctor: 'Dr. R. Paz', isLast: true),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPetsListTab() {
    return Obx(() => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Obx(() => Text('${ctrl.pets.length.toString().padLeft(2, '0')} / ${ctrl.pets.length.toString().padLeft(2, '0')}', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black.withValues(alpha: 0.55)))),
                Text('Your pets', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.04 * 28)),
              ]),
              GestureDetector(
                onTap: ctrl.goToAddPet,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1), borderRadius: BorderRadius.circular(999)), child: Row(children: [
                  Text('ADD', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.12)),
                  const SizedBox(width: 6),
                  const Icon(Icons.add, size: 12),
                ])),
              ),
            ]),
            const SizedBox(height: 20),
            Obx(() {
              if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (ctrl.pets.isEmpty) return Container(padding: const EdgeInsets.all(40), child: Center(child: Text('No pets yet.\nTap ADD to register your first pet.', textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 13, height: 1.6, color: Colors.black.withValues(alpha: 0.45)))));
              return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: ctrl.pets.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (ctx, i) => _buildPetListItem(ctrl.pets[i]));
            }),
          ],
        ),
      ),
    ));
  }

  Widget _buildPetListItem(dynamic pet) {
    return GestureDetector(
      onTap: () => ctrl.goToPetProfile(pet),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.pets, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pet.name ?? 'Unknown', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${pet.speciesName ?? 'Unknown'} · ${pet.sexCode ?? '?'}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.black.withValues(alpha: 0.55))),
          ])),
          const Icon(Icons.chevron_right, size: 16),
        ]),
      ),
    );
  }

  Widget _buildAppointmentRow({required String date, required String time, required String title, required String doctor, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: Colors.black),
          bottom: isLast ? const BorderSide(color: Colors.black) : BorderSide.none,
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(date, style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.12, color: Colors.black.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          Text(time, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(doctor, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.black.withValues(alpha: 0.55))),
        ]))),
        const Icon(Icons.chevron_right, size: 16),
      ]),
    );
  }
}
