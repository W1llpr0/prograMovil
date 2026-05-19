import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';

class VetDashboardController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final ConsultationService _consultationService = ConsultationService();

  final RxList<Consultation> agenda = <Consultation>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgenda();
  }

  Future<void> loadAgenda() async {
    // VetId == userId for simplicity (direct relation in schema)
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) return;
    isLoading.value = true;
    final GenericResponse<List<Consultation>> res = await _consultationService.fetchForVet(uid);
    isLoading.value = false;
    if (res.success && res.data != null) {
      agenda.assignAll(res.data!);
    }
  }

  void goToRegister(Consultation c) =>
      Get.toNamed(AppRoutes.registerMedical, arguments: c)?.then((_) => loadAgenda());

  void goToProfile() => Get.toNamed(AppRoutes.profile);
}
