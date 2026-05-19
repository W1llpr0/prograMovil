import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';

/// Global controller: owns current user, theme mode, locale.
class AppController extends GetxController {
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isDark = false.obs;
  final RxString locale = 'en'.obs;

  bool get isLoggedIn => currentUser.value != null;
  bool get isVet => currentUser.value?.role == 'veterinarian';
  bool get isClient => currentUser.value?.role == 'client';

  void setUser(AppUser? user) => currentUser.value = user;

  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleLocale() {
    if (locale.value == 'en') {
      locale.value = 'es';
      Get.updateLocale(const Locale('es', 'ES'));
    } else {
      locale.value = 'en';
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
