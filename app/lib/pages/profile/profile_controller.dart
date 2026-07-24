import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../models/specialty.dart';
import '../../services/auth_service.dart';
import '../sign_in/sign_in_controller.dart';

class ProfileController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final AuthService _authService = AuthService();
  final SupabaseClient _sb = Supabase.instance.client;

  final isSaving = false.obs;
  final specialties = <Specialty>[].obs;
  final allSpecialties = <Specialty>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (appCtrl.currentUser.value?.role == 'veterinarian') {
      loadSpecialties();
    }
  }

  Future<void> updateUserField(String fieldName, String newValue) async {
    final user = appCtrl.currentUser.value;
    if (user == null || newValue.trim().isEmpty) return;
    final dbField = {
      'firstName': 'first_name',
      'lastName': 'last_name',
      'phone': 'phone',
      'document': 'document',
      'address': 'address',
    }[fieldName];
    if (dbField == null) return;
    try {
      isSaving.value = true;
      await _sb
          .from('users')
          .update({dbField: newValue.trim()}).eq('id', user.id);
      final updated = switch (fieldName) {
        'firstName' => user.copyWith(firstName: newValue.trim()),
        'lastName' => user.copyWith(lastName: newValue.trim()),
        'phone' => user.copyWith(phone: newValue.trim()),
        'document' => user.copyWith(document: newValue.trim()),
        'address' => user.copyWith(address: newValue.trim()),
        _ => user,
      };
      appCtrl.setUser(updated);
      Get.snackbar('Perfil', 'Datos actualizados.');
    } catch (error) {
      Get.snackbar('Error', 'No se pudo actualizar el perfil.');
      debugPrint('Profile update error: $error');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateYearsExperience(int years) async {
    final user = appCtrl.currentUser.value;
    if (user == null || user.role != 'veterinarian' || years < 0) return;
    try {
      await _sb
          .from('veterinarians')
          .update({'years_experience': years}).eq('user_id', user.id);
      appCtrl.setUser(user.copyWith(yearsExperience: years));
    } catch (error) {
      Get.snackbar('Error', 'No se pudo actualizar la experiencia.');
    }
  }

  Future<void> updateLicenseNumber(String licenseNumber) async {
    final user = appCtrl.currentUser.value;
    final value = licenseNumber.trim();
    if (user == null || user.role != 'veterinarian' || value.isEmpty) return;
    try {
      await _sb
          .from('veterinarians')
          .update({'license_number': value}).eq('user_id', user.id);
      appCtrl.setUser(user.copyWith(licenseNumber: value));
      Get.snackbar('Perfil', 'Colegiatura actualizada.');
    } catch (error) {
      Get.snackbar('Error', 'No se pudo actualizar la colegiatura.');
    }
  }

  Future<void> loadSpecialties() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) return;
    try {
      final catalog = await _sb.from('specialties').select().order('name');
      allSpecialties.assignAll((catalog as List).map(
          (row) => Specialty.fromJson(Map<String, dynamic>.from(row as Map))));
      final vet = await _sb
          .from('veterinarians')
          .select('id, veterinarian_specialties(specialties(id,name,icon))')
          .eq('user_id', uid)
          .single();
      final links = vet['veterinarian_specialties'] as List? ?? const [];
      specialties.assignAll(links
          .map((link) => (link as Map)['specialties'])
          .whereType<Map>()
          .map((row) => Specialty.fromJson(Map<String, dynamic>.from(row))));
    } catch (error) {
      debugPrint('Specialties error: $error');
    }
  }

  Future<void> addSpecialty(Specialty specialty) async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null || specialties.any((item) => item.id == specialty.id)) {
      return;
    }
    try {
      final vet = await _sb
          .from('veterinarians')
          .select('id')
          .eq('user_id', uid)
          .single();
      await _sb.from('veterinarian_specialties').insert({
        'veterinarian_id': vet['id'],
        'specialty_id': specialty.id,
      });
      specialties.add(specialty);
    } catch (error) {
      Get.snackbar('Error', 'No se pudo añadir la especialidad.');
    }
  }

  Future<void> pickPhoto() async {
    final user = appCtrl.currentUser.value;
    if (user == null) return;
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image == null) return;
      isSaving.value = true;
      final bytes = await image.readAsBytes();
      final path = 'profile-pictures/${user.id}/profile.jpg';
      await _sb.storage.from('profiles').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final url = _sb.storage.from('profiles').getPublicUrl(path);
      await _sb
          .from('users')
          .update({'profile_picture': url}).eq('id', user.id);
      appCtrl.setUser(user.copyWith(profilePicture: url));
    } catch (error) {
      Get.snackbar('Error', 'No se pudo actualizar la foto.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    appCtrl.setUser(null);
    Get.delete<SignInController>(force: true);
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<void> logout() => signOut();
  void toggleTheme() => appCtrl.toggleTheme();
  void toggleLocale() => appCtrl.toggleLocale();
}
