import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/pet.dart';
import '../../models/veterinarian.dart';
import '../../services/consultation_service.dart';
import '../../services/pet_service.dart';

class HomeController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final PetService _petService = PetService();
  final ConsultationService _consultationService = ConsultationService();

  final RxList<Pet> pets = <Pet>[].obs;
  final RxList<Veterinarian> vets = <Veterinarian>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool doseDone = false.obs;
  final RxString errorMessage = ''.obs;

  // Next dose data
  final RxString nextDoseMedication = 'No active medications'.obs;
  final RxString nextDoseTime = '—'.obs;
  final RxString nextDoseDetails = '—'.obs;
  final RxInt nextDoseId = 0.obs;

  // Appointments data
  final RxList<Map<String, dynamic>> upcomingAppointments = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkSessionAndLoadData();
  }

  Future<void> _checkSessionAndLoadData() async {
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
      await Future.wait([
        loadPets(),
        loadNextDose(),
        loadUpcomingAppointments(),
        loadVets(),
      ]);
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

  Future<void> loadNextDose() async {
    try {
      final uid = appCtrl.currentUser.value?.id;
      if (uid == null) return;

      // Get user's pets first
      final petsRes = await Supabase.instance.client
          .from('pets')
          .select('id')
          .eq('client_id', uid);

      if (petsRes.isEmpty) {
        nextDoseMedication.value = 'No pets registered yet';
        return;
      }

      final petIds = (petsRes as List).map((p) => p['id']).toList();

      // Get active medication schedules for these pets
      final medRes = await Supabase.instance.client.from('medication_schedules')
          .select('*, consultations(*, pets(name, species_id))')
          .eq('is_active', true)
          .inFilter('consultation_id', [
        for (final petId in petIds)
          (await Supabase.instance.client
              .from('consultations')
              .select('id')
              .eq('pet_id', petId)) as List
      ].expand((e) => e.map((c) => c['id'])).toList());

      if ((medRes as List).isEmpty) {
        nextDoseMedication.value = 'No active medications';
        return;
      }

      // Use the first active medication
      final med = medRes.first;
      final petName = med['consultations']['pets']['name'] ?? 'Pet';
      nextDoseId.value = med['id'] as int;
      nextDoseMedication.value = med['medication_name'] ?? 'Medication';
      nextDoseDetails.value = '${med['dosage'] ?? '1 dose'} · $petName';
      nextDoseTime.value = 'IN ${_timeUntilNext(med['frequency'] as String?)}';

      debugPrint('✅ Loaded next dose: ${nextDoseMedication.value}');
    } catch (e) {
      debugPrint('❌ Error loading next dose: $e');
    }
  }

  String _timeUntilNext(String? frequency) {
    if (frequency == null) return '04:12';
    if (frequency.contains('8')) return '03:45';
    if (frequency.contains('12')) return '06:30';
    return '04:12';
  }

  Future<void> loadUpcomingAppointments() async {
    try {
      final uid = appCtrl.currentUser.value?.id;
      if (uid == null) return;

      // Get user's pets
      final petsRes = await Supabase.instance.client
          .from('pets')
          .select('id')
          .eq('client_id', uid);

      if (petsRes.isEmpty) return;

      final petIds = (petsRes as List).map((p) => p['id']).toList();

      // Get upcoming consultations
      final now = DateTime.now();
      final apptRes = await Supabase.instance.client
          .from('consultations')
          .select(
              '*, pets(name), veterinarians(users(first_name, last_name))')
          .inFilter('pet_id', List<int>.from(petIds))
          .eq('status', 'scheduled')
          .gte('scheduled_at', now.toIso8601String())
          .order('scheduled_at', ascending: true)
          .limit(3);

      final appointments = (apptRes as List).map((appt) {
        final scheduled = DateTime.parse(appt['scheduled_at'] as String);
        return {
          'date': _formatDate(scheduled),
          'time': _formatTime(scheduled),
          'title': appt['reason'] ?? 'Consultation',
          'petName': appt['pets']['name'] ?? 'Pet',
          'vetName': 'Dr. ${(appt['veterinarians']?['users'])?['last_name'] ?? 'Vet'}',  
          'status': appt['status'] ?? 'scheduled',
        };
      }).toList();

      upcomingAppointments.assignAll(appointments);
      debugPrint('✅ Loaded ${appointments.length} appointments');
    } catch (e) {
      debugPrint('❌ Error loading appointments: $e');
    }
  }

  String _formatDate(DateTime date) {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return '${date.day} ${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void goToAddPet() => Get.toNamed(AppRoutes.addPet)?.then((_) async {
        await Future.wait([loadPets(), loadNextDose(), loadUpcomingAppointments()]);
      });

  void goToPetProfile(Pet pet) => Get.toNamed(AppRoutes.petProfile, arguments: pet);

  void goToProfile() => Get.toNamed(AppRoutes.profile);

  void goToMedication() => Get.toNamed(AppRoutes.medicationAdherence);

  void goToAlerts() => Get.toNamed(AppRoutes.epidemiologicalMap);

  Future<void> loadVets() async {
    try {
      final res = await _consultationService.fetchVeterinarians();
      if (res.success && res.data != null) {
        vets.assignAll(res.data!);
      }
    } catch (e) {
      debugPrint('❌ Error loading vets: $e');
    }
  }
}
