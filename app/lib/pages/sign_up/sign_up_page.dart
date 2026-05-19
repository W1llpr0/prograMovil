import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import 'sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final SignUpController ctrl = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'sign_up'.tr,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.04,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              // Role selector
              _RoleSelector(ctrl: ctrl),
              const SizedBox(height: 24),
              LineInput(controller: ctrl.firstNameCtrl, label: 'first_name'.tr, textCapitalization: TextCapitalization.words),
              LineInput(controller: ctrl.lastNameCtrl, label: 'last_name'.tr, textCapitalization: TextCapitalization.words),
              LineInput(controller: ctrl.emailCtrl, label: 'email'.tr, keyboardType: TextInputType.emailAddress),
              LineInput(controller: ctrl.phoneCtrl, label: 'phone'.tr, keyboardType: TextInputType.phone),
              LineInput(controller: ctrl.passwordCtrl, label: 'password'.tr, obscureText: true),
              LineInput(controller: ctrl.confirmCtrl, label: 'confirm_password'.tr, obscureText: true),
              Obx(() => ctrl.message.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(ctrl.message.value,
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.8))),
                    )),
              const SizedBox(height: 8),
              Obx(() => MonochromeButton(
                    label: 'sign_up'.tr,
                    onPressed: ctrl.register,
                    isLoading: ctrl.isLoading.value,
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('already_account'.tr,
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: ctrl.goToSignIn,
                    child: Text('login_here'.tr,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            decoration: TextDecoration.underline,
                            decorationColor: cs.onSurface)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final SignUpController ctrl;
  const _RoleSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() => Row(
          children: [
            _Chip(
              label: 'Client',
              selected: ctrl.selectedRole.value == 'client',
              onTap: () => ctrl.selectedRole.value = 'client',
              cs: cs,
            ),
            const SizedBox(width: 12),
            _Chip(
              label: 'Veterinarian',
              selected: ctrl.selectedRole.value == 'veterinarian',
              onTap: () => ctrl.selectedRole.value = 'veterinarian',
              cs: cs,
            ),
          ],
        ));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _Chip({required this.label, required this.selected, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.onSurface : Colors.transparent,
          border: Border.all(color: cs.onSurface, width: 1),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.22,
            color: selected ? cs.surface : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
