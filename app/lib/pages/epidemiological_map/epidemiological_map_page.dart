import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'epidemiological_map_controller.dart';

class EpidemiologicalMapPage extends StatelessWidget {
  EpidemiologicalMapPage({super.key});

  final EpidemiologicalMapController ctrl = Get.put(EpidemiologicalMapController());

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
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
                      decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(999)),
                      child: Icon(Icons.chevron_left, size: 18, color: fg),
                    ),
                  ),
                  Text('MAPA EPIDEMIOLÓGICO', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
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
                                color: fg.withValues(alpha: 0.55))),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: 'Alertas\n',
                                style: GoogleFonts.spaceGrotesk(fontSize: 38, fontWeight: FontWeight.w700,
                                    letterSpacing: -0.04 * 38, height: 0.92, color: fg)),
                            TextSpan(text: 'de enfermedades.',
                                style: GoogleFonts.instrumentSerif(fontSize: 28, fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400, letterSpacing: -0.02 * 28, height: 1.0, color: fg)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Map container ──────────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        // Google Maps
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                            decoration: BoxDecoration(
                              border: Border.all(color: fg),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Obx(() => GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(-12.0464, -77.0428), // Lima, Peru
                                zoom: 12,
                              ),
                              onMapCreated: ctrl.onMapCreated,
                              markers: ctrl.markers.value,
                              circles: ctrl.circles.value,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              scrollGesturesEnabled: true,
                              rotateGesturesEnabled: false,
                            )),
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

                        // ── Zoom buttons ──────────────────────
                        Positioned(
                          right: 32, bottom: 100,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: ctrl.zoomIn,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: bg,
                                    border: Border.all(color: fg),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.add, color: fg, size: 20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: ctrl.zoomOut,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: bg,
                                    border: Border.all(color: fg),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.remove, color: fg, size: 20),
                                ),
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
