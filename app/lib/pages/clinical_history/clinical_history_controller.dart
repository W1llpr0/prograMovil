import 'package:get/get.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';

class ClinicalHistoryController extends GetxController {
  final ConsultationService _consultationService = ConsultationService();

  final Rx<Consultation?> consultation = Rx<Consultation?>(null);
  final RxBool integrityOk = false.obs;
  final RxBool integrityChecked = false.obs;

  @override
  void onInit() {
    super.onInit();
    consultation.value = Get.arguments as Consultation?;
    if (consultation.value != null) {
      _checkIntegrity();
    }
  }

  void _checkIntegrity() {
    final c = consultation.value!;
    if (c.integrityHash != null) {
      integrityOk.value = _consultationService.verifyIntegrity(c);
      integrityChecked.value = true;
    }
  }
}
