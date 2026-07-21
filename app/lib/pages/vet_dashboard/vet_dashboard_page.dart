import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../configs/theme.dart';
import '../../models/consultation.dart';
import '../profile/profile_page.dart';
import 'vet_dashboard_controller.dart';

class VetDashboardPage extends StatefulWidget {
  const VetDashboardPage({super.key});

  @override
  State<VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<VetDashboardPage> {
  late final VetDashboardController ctrl = Get.put(VetDashboardController());
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: selectedIndex,
            children: [
              _VetHome(
                  controller: ctrl,
                  openAgenda: () => setState(() => selectedIndex = 1)),
              _VetAgenda(controller: ctrl),
              _Patients(controller: ctrl),
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
            NavigationDestination(
                icon: Icon(Icons.event_note), label: 'Agenda'),
            NavigationDestination(icon: Icon(Icons.group), label: 'Pacientes'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      );
}

class _VetHome extends StatelessWidget {
  final VetDashboardController controller;
  final VoidCallback openAgenda;
  const _VetHome({required this.controller, required this.openAgenda});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: controller.loadAgenda,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(34, 22, 34, 32),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Obx(() => Text(_initials(
                      controller.appCtrl.currentUser.value?.fullName ??
                          'Veterinario'))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Obx(() => Text(
                        'Dr. ${controller.appCtrl.currentUser.value?.fullName ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Resumen diario',
                    style: Theme.of(context).textTheme.titleMedium),
                Chip(
                  avatar: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                      DateFormat('dd MMM', 'es_ES').format(DateTime.now())),
                  backgroundColor: AppColors.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.groups,
                        value: controller.todayTotal,
                        label: 'Citas totales',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.pending_actions,
                        value: controller.pendingCount,
                        label: 'Pendientes',
                        danger: true,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 26),
            Text('Paciente en sala',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Obx(() {
              final current = controller.todayConsultations
                  .where((item) => item.status == 'in_progress')
                  .firstOrNull;
              final next = current ??
                  controller.todayConsultations
                      .where((item) => ['pending', 'scheduled', 'confirmed']
                          .contains(item.status))
                      .firstOrNull;
              if (next == null) {
                return _EmptyAgenda(openAgenda: openAgenda);
              }
              return _CurrentPatient(
                consultation: next,
                onTap: () => controller.goToRegister(next),
              );
            }),
          ],
        ),
      );

  String _initials(String name) => name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class _VetAgenda extends StatelessWidget {
  final VetDashboardController controller;
  const _VetAgenda({required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Mi agenda médica'),
          actions: [
            IconButton(
              tooltip: 'Disponibilidad semanal',
              onPressed: () => _showAvailability(context),
              icon: const Icon(Icons.calendar_month),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: controller.loadAgenda,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
            children: [
              SizedBox(
                height: 68,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 14,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final date = DateTime.now().add(Duration(days: index));
                    return Obx(() => ChoiceChip(
                          selected: DateUtils.isSameDay(
                              controller.selectedDate.value, date),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('EEE', 'es_ES')
                                  .format(date)
                                  .toUpperCase()),
                              Text('${date.day}',
                                  style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                          onSelected: (_) =>
                              controller.selectedDate.value = date,
                        ));
                  },
                ),
              ),
              const SizedBox(height: 22),
              Obx(() {
                final appointments = controller.selectedDateConsultations;
                if (controller.isLoading.value && appointments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (appointments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('Sin consultas para este día.')),
                  );
                }
                return Column(
                  children: appointments
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AgendaItem(
                              consultation: item,
                              onTap: () => controller.goToRegister(item),
                            ),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      );

  void _showAvailability(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Disponibilidad semanal',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (controller.availability.isEmpty)
                  const Text('Usando horario predeterminado de 09:00 a 18:00.')
                else
                  ...controller.availability.map((slot) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule,
                            color: AppColors.primary),
                        title: Text(_dayName(slot['day_of_week'] as int)),
                        subtitle: Text(
                            '${slot['start_time'].toString().substring(0, 5)} – ${slot['end_time'].toString().substring(0, 5)}'),
                      )),
              ],
            )),
      ),
    );
  }

  String _dayName(int day) => const [
        'Domingo',
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado'
      ][day];
}

