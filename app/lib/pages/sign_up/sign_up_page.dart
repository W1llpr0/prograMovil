import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../configs/theme.dart';
import 'sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final SignUpController ctrl = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Crear cuenta'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selecciona tu tipo de perfil en VetCare:'),
                      const SizedBox(height: 14),
                      Obx(() => SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'client',
                                icon: Icon(Icons.person),
                                label: Text('Dueño'),
                              ),
                              ButtonSegment(
                                value: 'veterinarian',
                                icon: Icon(Icons.medical_services),
                                label: Text('Veterinario'),
                              ),
                            ],
                            selected: {ctrl.selectedRole.value},
                            onSelectionChanged: (value) =>
                                ctrl.selectedRole.value = value.first,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                        ? AppColors.primaryContainer
                                        : AppColors.surfaceContainer,
                              ),
                              foregroundColor: const WidgetStatePropertyAll(
                                AppColors.onSurface,
                              ),
                            ),
                          )),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: LineInput(
                              controller: ctrl.firstNameCtrl,
                              label: 'Nombres',
                              prefixIcon: Icons.badge,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LineInput(
                              controller: ctrl.lastNameCtrl,
                              label: 'Apellidos',
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      Obx(() => LineInput(
                            controller: ctrl.documentCtrl,
                            label: ctrl.selectedRole.value == 'veterinarian'
                                ? 'CMPV / colegiatura'
                                : 'Documento de identidad',
                            prefixIcon: Icons.assignment_ind,
                          )),
                      LineInput(
                        controller: ctrl.phoneCtrl,
                        label: 'Teléfono celular',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      Obx(() => ctrl.selectedRole.value == 'client'
                          ? LineInput(
                              controller: ctrl.addressCtrl,
                              label: 'Dirección (opcional)',
                              prefixIcon: Icons.location_on,
                              textCapitalization: TextCapitalization.words,
                            )
                          : const SizedBox.shrink()),
                      LineInput(
                        controller: ctrl.emailCtrl,
                        label: 'Correo electrónico',
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
                      LineInput(
                        controller: ctrl.confirmCtrl,
                        label: 'Confirmar contraseña',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        showPasswordToggle: true,
                      ),
                      Obx(() => ctrl.message.value.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              ctrl.message.value,
                              style: const TextStyle(color: AppColors.error),
                            )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 24),
                child: Obx(() => MonochromeButton(
                      label: 'Completar registro',
                      onPressed: ctrl.register,
                      isLoading: ctrl.isLoading.value,
                    )),
              ),
            ],
          ),
        ),
      );
}
