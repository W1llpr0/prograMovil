import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/app_controller.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../models/pet.dart';
import '../../models/veterinarian.dart';
import '../../services/consultation_service.dart';
import '../../services/pet_service.dart';

class BookAppointmentController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final ConsultationService _consultationService = ConsultationService();
  final PetService _petService = PetService();

  final reasonCtrl = TextEditingController();
  final timeCtrl = TextEditingController();

  final RxList<Pet> clientPets = <Pet>[].obs;
  final RxList<Veterinarian> vets = <Veterinarian>[].obs;
  final Rx<Pet?> pet = Rx<Pet?>(null);
  final Rx<Veterinarian?> selectedVet = Rx<Veterinarian?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVets();
    _loadClientPets();
  }

  Future<void> _loadVets() async {
    final res = await _consultationService.fetchVeterinarians();
    if (res.success && res.data != null) vets.assignAll(res.data!);
  }

  Future<void> _loadClientPets() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) return;
    final res = await _petService.fetchPets(uid);
    if (res.success && res.data != null) clientPets.assignAll(res.data!);
  }

  void selectVet(Veterinarian v) {
    selectedVet.value = v;
    nextStep();
  }

  void selectPet(Pet p) {
    pet.value = p;
    message.value = '';
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    if (picked != null) selectedTime.value = picked;
  }

  void nextStep() {
    if (currentStep.value < 2) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  Future<void> book() async {
    if (pet.value?.id == null ||
        selectedVet.value == null ||
        selectedDate.value == null ||
        selectedTime.value == null) {
      message.value = 'error_empty_fields'.tr;
      return;
    }
    final d = selectedDate.value!;
    final t = selectedTime.value!;
    final scheduledAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);

    isLoading.value = true;
    message.value = '';

    final GenericResponse<Consultation> res = await _consultationService.bookAppointment(
      Consultation(
        petId: pet.value!.id!,
        veterinarianId: selectedVet.value!.id,
        scheduledAt: scheduledAt,
        reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
      ),
    );

    isLoading.value = false;

    if (res.success) {
      Get.back(result: true);
    } else {
      message.value = res.message;
    }
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    timeCtrl.dispose();
    super.onClose();
  }
}
