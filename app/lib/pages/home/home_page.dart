import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/medication_adherence/medication_adherence_page.dart';
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
    debugPrint('🏠 HomePage.build() called');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Tab 0: Home (Pets)
            _buildHomeTab(),
            // Tab 1: Medication
            MedicationAdherencePage(),
            // Tab 2: Profile
            ProfilePage(),
            // Tab 3: Alerts
            EpidemiologicalMapPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Meds'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Obx(() {
      final user = ctrl.appCtrl.currentUser.value;
      final error = ctrl.errorMessage.value;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error banner
              if (error.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('⚠️ $error'),
                ),
                const SizedBox(height: 20),
              ],

              // Greeting
              if (user != null) ...[
                Text(
                  '👋 Good morning, ${user.firstName}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],

              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📊 Account Status', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('👤 ${user?.firstName ?? ''} ${user?.lastName ?? ''}'),
                    Text('📧 ${user?.email ?? ''}'),
                    Text('👨‍⚕️ Role: ${user?.role ?? ''}'),
                    Text('🐾 Pets: ${ctrl.pets.length}'),
                    if (ctrl.isLoading.value) ...[
                      const SizedBox(height: 10),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                )),
              ),

              const SizedBox(height: 20),

              // Pets section
              const Text('🐾 Your Pets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.pets.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No pets yet. Add your first pet to get started!'),
                  );
                }
                return Column(
                  children: [
                    for (final pet in ctrl.pets)
                      ListTile(
                        leading: const Icon(Icons.pets),
                        title: Text(pet.name),
                        subtitle: Text('${pet.speciesName ?? 'Unknown'} · ${pet.sexCode ?? '?'}'),
                        onTap: () => ctrl.goToPetProfile(pet),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Add Pet button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: ctrl.goToAddPet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Pet'),
                ),
              ),

              const SizedBox(height: 20),

              // Sign out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showSignOutDialog(),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/sign-in');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
