import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final RxString errorMessage = ''.obs;

  // Appointments data
  final RxList<Map<String, dynamic>> upcomingAppointments =
      <Map<String, dynamic>>[].obs;

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
        loadUpcomingAppointments(),
        loadVets(),
      ]);
    } catch (e) {
      errorMessage.value = 'No se pudieron cargar los datos.';
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
      errorMessage.value = 'No se pudieron cargar las mascotas.';
      debugPrint('❌ Exception loading pets: $e');
    }
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

      if (petsRes.isEmpty) {
        upcomingAppointments.clear();
        return;
      }

      final petIds = (petsRes as List).map((p) => p['id']).toList();

      // Get upcoming consultations
      final now = DateTime.now().toUtc();
      final apptRes = await Supabase.instance.client
          .from('consultations')
          .select('*, pets(name), veterinarians(users(first_name, last_name))')
          .inFilter('pet_id', List<int>.from(petIds))
          .inFilter('status', ['pending', 'scheduled', 'confirmed'])
          .gte('scheduled_at', now.toIso8601String())
          .order('scheduled_at', ascending: true);

      final appointments = (apptRes as List).map((appt) {
        final scheduled = DateTime.parse(appt['scheduled_at'] as String);
        return {
          'date': _formatDate(scheduled),
          'time': _formatTime(scheduled),
          'title': appt['reason'] ?? 'Consultation',
          'petName': appt['pets']['name'] ?? 'Pet',
          'vetName':
              'Dr. ${(appt['veterinarians']?['users'])?['last_name'] ?? 'Vet'}',
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
    return DateFormat('dd MMM', 'es_ES').format(date.toLocal()).toUpperCase();
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm', 'es_ES').format(date.toLocal());
  }

  void goToAddPet() => Get.toNamed(AppRoutes.addPet)?.then((_) async {
        await Future.wait([loadPets(), loadUpcomingAppointments()]);
      });

  void goToPetProfile(Pet pet) =>
      Get.toNamed(AppRoutes.petProfile, arguments: pet);

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
