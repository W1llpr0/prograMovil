import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/app_controller.dart';
import '../../configs/generic_response.dart';
import '../../models/pet.dart';
import '../../models/species.dart';
import '../../services/pet_service.dart';

class AddPetController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final PetService _petService = PetService();

  final nameCtrl = TextEditingController();
  final breedCtrl = TextEditingController();
  final birthDateCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final microchipCtrl = TextEditingController();
  final Rx<File?> imageFile = Rx<File?>(null);

  final RxList<Species> speciesList = <Species>[].obs;
  final Rx<Species?> selectedSpecies = Rx<Species?>(null);
  final RxString selectedSex = ''.obs;
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final RxBool isExotic = false.obs;
  final Rx<File?> photoFile = Rx<File?>(null);

  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    final res = await _petService.fetchSpecies();
    if (res.success && res.data != null) {
      speciesList.assignAll(res.data!);
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile != null) photoFile.value = File(xFile.path);
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
    if (uid == null) return;
    if (nameCtrl.text.trim().isEmpty || selectedSpecies.value == null) {
      message.value = 'error_empty_fields'.tr;
      return;
    }

    isLoading.value = true;
    message.value = '';

    final pet = Pet(
      clientId: uid,
      name: nameCtrl.text.trim(),
      speciesId: selectedSpecies.value!.id,
      sexCode: selectedSex.value.isEmpty ? null : selectedSex.value,
      birthDate: birthDate.value,
      weightKg: double.tryParse(weightCtrl.text),
      microchip: microchipCtrl.text.trim().isEmpty ? null : microchipCtrl.text.trim(),
      isExotic: isExotic.value || (selectedSpecies.value?.isExotic ?? false),
    );

    final GenericResponse<Pet> res = await _petService.addPet(pet, photo: photoFile.value);
    isLoading.value = false;

    if (res.success) {
      Get.back(result: true);
    } else {
      message.value = res.message;
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
