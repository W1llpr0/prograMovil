import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/app_routes.dart';
import '../../configs/theme.dart';
import '../../models/pet.dart';
import '../profile/profile_page.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController ctrl = Get.put(HomeController());
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: selectedIndex,
            children: [
              _Dashboard(controller: ctrl),
              _Pets(controller: ctrl),
              _Appointments(controller: ctrl),
              ProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => selectedIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.pets), label: 'Mascotas'),
            NavigationDestination(
                icon: Icon(Icons.calendar_month), label: 'Citas'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      );
}

class _Dashboard extends StatelessWidget {
  final HomeController controller;
  const _Dashboard({required this.controller});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async => Future.wait([
          controller.loadPets(),
          controller.loadUpcomingAppointments(),
          controller.loadNextDose(),
        ]),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 32),
          children: [
            Row(
              children: [
                Obx(() {
                  final user = controller.appCtrl.currentUser.value;
                  return CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Text(_initials(user?.fullName ?? 'Usuario')),
                  );
                }),
                const SizedBox(width: 14),
                Expanded(
                  child: Obx(() => Text(
                        'Hola, ${controller.appCtrl.currentUser.value?.firstName ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                ),
                IconButton(
                  tooltip: 'Alertas epidemiológicas',
                  onPressed: controller.goToAlerts,
                  icon: const Icon(Icons.notifications),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() => controller.upcomingAppointments.isEmpty
                ? _AppointmentHero.empty(
                    onTap: () => Get.toNamed(AppRoutes.bookAppointment))
                : _AppointmentHero(
                    appointment: controller.upcomingAppointments.first,
                    onTap: () => Get.toNamed(AppRoutes.bookAppointment),
                  )),
            const SizedBox(height: 24),
            Text('Servicios', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    icon: Icons.event_available,
                    label: 'Agendar cita',
                    onTap: () => Get.toNamed(AppRoutes.bookAppointment)
                        ?.then((_) => controller.loadUpcomingAppointments()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ServiceCard(
                    icon: Icons.medication,
                    label: 'Medicamentos',
                    onTap: controller.goToMedication,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mis mascotas',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                    onPressed: controller.goToAddPet,
                    child: const Text('Añadir')),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => SizedBox(
                  height: 105,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.pets.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, index) {
                      if (index == controller.pets.length) {
                        return _PetBubble.add(onTap: controller.goToAddPet);
                      }
                      final pet = controller.pets[index];
                      return _PetBubble(
                        pet: pet,
                        onTap: () => controller.goToPetProfile(pet),
                      );
                    },
                  ),
                )),
          ],
        ),
      );

  static String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class _Pets extends StatelessWidget {
  final HomeController controller;
  const _Pets({required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mis mascotas')),
        body: Obx(() {
          if (controller.isLoading.value && controller.pets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.pets.isEmpty) {
            return const Center(
                child: Text('Todavía no registraste mascotas.'));
          }
          return RefreshIndicator(
            onRefresh: controller.loadPets,
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: controller.pets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, index) {
                final pet = controller.pets[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFFFE0B2),
                      child: Icon(Icons.pets, color: Colors.deepOrange),
                    ),
                    title: Text(pet.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        '${pet.breedName ?? pet.speciesName ?? 'Mascota'} · ${pet.ageYears} años'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => controller.goToPetProfile(pet),
                  ),
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.goToAddPet,
          backgroundColor: AppColors.primaryContainer,
          child: const Icon(Icons.add),
        ),
      );
}

class _Appointments extends StatelessWidget {
  final HomeController controller;
  const _Appointments({required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mis citas')),
        body: Obx(() => controller.upcomingAppointments.isEmpty
            ? const Center(child: Text('No tienes citas próximas.'))
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: controller.upcomingAppointments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final item = controller.upcomingAppointments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month,
                          color: AppColors.primary),
                      title: Text('${item['title']} · ${item['petName']}'),
                      subtitle: Text(
                          '${item['date']} · ${item['time']}\n${item['vetName']}'),
                      isThreeLine: true,
                    ),
                  );
                },
              )),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.bookAppointment)
              ?.then((_) => controller.loadUpcomingAppointments()),
          icon: const Icon(Icons.add),
          label: const Text('Nueva cita'),
        ),
      );
}

class _AppointmentHero extends StatelessWidget {
  final Map<String, dynamic>? appointment;
  final VoidCallback onTap;
  const _AppointmentHero({required this.appointment, required this.onTap});
  const _AppointmentHero.empty({required this.onTap}) : appointment = null;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: appointment == null
              ? const Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Agenda tu próxima consulta',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${appointment!['date']} ${appointment!['time']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Icon(Icons.event, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Consulta: ${appointment!['petName']}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    Text(
                        '${appointment!['vetName']} · ${appointment!['title']}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
        ),
      );
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ServiceCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(90),
          foregroundColor: AppColors.primary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 6),
            Text(label)
          ],
        ),
      );
}

class _PetBubble extends StatelessWidget {
  final Pet? pet;
  final VoidCallback onTap;
  const _PetBubble({required this.pet, required this.onTap});
  const _PetBubble.add({required this.onTap}) : pet = null;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          width: 66,
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    pet == null ? AppColors.surface : const Color(0xFFFFE0B2),
                child: Icon(pet == null ? Icons.add : Icons.pets,
                    color: pet == null ? AppColors.outline : Colors.deepOrange),
              ),
              const SizedBox(height: 6),
              Text(pet?.name ?? 'Añadir',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}
