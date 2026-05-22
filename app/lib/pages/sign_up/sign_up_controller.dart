import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../sign_in/sign_in_controller.dart';

class SignUpController extends GetxController {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final documentCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final RxString message = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'client'.obs;

  final AuthService _authService = AuthService();

  void register() async {
    final firstName = firstNameCtrl.text.trim();
    final lastName = lastNameCtrl.text.trim();
    final document = documentCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm = confirmCtrl.text;

    if (firstName.isEmpty || lastName.isEmpty || document.isEmpty || email.isEmpty || password.isEmpty) {
      message.value = 'error_empty_fields'.tr;
      return;
    }
    if (password != confirm) {
      message.value = 'error_passwords_mismatch'.tr;
      return;
    }

    isLoading.value = true;
    message.value = '';

    final GenericResponse<AppUser> res = await _authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      document: document,
      phone: phoneCtrl.text.trim(),
      role: selectedRole.value,
    );

    isLoading.value = false;

    if (res.success && res.data != null) {
      // Delete stale SignInController so the page gets a fresh instance
      Get.delete<SignInController>(force: true);
      Get.offAllNamed(AppRoutes.signIn);
    } else {
      message.value = res.message;
    }
  }

  void goToSignIn() => Get.toNamed(AppRoutes.signIn);

  @override
  void onClose() {
    // Defer disposal so in-flight page-exit animations finish before the
    // controllers are released (prevents "used after disposed" errors).
    final controllers = [
      firstNameCtrl, lastNameCtrl, documentCtrl,
      emailCtrl, phoneCtrl, passwordCtrl, confirmCtrl,
    ];
    Future.microtask(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    super.onClose();
  }
}
