import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class SignInController extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final RxString message = ''.obs;
  final RxBool isLoading = false.obs;

  final AuthService _authService;

  SignInController({AuthService? authService})
      : _authService = authService ?? AuthService();

  void login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      message.value = 'error_empty_fields'.tr;
      return;
    }
    isLoading.value = true;
    message.value = '';
    final GenericResponse<AppUser> res =
        await _authService.signIn(email: email, password: password);
    isLoading.value = false;

    if (res.success && res.data != null) {
      Get.find<AppController>().setUser(res.data!);
      Get.offAllNamed(
        res.data!.role == 'veterinarian'
            ? AppRoutes.vetDashboard
            : AppRoutes.homeClient,
      );
    } else {
      message.value = res.message;
    }
  }

  void goToSignUp() => Get.toNamed(AppRoutes.signUp);

  @override
  void onClose() {
    final controllers = [emailCtrl, passwordCtrl];
    Future.microtask(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    super.onClose();
  }
}
