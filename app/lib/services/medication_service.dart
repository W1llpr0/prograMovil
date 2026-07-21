import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/generic_response.dart';
import '../models/medication.dart';

class MedicationService {
  final _sb = Supabase.instance.client;

  Future<GenericResponse<List<MedicationSchedule>>> fetchSchedules(
      int petId) async {
    try {
      final data = await _sb
          .from('medication_schedules')
          .select('*, consultations!inner(pet_id)')
          .eq('consultations.pet_id', petId)
          .eq('is_active', true)
          .order('start_date');
      final list =
          (data as List).map((e) => MedicationSchedule.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(
          success: false,
          message: 'No se pudieron cargar los tratamientos.',
          error: e.toString());
    }
  }

  Future<GenericResponse<Map<String, dynamic>>> markTaken({
    required int scheduleId,
    String? notes,
  }) async {
    try {
      final payload = await _sb.rpc('record_medication_dose', params: {
        'p_schedule_id': scheduleId,
        'p_notes': notes,
      });
      return GenericResponse<Map<String, dynamic>>.fromRpc(
        payload,
        decode: (json) => json,
      );
    } catch (e) {
      return GenericResponse(
          success: false,
          message: 'No se pudo registrar la dosis.',
          error: e.toString());
    }
  }

  Future<GenericResponse<List<TreatmentAdherence>>> fetchAdherence(
      int scheduleId) async {
    try {
      final data = await _sb
          .from('treatment_adherence')
          .select()
          .eq('schedule_id', scheduleId)
          .order('taken_at', ascending: false);
      final list =
          (data as List).map((e) => TreatmentAdherence.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(
          success: false,
          message: 'No se pudieron cargar las dosis registradas.',
          error: e.toString());
    }
  }
}
