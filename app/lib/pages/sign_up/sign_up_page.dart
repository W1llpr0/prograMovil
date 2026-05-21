import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top nav row
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: ctrl.goToSignIn,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.onSurface, width: 1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(Icons.chevron_left, size: 20, color: cs.onSurface),
                    ),
                  ),
                  Text(
                    '01 / 03',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10,
                      letterSpacing: 0.18,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REGISTRATION',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10,
                      letterSpacing: 0.18,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tell us\nwho you are.',
                    style: GoogleFonts.spaceGrotesk(fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.04 * 42,
                      height: 0.92,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Sliding segmented toggle
                  _RoleToggle(ctrl: ctrl, cs: cs),
                  const SizedBox(height: 36),
                  // Morphing form fields
                  Obx(() => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: ctrl.selectedRole.value == 'client'
                            ? _ClientFields(ctrl: ctrl, key: const ValueKey('client'))
                            : _VetFields(ctrl: ctrl, key: const ValueKey('vet')),
                      )),
                  // Email + password (common)
                  LineInput(
                    controller: ctrl.emailCtrl,
                    label: 'EMAIL',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  LineInput(
                    controller: ctrl.passwordCtrl,
                    label: 'PASSWORD',
                    obscureText: true,
                    showPasswordToggle: true,
                  ),
                  LineInput(
                    controller: ctrl.confirmCtrl,
                    label: 'CONFIRM PASSWORD',
                    obscureText: true,
                    showPasswordToggle: true,
                  ),
                  // Terms
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: cs.onSurface,
                            border: Border.all(color: cs.onSurface),
                          ),
                          child: Icon(Icons.check, size: 10, color: cs.surface),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I accept the Terms of Service and consent to anchoring my signed records to a decentralized ledger.',
                            style: GoogleFonts.spaceGrotesk(fontSize: 11,
                              height: 1.5,
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Error
                  Obx(() => ctrl.message.value.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(ctrl.message.value,
                              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.8))),
                        )),
                ],
              ),
            ),
          ),

          // CONTINUE → button fixed at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Obx(() => MonochromeButton(
                      label: 'CONTINUE →',
                      onPressed: ctrl.register,
                      isLoading: ctrl.isLoading.value,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliding segmented role toggle ──────────────────────────────────
class _RoleToggle extends StatelessWidget {
  final SignUpController ctrl;
  final ColorScheme cs;

  const _RoleToggle({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isClient = ctrl.selectedRole.value == 'client';
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface, width: 1),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            // Sliding thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: const Cubic(0.2, 0.8, 0.2, 1),
              alignment: isClient ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.onSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.selectedRole.value = 'client',
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 320),
                        curve: const Cubic(0.2, 0.8, 0.2, 1),
                        style: GoogleFonts.jetBrainsMono(fontSize: 11,
                          letterSpacing: 0.22,
                          color: isClient ? cs.surface : cs.onSurface,
                        ),
                        child: const Text('CLIENT'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.selectedRole.value = 'veterinarian',
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 320),
                        curve: const Cubic(0.2, 0.8, 0.2, 1),
                        style: GoogleFonts.jetBrainsMono(fontSize: 11,
                          letterSpacing: 0.22,
                          color: isClient ? cs.onSurface : cs.surface,
                        ),
                        child: const Text('VETERINARIAN'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _ClientFields extends StatelessWidget {
  final SignUpController ctrl;
  const _ClientFields({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LineInput(
          controller: ctrl.firstNameCtrl,
          label: 'FULL NAME',
          textCapitalization: TextCapitalization.words,
        ),
        LineInput(
          controller: ctrl.lastNameCtrl,
          label: 'LAST NAME',
          textCapitalization: TextCapitalization.words,
        ),
        LineInput(
          controller: ctrl.documentCtrl,
          label: 'IDENTITY DOCUMENT · DNI',
        ),
        LineInput(
          controller: ctrl.phoneCtrl,
          label: 'PHONE',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _VetFields extends StatelessWidget {
  final SignUpController ctrl;
  const _VetFields({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LineInput(
          controller: ctrl.firstNameCtrl,
          label: 'FULL NAME',
          textCapitalization: TextCapitalization.words,
        ),
        LineInput(
          controller: ctrl.lastNameCtrl,
          label: 'LICENSE NUMBER · CMP',
        ),
        LineInput(
          controller: ctrl.phoneCtrl,
          label: 'SPECIALTY',
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
