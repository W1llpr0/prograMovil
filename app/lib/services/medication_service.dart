import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/generic_response.dart';
import '../models/medication.dart';

class MedicationService {
  final _sb = Supabase.instance.client;

  Future<GenericResponse<List<MedicationSchedule>>> fetchSchedules(int petId) async {
    try {
      final data = await _sb
          .from('medication_schedules')
          .select('*, consultations!inner(pet_id)')
          .eq('consultations.pet_id', petId)
          .eq('is_active', true)
          .order('start_date');
      final list = (data as List).map((e) => MedicationSchedule.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load schedules.', error: e.toString());
    }
  }

  Future<GenericResponse<TreatmentAdherence>> markTaken({
    required int scheduleId,
    String? notes,
  }) async {
    try {
      final res = await _sb.from('treatment_adherence').insert({
        'schedule_id': scheduleId,
        'taken_at': DateTime.now().toIso8601String(),
        if (notes != null) 'notes': notes,
      }).select().single();
      return GenericResponse(success: true, data: TreatmentAdherence.fromJson(res), message: 'Logged!');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not log adherence.', error: e.toString());
    }
  }

  Future<GenericResponse<List<TreatmentAdherence>>> fetchAdherence(int scheduleId) async {
    try {
      final data = await _sb
          .from('treatment_adherence')
          .select()
          .eq('schedule_id', scheduleId)
          .order('taken_at', ascending: false);
      final list = (data as List).map((e) => TreatmentAdherence.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load adherence records.', error: e.toString());
    }
  }
}
