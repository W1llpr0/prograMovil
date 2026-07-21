import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../configs/app_routes.dart';
import '../../configs/theme.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController ctrl = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(
              ctrl.appCtrl.currentUser.value?.role == 'veterinarian'
                  ? 'Mi perfil médico'
                  : 'Mi cuenta')),
        ),
        body: Obx(() {
          final user = ctrl.appCtrl.currentUser.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final isVet = user.role == 'veterinarian';
          return ListView(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 36),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: isVet
                          ? AppColors.primary
                          : AppColors.primaryContainer,
                      foregroundColor: isVet ? Colors.white : AppColors.primary,
                      backgroundImage: user.profilePicture == null
                          ? null
                          : NetworkImage(user.profilePicture!),
                      child: user.profilePicture == null
                          ? Text(_initials(user.fullName),
                              style: const TextStyle(fontSize: 34))
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton.filledTonal(
                        onPressed: ctrl.pickPhoto,
                        icon: const Icon(Icons.camera_alt, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isVet ? 'Dr. ${user.fullName}' : user.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(user.email, textAlign: TextAlign.center),
              if (isVet) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Chip(
                    avatar: Icon(Icons.verified, size: 18),
                    label: Text('Colegiado activo'),
                    backgroundColor: AppColors.primaryContainer,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              if (isVet) ...[
                _EditableRow(
                  icon: Icons.badge,
                  label: 'CMPV (colegiatura)',
                  value: user.licenseNumber ?? user.document ?? 'Sin registrar',
                  onEdit: ctrl.updateLicenseNumber,
                ),
                _EditableRow(
                  icon: Icons.history,
                  label: 'Años de experiencia',
                  value: '${user.yearsExperience ?? 0}',
                  numeric: true,
                  onEdit: (value) =>
                      ctrl.updateYearsExperience(int.tryParse(value) ?? 0),
                ),
                const SizedBox(height: 20),
                Text('Especialidades',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...ctrl.specialties
                        .map((item) => Chip(label: Text(item.name))),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Añadir'),
                      onPressed: () => _selectSpecialty(context),
                    ),
                  ],
                ),
              ] else ...[
                _MenuTile(
                  icon: Icons.person,
                  label: 'Datos personales',
                  onTap: () => _showPersonalData(context),
                ),
                _MenuTile(
                  icon: Icons.star,
                  label: 'Mis reseñas',
                  onTap: () => _showReviews(context),
                ),
                _MenuTile(
                  icon: Icons.settings,
                  label: 'Configuración',
                  onTap: () => Get.toNamed(AppRoutes.settings),
                ),
              ],
              const SizedBox(height: 30),
              TextButton.icon(
                onPressed: ctrl.signOut,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Cerrar sesión',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          );
        }),
      );

  void _showPersonalData(BuildContext context) {
    final user = ctrl.appCtrl.currentUser.value!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 8, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Datos personales',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableRow(
              icon: Icons.phone,
              label: 'Teléfono',
              value: user.phone ?? 'Sin registrar',
              onEdit: (value) => ctrl.updateUserField('phone', value),
            ),
            _EditableRow(
              icon: Icons.assignment_ind,
              label: 'Documento',
              value: user.document ?? 'Sin registrar',
              onEdit: (value) => ctrl.updateUserField('document', value),
            ),
            _EditableRow(
              icon: Icons.location_on,
              label: 'Dirección',
              value: user.address ?? 'Sin registrar',
              onEdit: (value) => ctrl.updateUserField('address', value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReviews(BuildContext context) async {
    final result = await ReviewService().fetchMine();
    if (!context.mounted) return;
    final reviews = result.data ?? const <Review>[];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis reseñas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Todavía no enviaste reseñas.'),
              )
            else
              ...reviews.map((review) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${review.rating}★'),
                      ),
                      title: Text(
                        review.petName == null
                            ? 'Consulta #${review.consultationId}'
                            : '${review.petName} · ${review.specialtyName ?? 'Consulta'}',
                      ),
                      subtitle: Text([
                        if (review.consultationDate != null)
                          DateFormat('dd MMM yyyy', 'es_ES')
                              .format(review.consultationDate!),
                        if (review.diagnosis?.isNotEmpty == true)
                          'Diagnóstico: ${review.diagnosis}',
                        review.comment ?? 'Sin comentario',
                      ].join('\n')),
                      isThreeLine: true,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _selectSpecialty(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('Añadir especialidad',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...ctrl.allSpecialties.map((item) => ListTile(
                title: Text(item.name),
                trailing:
                    ctrl.specialties.any((current) => current.id == item.id)
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : const Icon(Icons.add),
                onTap: () async {
                  await ctrl.addSpecialty(item);
                  if (context.mounted) Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
          child: Row(
            children: [
              Icon(icon, color: AppColors.outline),
              const SizedBox(width: 14),
              Expanded(child: Text(label)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
}

class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool numeric;
  final ValueChanged<String> onEdit;
  const _EditableRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          tileColor: AppColors.surfaceContainer,
          leading: Icon(icon),
          title: Text(label, style: const TextStyle(color: AppColors.primary)),
          subtitle: Text(value),
          trailing: const Icon(Icons.edit, size: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () async {
            final controller = TextEditingController(
                text: value == 'Sin registrar' ? '' : value);
            final result = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Editar $label'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      numeric ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(labelText: label),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Guardar')),
                ],
              ),
            );
            controller.dispose();
            if (result?.trim().isNotEmpty == true) onEdit(result!);
          },
        ),
      );
}
