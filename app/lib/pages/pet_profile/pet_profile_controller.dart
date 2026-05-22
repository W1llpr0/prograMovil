import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../models/exotic_models.dart';
import '../../models/pet.dart';
import '../../pages/home/home_controller.dart';
import '../../services/alert_service.dart';
import '../../services/consultation_service.dart';
import '../../services/pet_service.dart';

class PetProfileController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final ConsultationService _consultationService = ConsultationService();
  final AlertService _alertService = AlertService();
  final PetService _petService = PetService();

  final Rx<Pet?> pet = Rx<Pet?>(null);
  final RxList<Consultation> consultations = <Consultation>[].obs;
  final RxList<MorphologicalRecord> morphological = <MorphologicalRecord>[].obs;
  final RxList<LegalDocument> legalDocs = <LegalDocument>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    pet.value = Get.arguments as Pet?;
    if (pet.value != null) {
      loadConsultations();
      if (pet.value!.isExotic) {
        loadExoticData();
      }
    }
  }

  Future<void> loadConsultations() async {
    if (pet.value?.id == null) return;
    isLoading.value = true;
    final GenericResponse<List<Consultation>> res =
        await _consultationService.fetchForPet(pet.value!.id!);
    isLoading.value = false;
    if (res.success && res.data != null) {
      consultations.assignAll(res.data!);
    }
  }

  Future<void> loadExoticData() async {
    if (pet.value?.id == null) return;
    final mr = await _alertService.fetchMorphological(pet.value!.id!);
    if (mr.success && mr.data != null) morphological.assignAll(mr.data!);
    final ld = await _alertService.fetchLegalDocs(pet.value!.id!);
    if (ld.success && ld.data != null) legalDocs.assignAll(ld.data!);
  }

  void goToBookAppointment() =>
      Get.toNamed(AppRoutes.bookAppointment, arguments: pet.value)?.then((_) => loadConsultations());

  void goToHistory(Consultation c) =>
      Get.toNamed(AppRoutes.clinicalHistory, arguments: c);

  Future<void> deletePet() async {
    if (pet.value?.id == null) return;
    final GenericResponse<void> res = await _petService.deletePet(pet.value!.id!);
    if (res.success) {
      try {
        Get.find<HomeController>().loadPets();
      } catch (_) {}
      Get.back();
      Get.snackbar('pet_deleted'.tr, '', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updatePetPhoto() async {
    if (pet.value?.id == null) return;
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (xFile == null) return;
      isLoading.value = true;
      final res = await _petService.updatePet(pet.value!.id!, {}, photo: File(xFile.path));
      isLoading.value = false;
      if (res.success && res.data != null) {
        pet.value = res.data;
        try {
          Get.find<HomeController>().loadPets();
        } catch (_) {}
      } else {
        Get.snackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
