import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import 'sign_in_controller.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final SignInController ctrl = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 72),
              // Logo mark
              _Logo(color: cs.onSurface),
              const SizedBox(height: 40),
              // Title
              Text(
                'VetCare',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.04,
                  color: cs.onSurface,
                ),
              ),
              Text(
                'sign_in'.tr,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 11,
                  letterSpacing: 0.32,
                  color: cs.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 48),
              // Form
              LineInput(
                controller: ctrl.emailCtrl,
                label: 'email'.tr,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              LineInput(
                controller: ctrl.passwordCtrl,
                label: 'password'.tr,
                hint: '••••••••',
                obscureText: true,
              ),
              // Error message
              Obx(() => ctrl.message.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        ctrl.message.value,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    )),
              const SizedBox(height: 8),
              Obx(() => MonochromeButton(
                    label: 'sign_in'.tr,
                    onPressed: ctrl.login,
                    isLoading: ctrl.isLoading.value,
                  )),
              const SizedBox(height: 32),
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'no_account'.tr,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: ctrl.goToSignUp,
                    child: Text(
                      'create_here'.tr,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        decoration: TextDecoration.underline,
                        decorationColor: cs.onSurface,
                      ),
                    ),
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

class _Logo extends StatelessWidget {
  final Color color;
  const _Logo({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(painter: _LogoMiniPainter(color)),
    );
  }
}

class _LogoMiniPainter extends CustomPainter {
  final Color color;
  _LogoMiniPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width / 2 - 1, paint);

    final cross = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(c.dx, c.dy - 10), Offset(c.dx, c.dy + 10), cross);
    canvas.drawLine(Offset(c.dx - 10, c.dy), Offset(c.dx + 10, c.dy), cross);
  }

  @override
  bool shouldRepaint(_LogoMiniPainter old) => old.color != color;
}
