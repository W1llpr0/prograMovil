import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final AuthService _authService = AuthService();

  Future<void> logout() async {
    await _authService.signOut();
    appCtrl.setUser(null);
    Get.offAllNamed(AppRoutes.signIn);
  }

  void toggleTheme() => appCtrl.toggleTheme();

  void toggleLocale() => appCtrl.toggleLocale();
}
