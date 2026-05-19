import 'package:get/get.dart';
import '../../configs/generic_response.dart';
import '../../models/epidemiological_alert.dart';
import '../../services/alert_service.dart';

class EpidemiologicalMapController extends GetxController {
  final AlertService _alertService = AlertService();

  final RxList<EpidemiologicalAlert> alerts = <EpidemiologicalAlert>[].obs;
  final RxBool isLoading = false.obs;

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
    }
  }
}
