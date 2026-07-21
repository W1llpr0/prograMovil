import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

/// Global controller: owns current user, theme mode, locale.
class AppController extends GetxController {
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isDark = false.obs;
  final RxString locale = 'es'.obs;

  bool get isLoggedIn => currentUser.value != null;
  bool get isVet => currentUser.value?.role == 'veterinarian';
  bool get isClient => currentUser.value?.role == 'client';

  Locale get selectedLocale => locale.value == 'en'
      ? const Locale('en', 'US')
      : const Locale('es', 'ES');

  ThemeMode get selectedThemeMode =>
      isDark.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    locale.value = preferences.getString('locale') == 'en' ? 'en' : 'es';
    isDark.value = preferences.getBool('dark_mode') ?? false;
  }

  void setUser(AppUser? user) => currentUser.value = user;

  Future<void> setDarkMode(bool enabled) async {
    isDark.value = enabled;
    if (Get.context != null) Get.changeThemeMode(selectedThemeMode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dark_mode', enabled);
  }

  Future<void> toggleTheme() => setDarkMode(!isDark.value);

  Future<void> setLocale(String language) async {
    locale.value = language == 'en' ? 'en' : 'es';
    if (Get.context != null) Get.updateLocale(selectedLocale);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('locale', locale.value);
  }

  Future<void> toggleLocale() => setLocale(locale.value == 'en' ? 'es' : 'en');
}
