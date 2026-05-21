import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../configs/generic_response.dart';
import '../../models/epidemiological_alert.dart';
import '../../services/alert_service.dart';

class EpidemiologicalMapController extends GetxController {
  final AlertService _alertService = AlertService();
  late GoogleMapController mapController;

  final RxList<EpidemiologicalAlert> alerts = <EpidemiologicalAlert>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Set<Marker>> markers = Rx<Set<Marker>>(<Marker>{});
  final Rx<Set<Circle>> circles = Rx<Set<Circle>>(<Circle>{});

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    final GenericResponse<List<EpidemiologicalAlert>> res =
        await _alertService.fetchActiveAlerts();
    isLoading.value = false;
    if (res.success && res.data != null) {
      alerts.assignAll(res.data!);
      _updateMapOverlays();
    }
  }

  void _updateMapOverlays() {
    final newCircles = <Circle>{};
    final newMarkers = <Marker>{};

    for (int i = 0; i < alerts.length; i++) {
      final alert = alerts[i];
      final latitude = alert.latitude ?? -12.0464; // Default to Lima
      final longitude = alert.longitude ?? -77.0428;
      final position = LatLng(latitude, longitude);

      // Add circle for alert zone
      newCircles.add(
        Circle(
          circleId: CircleId('alert_$i'),
          center: position,
          radius: alert.radiusKm * 1000, // Convert km to meters
          fillColor: Colors.red.withValues(alpha: 0.15),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );

      // Add marker for alert center
      newMarkers.add(
        Marker(
          markerId: MarkerId('alert_marker_$i'),
          position: position,
          infoWindow: InfoWindow(title: alert.disease),
        ),
      );
    }

    circles.value = newCircles;
    markers.value = newMarkers;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> zoomIn() async {
    mapController.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOut() async {
    mapController.animateCamera(CameraUpdate.zoomOut());
  }
}
