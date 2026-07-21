import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../configs/theme.dart';
import 'sign_in_controller.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key, SignInController? controller})
      : ctrl = controller ?? Get.put(SignInController());

  final SignInController ctrl;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('VetCare',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Text('Tu veterinaria digital'),
                      const SizedBox(height: 46),
                      LineInput(
                        controller: ctrl.emailCtrl,
                        label: 'Correo electrónico',
                        hint: 'correo@ejemplo.com',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      LineInput(
                        controller: ctrl.passwordCtrl,
                        label: 'Contraseña',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        showPasswordToggle: true,
                      ),
                      Obx(() => ctrl.message.value.isEmpty
                          ? const SizedBox(height: 12)
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                ctrl.message.value,
                                style: const TextStyle(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      Obx(() => MonochromeButton(
                            label: 'Iniciar sesión',
                            icon: Icons.login,
                            onPressed: ctrl.login,
                            isLoading: ctrl.isLoading.value,
                          )),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('¿No tienes cuenta? '),
                          TextButton(
                            onPressed: ctrl.goToSignUp,
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
