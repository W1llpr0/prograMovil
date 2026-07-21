import 'package:get/get.dart';
import '../../components/app_controller.dart';

class SettingsController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();

  Future<void> changeLanguage(String lang) => appCtrl.setLocale(lang);

  Future<void> toggleTheme() => appCtrl.toggleTheme();
}
