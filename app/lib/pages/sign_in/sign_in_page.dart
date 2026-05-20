import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../components/vc_wordmark.dart';
import 'sign_in_controller.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final SignInController ctrl = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [VcWordmark(), SizedBox(width: 38)],
                    ),
                    const SizedBox(height: 64),
                    // Eyebrow
                    Text('SIGN IN · v 4.2',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                            color: cs.onSurface.withValues(alpha: 0.55))),
                    const SizedBox(height: 14),
                    // "Welcome back." display
                    Text('Welcome\nback.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 50, fontWeight: FontWeight.w700,
                          letterSpacing: -0.04 * 50, height: 0.92, color: cs.onSurface,
                        )),
                    const SizedBox(height: 12),
                    Text('Continue to your decentralized clinical history.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13, letterSpacing: -0.01, height: 1.5,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        )),
                    const SizedBox(height: 44),
                    LineInput(controller: ctrl.emailCtrl, label: 'EMAIL',
                        hint: 'you@vetcare.pe', keyboardType: TextInputType.emailAddress),
                    LineInput(controller: ctrl.passwordCtrl, label: 'PASSWORD',
                        hint: '••••••••', obscureText: true, showPasswordToggle: true),
                    // Remember + forgot row
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(color: cs.onSurface, border: Border.all(color: cs.onSurface)),
                              child: Icon(Icons.check, size: 10, color: cs.surface),
                            ),
                            const SizedBox(width: 10),
                            Text('REMEMBER DEVICE',
                                style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.14, color: cs.onSurface)),
                          ]),
                          Text('FORGOT?',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10, letterSpacing: 0.14, color: cs.onSurface,
                                decoration: TextDecoration.underline, decorationColor: cs.onSurface,
                              )),
                        ],
                      ),
                    ),
                    // Error
                    Obx(() => ctrl.message.value.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(ctrl.message.value,
                                style: GoogleFonts.spaceGrotesk(fontSize: 11,
                                    color: cs.onSurface.withValues(alpha: 0.8))))),
                    // SIGN IN → pill button
                    Obx(() => MonochromeButton(
                          label: 'SIGN IN →', onPressed: ctrl.login, isLoading: ctrl.isLoading.value)),
                    // OR divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(children: [
                        Expanded(child: Container(height: 1, color: cs.onSurface)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('OR', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.14, color: cs.onSurface)),
                        ),
                        Expanded(child: Container(height: 1, color: cs.onSurface)),
                      ]),
                    ),
                    // PASSKEY / FACE ID outlined pill
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          side: BorderSide(color: cs.onSurface, width: 1),
                          shape: const StadiumBorder(),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(width: 10),
                          Text('PASSKEY / FACE ID',
                              style: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 0.22, color: cs.onSurface)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom "New here?" footer
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.onSurface, width: 1))),
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 30),
            child: SafeArea(
              top: false,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('New here? ',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                GestureDetector(
                  onTap: ctrl.goToSignUp,
                  child: Text('Create an account',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        letterSpacing: -0.03 * 14,
                        decoration: TextDecoration.underline, decorationColor: cs.onSurface,
                        color: cs.onSurface,
                      )),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
