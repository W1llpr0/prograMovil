import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final RxBool doseDone = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSessionAndLoadPets();
  }

  Future<void> _checkSessionAndLoadPets() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        errorMessage.value = 'No active session. Please sign in again.';
        debugPrint('❌ HomeController: No active session!');
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.signIn);
        return;
      }
      debugPrint('✅ HomeController: Session active, uid=${session.user.id}');
      await loadPets();
    } catch (e) {
      errorMessage.value = 'Error loading data: $e';
      debugPrint('❌ HomeController: $e');
    }
  }

  Future<void> loadPets() async {
    final uid = appCtrl.currentUser.value?.id;
    debugPrint('🐾 Loading pets for uid: $uid');
    if (uid == null) {
      errorMessage.value = 'User ID is null';
      debugPrint('❌ HomeController: uid is null');
      return;
    }
    isLoading.value = true;
    try {
      final GenericResponse<List<Pet>> res = await _petService.fetchPets(uid);
      isLoading.value = false;
      if (res.success && res.data != null) {
        pets.assignAll(res.data!);
        debugPrint('✅ Loaded ${res.data!.length} pets');
      } else {
        errorMessage.value = res.message;
        debugPrint('❌ Failed to load pets: ${res.message}');
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error: $e';
      debugPrint('❌ Exception loading pets: $e');
    }
  }

  void goToAddPet() => Get.toNamed(AppRoutes.addPet)?.then((_) => loadPets());

  void goToPetProfile(Pet pet) => Get.toNamed(AppRoutes.petProfile, arguments: pet);

  void goToProfile() => Get.toNamed(AppRoutes.profile);

  void goToMedication() => Get.toNamed(AppRoutes.medicationAdherence);

  void goToAlerts() => Get.toNamed(AppRoutes.epidemiologicalMap);
}
