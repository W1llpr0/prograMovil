import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/pet.dart';
import '../../services/pet_service.dart';

class HomeController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final PetService _petService = PetService();

  final RxList<Pet> pets = <Pet>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPets();
  }

  Future<void> loadPets() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) return;
    isLoading.value = true;
    final GenericResponse<List<Pet>> res = await _petService.fetchPets(uid);
    isLoading.value = false;
    if (res.success && res.data != null) {
      pets.assignAll(res.data!);
    }
  }

  void goToAddPet() => Get.toNamed(AppRoutes.addPet)?.then((_) => loadPets());

  void goToPetProfile(Pet pet) => Get.toNamed(AppRoutes.petProfile, arguments: pet);

  void goToProfile() => Get.toNamed(AppRoutes.profile);

  void goToMedication() => Get.toNamed(AppRoutes.medicationAdherence);

  void goToAlerts() => Get.toNamed(AppRoutes.epidemiologicalMap);
}
