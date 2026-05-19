import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final AuthService _authService = AuthService();

  final RxBool pushNotifs = true.obs;
  final RxBool geofenceAlerts = true.obs;
  final RxBool ledgerBroadcasts = false.obs;

  Future<void> signOut() async {
    await _authService.signOut();
    appCtrl.setUser(null);
    Get.offAllNamed(AppRoutes.signIn);
  }

  // Legacy alias
  Future<void> logout() => signOut();

  void pickPhoto() {}

  void toggleTheme() => appCtrl.toggleTheme();
  void toggleLocale() => appCtrl.toggleLocale();
}
