import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'epidemiological_map_controller.dart';

class EpidemiologicalMapPage extends StatelessWidget {
  EpidemiologicalMapPage({super.key});

  final EpidemiologicalMapController ctrl = Get.put(EpidemiologicalMapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top nav ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(999)),
                      child: const Icon(Icons.chevron_left, size: 18, color: Colors.black),
                    ),
                  ),
                  Text('EPIDEMIOLOGICAL MAP', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: Colors.black)),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  // ── Header block ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GEOFENCE · LIMA METRO',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                                color: Colors.black.withValues(alpha: 0.55))),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: 'Disease\n',
                                style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                                    letterSpacing: -0.04 * 38, height: 0.92, color: Colors.black)),
                            TextSpan(text: 'alerts.',
                                style: GoogleFonts.instrumentSerif(fontSize: 36, fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400, letterSpacing: -0.02 * 36, height: 1.0, color: Colors.black)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Map placeholder ──────────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        // Map bg
                        Container(
                          margin: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _PulseRing(),
                                const SizedBox(height: 16),
                                Text('MAP VIEW', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                                    color: Colors.black.withValues(alpha: 0.4))),
                              ],
                            ),
                          ),
                        ),

                        // ── Alert sheet ───────────────────────
                        Positioned(
                          left: 22, right: 22, bottom: 22,
                          child: Obx(() {
                            if (ctrl.alerts.isEmpty) return const SizedBox.shrink();
                            final alert = ctrl.alerts.first;
                            return Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Icon(Icons.warning_amber_outlined, size: 20, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('GEOFENCE ALERT', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.18,
                                            color: Colors.white.withValues(alpha: 0.6))),
                                        const SizedBox(height: 4),
                                        Text(alert.disease,
                                            style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600,
                                                letterSpacing: -0.03 * 15, color: Colors.white)),
                                        const SizedBox(height: 2),
                                        Text('Limit walks · ${alert.radiusKm.toStringAsFixed(0)} km radius',
                                            style: GoogleFonts.spaceGrotesk(fontSize: 11,
                                                color: Colors.white.withValues(alpha: 0.7))),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated pulse ring ───────────────────────────────────────────
class _PulseRing extends StatefulWidget {
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale, _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _scale = Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
