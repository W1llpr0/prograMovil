import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> loadRemotePreferences(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('user_preferences')
          .select('locale, dark_mode')
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return;
      locale.value = data['locale'] == 'en' ? 'en' : 'es';
      isDark.value = data['dark_mode'] == true;
      if (Get.context != null) {
        Get.updateLocale(selectedLocale);
        Get.changeThemeMode(selectedThemeMode);
      }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('locale', locale.value);
      await preferences.setBool('dark_mode', isDark.value);
    } catch (error) {
      debugPrint('Remote preferences load failed: ${error.runtimeType}');
    }
  }

  void setUser(AppUser? user) => currentUser.value = user;

  Future<void> setDarkMode(bool enabled) async {
    await _saveRemotePreferences(darkMode: enabled);
    isDark.value = enabled;
    if (Get.context != null) Get.changeThemeMode(selectedThemeMode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dark_mode', enabled);
  }

  Future<void> toggleTheme() => setDarkMode(!isDark.value);

  Future<void> setLocale(String language) async {
    final selected = language == 'en' ? 'en' : 'es';
    await _saveRemotePreferences(selectedLocale: selected);
    locale.value = selected;
    if (Get.context != null) Get.updateLocale(selectedLocale);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('locale', locale.value);
  }

  Future<void> toggleLocale() => setLocale(locale.value == 'en' ? 'es' : 'en');

  Future<void> _saveRemotePreferences({
    String? selectedLocale,
    bool? darkMode,
  }) async {
    final user = currentUser.value;
    if (user == null) return;
    try {
      await Supabase.instance.client.from('user_preferences').upsert({
        'user_id': user.id,
        'locale': selectedLocale ?? locale.value,
        'dark_mode': darkMode ?? isDark.value,
      }, onConflict: 'user_id');
    } catch (error) {
      debugPrint('Remote preferences save failed: ${error.runtimeType}');
      rethrow;
    }
  }
}
