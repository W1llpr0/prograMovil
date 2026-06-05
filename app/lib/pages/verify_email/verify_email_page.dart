import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/monochrome_button.dart';
import '../../configs/app_routes.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String email = Get.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.onSurface, width: 1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(Icons.mail_outline_rounded, size: 24, color: cs.onSurface),
              ),

              const SizedBox(height: 28),

              // Eyebrow
              Text(
                'ALMOST THERE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  letterSpacing: 0.18,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 10),

              // Headline
              Text(
                'Check your\nemail.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.04 * 42,
                  height: 0.92,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 28),

              // Description
              Text(
                'We sent a confirmation link to:',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              if (email.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.onSurface, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    email,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Click the link in that email to activate your account, then sign in.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  height: 1.6,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),

              const Spacer(),

              // Go to sign in
              MonochromeButton(
                label: 'GO TO SIGN IN →',
                onPressed: () => Get.offAllNamed(AppRoutes.signIn),
              ),

              const SizedBox(height: 14),

              // Back to registration
              Center(
                child: GestureDetector(
                  onTap: () => Get.offAllNamed(AppRoutes.signUp),
                  child: Text(
                    'Use a different email',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.55),
                      decoration: TextDecoration.underline,
                      decorationColor: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
