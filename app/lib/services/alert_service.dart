import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/generic_response.dart';
import '../models/epidemiological_alert.dart';
import '../models/exotic_models.dart';

class AlertService {
  final _sb = Supabase.instance.client;

  Future<GenericResponse<List<EpidemiologicalAlert>>> fetchActiveAlerts() async {
    try {
      final data = await _sb
          .from('epidemiological_alerts')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      final list = (data as List).map((e) => EpidemiologicalAlert.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load alerts.', error: e.toString());
    }
  }

  // ── Exotic / CITES ──────────────────────────────────────────────────────

  Future<GenericResponse<List<MorphologicalRecord>>> fetchMorphological(int petId) async {
    try {
      final data = await _sb
          .from('morphological_records')
          .select()
          .eq('pet_id', petId)
          .order('recorded_at', ascending: false);
      final list = (data as List).map((e) => MorphologicalRecord.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load morphological records.', error: e.toString());
    }
  }

  Future<GenericResponse<MorphologicalRecord>> addMorphological(MorphologicalRecord record) async {
    try {
      final res = await _sb
          .from('morphological_records')
          .insert(record.toInsertJson())
          .select()
          .single();
      return GenericResponse(success: true, data: MorphologicalRecord.fromJson(res), message: 'Record added.');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not add record.', error: e.toString());
    }
  }

  Future<GenericResponse<List<LegalDocument>>> fetchLegalDocs(int petId) async {
    try {
      final data = await _sb
          .from('legal_documents')
          .select()
          .eq('pet_id', petId)
          .order('expires_at');
      final list = (data as List).map((e) => LegalDocument.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load documents.', error: e.toString());
    }
  }
}