class _Patients extends StatelessWidget {
  final VetDashboardController controller;
  const _Patients({required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pacientes')),
        body: Obx(() {
          final patients = controller.patients;
          if (patients.isEmpty) {
            return const Center(child: Text('Todavía no tienes pacientes.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final item = patients[index];
              final consultation = item['actionConsultation'] as Consultation;
              final status = _patientStatus(consultation.status);
              return Card(
                child: ListTile(
                  onTap: () => controller.goToRegister(consultation),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE0B2),
                    child: Icon(Icons.pets, color: Colors.deepOrange),
                  ),
                  title: Text(item['petName'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Dueño: ${item['ownerName']}\n'
                    '${item['completedCount']} atendidas · '
                    '${item['pendingConsultationCount']} pendientes · '
                    '${DateFormat('dd MMM', 'es_ES').format(item['lastDate'] as DateTime)}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status.$2.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status.$1,
                          style: TextStyle(
                            color: status.$2,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      );

  (String, Color) _patientStatus(String status) => switch (status) {
        'completed' => ('Atendido', AppColors.primary),
        'in_progress' => ('En consulta', Colors.orange),
        'cancelled' => ('Cancelado', AppColors.error),
        _ => ('Pendiente', Colors.blue),
      };
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final bool danger;
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 128,
        decoration: BoxDecoration(
          color: danger ? AppColors.surface : AppColors.surfaceContainer,
          border: Border.all(
              color: danger ? AppColors.error : AppColors.surfaceContainer),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: danger ? AppColors.error : AppColors.primary),
            const SizedBox(height: 6),
            Text('$value',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: danger ? AppColors.error : AppColors.onSurface,
                )),
            Text(label),
          ],
        ),
      );
}

class _CurrentPatient extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onTap;
  const _CurrentPatient({required this.consultation, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: Container(
          decoration: const BoxDecoration(
            border:
                Border(left: BorderSide(color: AppColors.warning, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(
                    '${DateFormat('hh:mm a').format(consultation.scheduledAt)} ${consultation.status == 'in_progress' ? '(Turno actual)' : ''}'),
                backgroundColor: const Color(0xFFFFF0C2),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE0B2),
                  child: Icon(Icons.pets, color: Colors.deepOrange),
                ),
                title: Text(consultation.petName ?? 'Paciente',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Dueño: ${consultation.ownerName ?? 'Cliente'}'),
              ),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.visibility),
                label: const Text('Ver expediente'),
              ),
            ],
          ),
        ),
      );
}

class _AgendaItem extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onTap;
  const _AgendaItem({required this.consultation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final completed = consultation.status == 'completed';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: completed ? AppColors.outline : AppColors.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(DateFormat('HH:mm').format(consultation.scheduledAt),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Container(width: 3, height: 48, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(consultation.petName ?? 'Paciente',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(consultation.specialtyName ??
                      consultation.reason ??
                      'Consulta veterinaria'),
                ],
              ),
            ),
            Chip(label: Text(_statusLabel(consultation.status))),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'completed' => 'Fin',
        'in_progress' => 'En curso',
        'confirmed' => 'Confirmada',
        'cancelled' => 'Cancelada',
        _ => 'En espera',
      };
}

class _EmptyAgenda extends StatelessWidget {
  final VoidCallback openAgenda;
  const _EmptyAgenda({required this.openAgenda});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(Icons.event_available,
                  size: 42, color: AppColors.primary),
              const SizedBox(height: 10),
              const Text('No hay pacientes en espera.'),
              TextButton(
                  onPressed: openAgenda, child: const Text('Ver agenda')),
            ],
          ),
        ),
      );
}
