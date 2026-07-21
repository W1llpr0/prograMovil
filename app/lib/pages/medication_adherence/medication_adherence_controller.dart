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
  final RxSet<int> marking = <int>{}.obs;
  final RxMap<int, String> scheduleMessages = <int, String>{}.obs;
  final RxString pageMessage = ''.obs;

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
    pageMessage.value = '';
    scheduleMessages.clear();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    final petId = selectedPet.value?.id;
    if (petId == null) return;
    isLoading.value = true;
    final GenericResponse<List<MedicationSchedule>> res =
        await _medService.fetchSchedules(petId);
    if (selectedPet.value?.id != petId) return;
    isLoading.value = false;
    if (res.success && res.data != null) {
      schedules.assignAll(res.data!);
    } else {
      schedules.clear();
      pageMessage.value = res.message;
    }
  }

  Future<void> markTaken(int scheduleId) async {
    if (marking.contains(scheduleId)) return;
    marking.add(scheduleId);
    scheduleMessages.remove(scheduleId);
    final res = await _medService.markTaken(scheduleId: scheduleId);
    if (res.success) {
      scheduleMessages[scheduleId] = 'Dosis registrada';
      await loadSchedules();
      Get.snackbar(
        'Medicamento',
        'Dosis registrada correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      scheduleMessages[scheduleId] = res.message;
      Get.snackbar(
        'No se registró la dosis',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    marking.remove(scheduleId);
  }
}
