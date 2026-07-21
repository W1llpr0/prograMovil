import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show EdgeInsets;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../services/auth_service.dart';
import '../../services/consultation_service.dart';
import '../sign_in/sign_in_controller.dart';

class VetDashboardController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final ConsultationService _consultationService = ConsultationService();
  final _sb = Supabase.instance.client;

  final RxList<Consultation> agenda = <Consultation>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString licenseNumber = ''.obs;
  final RxInt yearsExperience = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<Map<String, dynamic>> availability =
      <Map<String, dynamic>>[].obs;

  // ── Date-filtered helpers ────────────────────────────────────────

  List<Consultation> get todayConsultations {
    final today = DateTime.now();
    return agenda
        .where((c) =>
            c.scheduledAt.year == today.year &&
            c.scheduledAt.month == today.month &&
            c.scheduledAt.day == today.day)
        .toList();
  }

  List<Consultation> get selectedDateConsultations {
    final d = selectedDate.value;
    return agenda
        .where((c) =>
            c.scheduledAt.year == d.year &&
            c.scheduledAt.month == d.month &&
            c.scheduledAt.day == d.day)
        .toList();
  }

  int get todayTotal => todayConsultations.length;
  int get completedCount =>
      todayConsultations.where((c) => c.status == 'completed').length;
  int get inProgressCount =>
      todayConsultations.where((c) => c.status == 'in_progress').length;
  int get pendingCount => todayConsultations
      .where((c) => c.status == 'scheduled' || c.status == 'pending')
      .length;

  // ── All-time stats ───────────────────────────────────────────────

  int get totalConsultations => agenda.length;
  int get totalCompleted => agenda.where((c) => c.status == 'completed').length;

  // ── Unique patient list ──────────────────────────────────────────

  List<Map<String, dynamic>> get patients {
    final Map<int, Map<String, dynamic>> petMap = {};
    for (final c in agenda) {
      if (!petMap.containsKey(c.petId)) {
        petMap[c.petId] = {
          'petId': c.petId,
          'petName': c.petName ?? 'Unknown',
          'ownerName': c.ownerName ?? '—',
          'consultationCount': 1,
          'completedCount': c.status == 'completed' ? 1 : 0,
          'pendingConsultationCount':
              c.status == 'completed' || c.status == 'cancelled' ? 0 : 1,
          'lastDate': c.scheduledAt,
          'actionConsultation': c,
        };
      } else {
        final patient = petMap[c.petId]!;
        patient['consultationCount'] =
            (patient['consultationCount'] as int) + 1;
        if (c.status == 'completed') {
          patient['completedCount'] = (patient['completedCount'] as int) + 1;
        } else if (c.status != 'cancelled') {
          patient['pendingConsultationCount'] =
              (patient['pendingConsultationCount'] as int) + 1;
        }
        if (c.scheduledAt.isAfter(patient['lastDate'] as DateTime)) {
          patient['lastDate'] = c.scheduledAt;
        }
        final current = patient['actionConsultation'] as Consultation;
        final candidatePriority = _patientActionPriority(c.status);
        final currentPriority = _patientActionPriority(current.status);
        if (candidatePriority > currentPriority ||
            (candidatePriority == currentPriority &&
                c.scheduledAt.isAfter(current.scheduledAt))) {
          patient['actionConsultation'] = c;
        }
      }
    }
    final result = petMap.values.toList();
    result.sort((a, b) =>
        (b['lastDate'] as DateTime).compareTo(a['lastDate'] as DateTime));
    return result;
  }

  int _patientActionPriority(String status) => switch (status) {
        'in_progress' => 3,
        'scheduled' || 'pending' || 'confirmed' => 2,
        'completed' => 1,
        _ => 0,
      };

  @override
  void onInit() {
    super.onInit();
    _loadVetProfile();
    loadAgenda();
    loadAvailability();
  }

  Future<void> _loadVetProfile() async {
    try {
      final user = appCtrl.currentUser.value;
      if (user == null) return;
      // Prefer data already joined into AppUser from _fetchProfile
      if (user.licenseNumber != null && user.licenseNumber!.isNotEmpty) {
        licenseNumber.value = user.licenseNumber!;
        yearsExperience.value = user.yearsExperience ?? 0;
        return;
      }
      // Fallback: direct query
      final data = await _sb
          .from('veterinarians')
          .select('license_number, years_experience')
          .eq('user_id', user.id)
          .maybeSingle();
      if (data != null) {
        licenseNumber.value = data['license_number'] as String? ?? '';
        yearsExperience.value = data['years_experience'] as int? ?? 0;
      }
    } catch (e) {
      debugPrint('_loadVetProfile error: $e');
    }
  }

  Future<void> loadAgenda() async {
    final uid = appCtrl.currentUser.value?.id;
    if (uid == null) return;
    isLoading.value = true;
    final GenericResponse<List<Consultation>> res =
        await _consultationService.fetchForVet(uid);
    isLoading.value = false;
    if (res.success && res.data != null) {
      agenda.assignAll(res.data!);
    }
  }

  Future<void> loadAvailability() async {
    try {
      final uid = appCtrl.currentUser.value?.id;
      if (uid == null) return;
      final vetRow = await _sb
          .from('veterinarians')
          .select('id')
          .eq('user_id', uid)
          .maybeSingle();
      if (vetRow == null) return;
      final vetId = vetRow['id'];
      final data = await _sb
          .from('veterinarian_availability')
          .select()
          .eq('veterinarian_id', vetId)
          .order('day_of_week');
      availability.assignAll((data as List).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('loadAvailability error: $e');
    }
  }

  Future<bool> saveAvailabilitySlot({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    int slotDuration = 30,
  }) async {
    isSaving.value = true;
    try {
      final uid = appCtrl.currentUser.value?.id;
      if (uid == null) {
        debugPrint('saveAvailabilitySlot: uid is null');
        Get.snackbar('Error', 'No hay sesión activa',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16));
        return false;
      }
      final vetRow = await _sb
          .from('veterinarians')
          .select('id')
          .eq('user_id', uid)
          .maybeSingle();
      if (vetRow == null) {
        debugPrint('saveAvailabilitySlot: no vet row for uid=$uid');
        Get.snackbar('Error', 'No se encontró perfil de veterinario (uid=$uid)',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.all(16));
        return false;
      }
      final vetId = vetRow['id'];
      await _sb.from('veterinarian_availability').upsert({
        'veterinarian_id': vetId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'slot_duration_minutes': slotDuration,
        'is_active': true,
      }, onConflict: 'veterinarian_id,day_of_week');
      await loadAvailability();
      Get.snackbar('', 'vet_save_ok'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16));
      return true;
    } catch (e) {
      debugPrint('saveAvailabilitySlot error: $e');
      Get.snackbar('', 'vet_save_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void goToRegister(Consultation c) {
    final route = switch (c.status) {
      'completed' => AppRoutes.clinicalHistory,
      'in_progress' => AppRoutes.registerMedical,
      _ => AppRoutes.preConsultation,
    };
    Get.toNamed(route, arguments: c)?.then((_) => loadAgenda());
  }

  Future<void> signOut() async {
    await AuthService().signOut();
    Get.delete<SignInController>(force: true);
    Get.offAllNamed(AppRoutes.signIn);
  }
}
