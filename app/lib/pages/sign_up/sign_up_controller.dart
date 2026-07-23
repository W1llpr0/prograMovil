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
  final addressCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final RxString message = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'client'.obs;

  final AuthService _authService;

  SignUpController({AuthService? authService})
      : _authService = authService ?? AuthService();

  void register() async {
    final firstName = firstNameCtrl.text.trim();
    final lastName = lastNameCtrl.text.trim();
    final document = documentCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm = confirmCtrl.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        document.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      message.value = 'error_empty_fields'.tr;
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      message.value = 'error_invalid_email'.tr;
      return;
    }
    if (password.length < 6) {
      message.value = 'error_password_too_short'.tr;
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
      address: addressCtrl.text.trim(),
      role: selectedRole.value,
    );

    isLoading.value = false;

    if (res.success && res.data != null) {
      if (res.code == 'EMAIL_CONFIRMATION_REQUIRED') {
        Get.offAllNamed(AppRoutes.verifyEmail, arguments: email);
      } else if (Get.isRegistered<SignInController>()) {
        // Registration is normally opened over the login route. Return to the
        // existing page so its fields are not destroyed mid-transition.
        final signIn = Get.find<SignInController>();
        signIn.emailCtrl.text = email;
        signIn.passwordCtrl.clear();
        signIn.message.value = '';
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.signIn);
      }
    } else {
      message.value = res.message;
    }
  }

  void goToSignIn() => Get.toNamed(AppRoutes.signIn);
}
