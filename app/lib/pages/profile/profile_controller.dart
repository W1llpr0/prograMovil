import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final AuthService _authService = AuthService();

  final RxBool pushNotifs = true.obs;
  final RxBool geofenceAlerts = true.obs;
  final RxBool ledgerBroadcasts = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void _loadPreferences() {
    // Load preferences from user data if needed
  }

  Future<void> updateUserField(String fieldName, String newValue) async {
    try {
      isSaving.value = true;
      final uid = appCtrl.currentUser.value?.id;
      if (uid == null) throw Exception('User ID is null');

      // Map field names to database column names
      final fieldMap = {
        'firstName': 'first_name',
        'lastName': 'last_name',
        'phone': 'phone',
        'document': 'document',
        'address': 'address',
      };

      final dbField = fieldMap[fieldName] ?? fieldName;

      await Supabase.instance.client
          .from('users')
          .update({dbField: newValue}).eq('id', uid);

      // Update local state
      final currentUser = appCtrl.currentUser.value;
      if (currentUser != null) {
        AppUser updatedUser = currentUser;
        switch (fieldName) {
          case 'firstName':
            updatedUser = AppUser(
              id: currentUser.id,
              email: currentUser.email,
              firstName: newValue,
              lastName: currentUser.lastName,
              phone: currentUser.phone,
              document: currentUser.document,
              address: currentUser.address,
              profilePicture: currentUser.profilePicture,
              latitude: currentUser.latitude,
              longitude: currentUser.longitude,
              role: currentUser.role,
            );
            break;
          case 'lastName':
            updatedUser = AppUser(
              id: currentUser.id,
              email: currentUser.email,
              firstName: currentUser.firstName,
              lastName: newValue,
              phone: currentUser.phone,
              document: currentUser.document,
              address: currentUser.address,
              profilePicture: currentUser.profilePicture,
              latitude: currentUser.latitude,
              longitude: currentUser.longitude,
              role: currentUser.role,
            );
            break;
          case 'phone':
            updatedUser = AppUser(
              id: currentUser.id,
              email: currentUser.email,
              firstName: currentUser.firstName,
              lastName: currentUser.lastName,
              phone: newValue,
              document: currentUser.document,
              address: currentUser.address,
              profilePicture: currentUser.profilePicture,
              latitude: currentUser.latitude,
              longitude: currentUser.longitude,
              role: currentUser.role,
            );
            break;
          case 'document':
            updatedUser = AppUser(
              id: currentUser.id,
              email: currentUser.email,
              firstName: currentUser.firstName,
              lastName: currentUser.lastName,
              phone: currentUser.phone,
              document: newValue,
              address: currentUser.address,
              profilePicture: currentUser.profilePicture,
              latitude: currentUser.latitude,
              longitude: currentUser.longitude,
              role: currentUser.role,
            );
            break;
          case 'address':
            updatedUser = AppUser(
              id: currentUser.id,
              email: currentUser.email,
              firstName: currentUser.firstName,
              lastName: currentUser.lastName,
              phone: currentUser.phone,
              document: currentUser.document,
              address: newValue,
              profilePicture: currentUser.profilePicture,
              latitude: currentUser.latitude,
              longitude: currentUser.longitude,
              role: currentUser.role,
            );
            break;
        }
        appCtrl.setUser(updatedUser);
      }

      Get.snackbar('Success', '$fieldName updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update $fieldName: $e', snackPosition: SnackPosition.BOTTOM);
      debugPrint('❌ Update error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    appCtrl.setUser(null);
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<void> logout() => signOut();

  void pickPhoto() {}

  void toggleTheme() => appCtrl.toggleTheme();
  void toggleLocale() => appCtrl.toggleLocale();
}
