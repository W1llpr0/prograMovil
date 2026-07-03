import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/app_controller.dart';
import '../../configs/generic_response.dart';
import '../../models/pet.dart';
import '../../models/species.dart';
import '../../services/breed_api_service.dart';
import '../../services/pet_service.dart';

class AddPetController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final PetService _petService = PetService();
  final BreedApiService _breedApiService = BreedApiService();

  final nameCtrl = TextEditingController();
  final breedCtrl = TextEditingController();
  final birthDateCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final microchipCtrl = TextEditingController();
  final Rx<File?> imageFile = Rx<File?>(null);

  final RxList<Species> speciesList = <Species>[].obs;
  final Rx<Species?> selectedSpecies = Rx<Species?>(null);
  final RxList<Breed> breedsList = <Breed>[].obs;
  final Rx<Breed?> selectedBreed = Rx<Breed?>(null);
  final RxString selectedSex = ''.obs;
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final Rx<File?> photoFile = Rx<File?>(null);
  final RxBool showCustomBreed = false.obs;
  final customBreedCtrl = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSpecies();
    // Load breeds when species is selected
    ever(selectedSpecies, (_) {
      if (selectedSpecies.value != null) {
        _loadBreeds(selectedSpecies.value!.id);
      } else {
        breedsList.clear();
        selectedBreed.value = null;
      }
    });
  }

  Future<void> _loadSpecies() async {
    final res = await _petService.fetchSpecies();
    if (res.success && res.data != null) {
      speciesList.assignAll(res.data!);
    } else {
      message.value = res.message;
      print('loadSpecies error: ${res.error}');
    }
  }

  Future<void> _loadBreeds(int speciesId) async {
    breedsList.clear();
    selectedBreed.value = null;
    showCustomBreed.value = false;

    final speciesName = selectedSpecies.value?.name ?? '';
    GenericResponse<List<Breed>> res;

    if (speciesName == 'Perro' || speciesName.toLowerCase() == 'dog') {
      res = await _breedApiService.fetchDogBreeds(speciesId);
      // Fall back to DB if API fails
      if (!res.success || (res.data?.isEmpty ?? true)) {
        res = await _petService.fetchBreedsBySpecies(speciesId);
      }
    } else if (speciesName == 'Gato' || speciesName.toLowerCase() == 'cat') {
      res = await _breedApiService.fetchCatBreeds(speciesId);
      if (!res.success || (res.data?.isEmpty ?? true)) {
        res = await _petService.fetchBreedsBySpecies(speciesId);
      }
    } else {
      res = await _petService.fetchBreedsBySpecies(speciesId);
    }

    if (res.success && res.data != null) {
      breedsList.assignAll(res.data!);
    } else {
      message.value = 'Error cargando razas: ${res.message}';
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile != null) imageFile.value = File(xFile.path);
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate.value ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx),
        child: child!,
      ),
    );
    if (picked != null) birthDate.value = picked;
  }

  Future<void> savePet() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) {
      message.value = 'Debes iniciar sesión.';
      return;
    }
    if (nameCtrl.text.trim().isEmpty || selectedSpecies.value == null) {
      message.value = 'error_empty_fields'.tr;
      return;
    }

    isLoading.value = true;
    message.value = '';

    // Handle custom breed: create it in DB if typed
    int? breedId = selectedBreed.value?.id;
    // If breed has a negative ID it came from the external API → upsert it in DB
    if (breedId != null && breedId < 0) {
      final breedRes = await _petService.createBreed(
        selectedBreed.value!.name,
        selectedSpecies.value!.id,
      );
      breedId = breedRes.success ? breedRes.data?.id : null;
    } else if (showCustomBreed.value && customBreedCtrl.text.trim().isNotEmpty) {
      final breedRes = await _petService.createBreed(
        customBreedCtrl.text.trim(),
        selectedSpecies.value!.id,
      );
      if (breedRes.success && breedRes.data != null) {
        breedId = breedRes.data!.id;
      }
    }

    final pet = Pet(
      clientId: uid,
      name: nameCtrl.text.trim(),
      speciesId: selectedSpecies.value!.id,
      breedId: breedId,
      sexId: selectedSex.value == 'Male'
          ? 1
          : selectedSex.value == 'Female'
              ? 2
              : null,
      birthDate: birthDate.value,
      weightKg: double.tryParse(weightCtrl.text),
      microchip: microchipCtrl.text.trim().isEmpty ? null : microchipCtrl.text.trim(),
    );

    final GenericResponse<Pet> res = await _petService.addPet(pet, photo: imageFile.value);
    isLoading.value = false;

    if (res.success) {
      Get.back(result: true);
    } else {
      message.value = res.message.isNotEmpty ? res.message : 'Error al registrar mascota.';
      print('addPet error: ${res.error}');
    }
  }

  Future<void> submit() => savePet();

  @override
  void onClose() {
    nameCtrl.dispose();
    breedCtrl.dispose();
    birthDateCtrl.dispose();
    weightCtrl.dispose();
    microchipCtrl.dispose();
    super.onClose();
  }
}
