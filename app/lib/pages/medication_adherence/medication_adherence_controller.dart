import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/generic_response.dart';
import '../../models/medication.dart';
import '../../models/pet.dart';
import '../../services/medication_service.dart';
import '../../services/pet_service.dart';

class MedicationAdherenceController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final MedicationService _medService = MedicationService();
  final PetService _petService = PetService();

  final RxList<Pet> pets = <Pet>[].obs;
  final Rx<Pet?> selectedPet = Rx<Pet?>(null);
  final RxList<MedicationSchedule> schedules = <MedicationSchedule>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<int> loggedToday = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) return;
    final res = await _petService.fetchPets(uid);
    if (res.success && res.data != null) {
      pets.assignAll(res.data!);
      if (pets.isNotEmpty) selectPet(pets.first);
    }
  }

  void selectPet(Pet pet) {
    selectedPet.value = pet;
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    if (selectedPet.value?.id == null) return;
    isLoading.value = true;
    final GenericResponse<List<MedicationSchedule>> res =
        await _medService.fetchSchedules(selectedPet.value!.id!);
    isLoading.value = false;
    if (res.success && res.data != null) {
      schedules.assignAll(res.data!);
    }
  }

  Future<void> markTaken(int scheduleId) async {
    if (loggedToday.contains(scheduleId)) return;
    final res = await _medService.markTaken(scheduleId: scheduleId);
    if (res.success) {
      loggedToday.add(scheduleId);
    }
  }
}
