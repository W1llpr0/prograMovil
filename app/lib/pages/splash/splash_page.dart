import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;
  late Animation<double> _cross;
  late Animation<double> _titleFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 2200), vsync: this);
    _ring = Tween<double>(begin: 327, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)));
    _cross = Tween<double>(begin: 60, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.65, curve: Curves.easeInOut)));
    _titleFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));

    _ctrl.forward().then((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    final appCtrl = Get.find<AppController>();
    final user = await AuthService().currentUser();
    appCtrl.setUser(user);

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && user != null) {
      Get.offAllNamed(user.role == 'veterinarian' ? AppRoutes.vetDashboard : AppRoutes.homeClient);
    } else {
      Get.offAllNamed(AppRoutes.signIn);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(painter: _LogoPainter(_ring.value, _cross.value)),
              ),
              const SizedBox(height: 28),
              Opacity(
                opacity: _titleFade.value,
                child: Text(
                  'VetCare',
                  style: GoogleFonts.spaceGrotesk(fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: _titleFade.value * 0.55,
                child: Text(
                  'SIGNED · DECENTRALIZED · v 4.2',
                  style: GoogleFonts.jetBrainsMono(fontSize: 9,
                    letterSpacing: 0.32,
                    color: Colors.white,
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

class _LogoPainter extends CustomPainter {
  final double ringOffset;
  final double crossOffset;

  _LogoPainter(this.ringOffset, this.crossOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 52.0;

    // Outer ring
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final ringMetrics = circlePath.computeMetrics().first;
    final drawn = ringMetrics.extractPath(0, ringMetrics.length - ringOffset);
    canvas.drawPath(drawn, paint);

    // Cross
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final vPath = Path()
      ..moveTo(center.dx, center.dy - 30)
      ..lineTo(center.dx, center.dy + 30);
    final vMet = vPath.computeMetrics().first;
    canvas.drawPath(vMet.extractPath(0, vMet.length - crossOffset), crossPaint);

    final hPath = Path()
      ..moveTo(center.dx - 30, center.dy)
      ..lineTo(center.dx + 30, center.dy);
    final hMet = hPath.computeMetrics().first;
    canvas.drawPath(hMet.extractPath(0, hMet.length - crossOffset), crossPaint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.ringOffset != ringOffset || old.crossOffset != crossOffset;
}
