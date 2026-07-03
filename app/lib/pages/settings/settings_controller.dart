import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/app_controller.dart';

class SettingsController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();

  void changeLanguage(String lang) {
    if (lang == 'es') {
      appCtrl.locale.value = 'es';
      Get.updateLocale(const Locale('es', 'ES'));
    } else {
      appCtrl.locale.value = 'en';
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
