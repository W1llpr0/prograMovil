import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_controller.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../models/pet.dart';
import '../../models/specialty.dart';
import '../../models/veterinarian.dart';
import '../../services/consultation_service.dart';
import '../../services/pet_service.dart';

class BookAppointmentController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final ConsultationService consultationService;
  final PetService petService;

  BookAppointmentController({
    ConsultationService? consultationService,
    PetService? petService,
  })  : consultationService = consultationService ?? ConsultationService(),
        petService = petService ?? PetService();

  final reasonCtrl = TextEditingController();
  final RxList<Pet> clientPets = <Pet>[].obs;
  final RxList<Veterinarian> vets = <Veterinarian>[].obs;
  final RxList<Specialty> specialties = <Specialty>[].obs;
  final RxList<DateTime> availableSlots = <DateTime>[].obs;
  final Rx<Pet?> pet = Rx<Pet?>(null);
  final Rx<Specialty?> specialty = Rx<Specialty?>(null);
  final Rx<Veterinarian?> selectedVet = Rx<Veterinarian?>(null);
  final Rx<DateTime> selectedDate =
      DateTime.now().add(const Duration(days: 1)).obs;
  final Rx<DateTime?> selectedSlot = Rx<DateTime?>(null);
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSlots = false.obs;
  final RxString message = ''.obs;

  List<Veterinarian> get matchingVets {
    final id = specialty.value?.id;
    if (id == null) return vets;
    return vets.where((vet) => vet.specialtyIds.contains(id)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is Pet) pet.value = argument;
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    message.value = '';
    final results = await Future.wait([
      consultationService.fetchVeterinarians(),
      consultationService.fetchSpecialties(),
      _fetchPets(),
    ]);
    final vetsResult = results[0] as GenericResponse<List<Veterinarian>>;
    final specialtiesResult = results[1] as GenericResponse<List<Specialty>>;
    if (vetsResult.success) vets.assignAll(vetsResult.data ?? []);
    if (specialtiesResult.success) {
      specialties.assignAll(specialtiesResult.data ?? []);
      if (specialties.isNotEmpty) specialty.value = specialties.first;
    }
    isLoading.value = false;
  }

  Future<GenericResponse<List<Pet>>> _fetchPets() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) {
      return const GenericResponse(
        success: false,
        code: 'UNAUTHENTICATED',
        message: 'Debes iniciar sesión.',
      );
    }
    final result = await petService.fetchPets(uid);
    if (result.success) {
      clientPets.assignAll(result.data ?? []);
      // Keep a pet passed from its profile. From the generic booking entry,
      // require an explicit choice when the owner has more than one pet.
      if (pet.value == null && clientPets.length == 1) {
        pet.value = clientPets.first;
      }
    }
    return result;
  }

  void selectPet(Pet value) {
    pet.value = value;
    message.value = '';
  }

  void selectSpecialty(Specialty value) {
    specialty.value = value;
    selectedVet.value = null;
    selectedSlot.value = null;
    availableSlots.clear();
  }

  Future<void> selectVet(Veterinarian value) async {
    selectedVet.value = value;
    selectedSlot.value = null;
    await loadSlots();
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      selectedDate.value = picked;
      selectedSlot.value = null;
      await loadSlots();
    }
  }

  Future<void> loadSlots() async {
    final vet = selectedVet.value;
    if (vet == null) return;
    isLoadingSlots.value = true;
    final result = await consultationService.fetchAvailableSlots(
      veterinarianId: vet.id,
      date: selectedDate.value,
    );
    availableSlots.assignAll(result.data ?? []);
    if (!result.success) message.value = result.message;
    isLoadingSlots.value = false;
  }

  bool get canContinue => pet.value?.id != null && specialty.value != null;
  bool get canConfirm =>
      selectedVet.value != null && selectedSlot.value != null;

  void nextStep() {
    if (canContinue) {
      currentStep.value = 1;
      message.value = '';
    } else {
      message.value = 'Selecciona una mascota y una especialidad.';
    }
  }

  void prevStep() => currentStep.value = 0;

  Future<void> book() async {
    if (!canConfirm || pet.value?.id == null || specialty.value == null) {
      message.value = 'Selecciona veterinario, fecha y horario.';
      return;
    }
    isLoading.value = true;
    message.value = '';
    final result = await consultationService.bookAppointment(
      Consultation(
        petId: pet.value!.id!,
        veterinarianId: selectedVet.value!.id,
        specialtyId: specialty.value!.id,
        scheduledAt: selectedSlot.value!,
        reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
      ),
    );
    isLoading.value = false;
    if (result.success) {
      Get.back(result: true);
    } else {
      message.value = result.message;
      if (result.code == 'SLOT_TAKEN') await loadSlots();
    }
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
