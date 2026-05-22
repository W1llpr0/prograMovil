import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/app_controller.dart';
import '../../configs/app_routes.dart';
import '../../configs/generic_response.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';

class VetDashboardController extends GetxController {
  final AppController appCtrl = Get.find<AppController>();
  final ConsultationService _consultationService = ConsultationService();
  final _sb = Supabase.instance.client;

  final RxList<Consultation> agenda = <Consultation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString licenseNumber = ''.obs;
  final RxInt yearsExperience = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<Map<String, dynamic>> availability = <Map<String, dynamic>>[].obs;

  // ── Date-filtered helpers ────────────────────────────────────────

  List<Consultation> get todayConsultations {
    final today = DateTime.now();
    return agenda.where((c) =>
        c.scheduledAt.year == today.year &&
        c.scheduledAt.month == today.month &&
        c.scheduledAt.day == today.day).toList();
  }

  List<Consultation> get selectedDateConsultations {
    final d = selectedDate.value;
    return agenda.where((c) =>
        c.scheduledAt.year == d.year &&
        c.scheduledAt.month == d.month &&
        c.scheduledAt.day == d.day).toList();
  }

  int get todayTotal => todayConsultations.length;
  int get completedCount => todayConsultations.where((c) => c.status == 'completed').length;
  int get inProgressCount => todayConsultations.where((c) => c.status == 'in_progress').length;
  int get pendingCount => todayConsultations.where((c) =>
      c.status == 'scheduled' || c.status == 'pending').length;

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
          'lastDate': c.scheduledAt,
        };
      } else {
        petMap[c.petId]!['consultationCount'] =
            (petMap[c.petId]!['consultationCount'] as int) + 1;
        if (c.scheduledAt.isAfter(petMap[c.petId]!['lastDate'] as DateTime)) {
          petMap[c.petId]!['lastDate'] = c.scheduledAt;
        }
      }
    }
    return petMap.values.toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadVetProfile();
    loadAgenda();
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

  Future<void> saveAvailabilitySlot({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    int slotDuration = 30,
  }) async {
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
      await _sb.from('veterinarian_availability').upsert({
        'veterinarian_id': vetId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'slot_duration_minutes': slotDuration,
        'is_active': true,
      }, onConflict: 'veterinarian_id, day_of_week');
      await loadAvailability();
    } catch (e) {
      debugPrint('saveAvailabilitySlot error: $e');
    }
  }

  void goToRegister(Consultation c) =>
      Get.toNamed(AppRoutes.registerMedical, arguments: c)?.then((_) => loadAgenda());
}

