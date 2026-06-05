import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/generic_response.dart';
import '../models/consultation.dart';
import '../models/veterinarian.dart';

class ConsultationService {
  final _sb = Supabase.instance.client;

  Future<GenericResponse<List<Consultation>>> fetchForPet(int petId) async {
    try {
      final data = await _sb
          .from('consultations')
          .select('*, veterinarians(user_id, users(first_name, last_name))')
          .eq('pet_id', petId)
          .order('scheduled_at', ascending: false);
      final list = (data as List).map((e) => Consultation.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load history.', error: e.toString());
    }
  }

  Future<GenericResponse<List<Consultation>>> fetchForVet(String userId) async {
    try {
      // Resolve user UUID → veterinarians.id (int FK used in consultations)
      final vetRow = await _sb
          .from('veterinarians')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      if (vetRow == null) return const GenericResponse(success: true, data: []);
      final vetId = vetRow['id'];
      final data = await _sb
          .from('consultations')
          .select('*, pets(name, clients(users(first_name, last_name)))')
          .eq('veterinarian_id', vetId)
          .order('scheduled_at', ascending: false);
      final list = (data as List).map((e) => Consultation.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load agenda.', error: e.toString());
    }
  }

  Future<GenericResponse<Consultation>> bookAppointment(Consultation c) async {
    try {
      final res = await _sb
          .from('consultations')
          .insert(c.toInsertJson())
          .select()
          .single();
      return GenericResponse(success: true, data: Consultation.fromJson(res), message: 'Appointment booked.');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not book appointment.', error: e.toString());
    }
  }

  /// Completes a consultation with diagnosis/treatment and generates SHA-256 hash.
  Future<GenericResponse<Consultation>> completeConsultation({
    required int consultationId,
    required String diagnosis,
    required String treatment,
    String? notes,
    required bool isContagious,
  }) async {
    try {
      final hash = _generateHash(
        consultationId: consultationId,
        diagnosis: diagnosis,
        treatment: treatment,
      );
      final res = await _sb
          .from('consultations')
          .update({
            'diagnosis': diagnosis,
            'treatment': treatment,
            if (notes != null) 'notes': notes,
            'is_contagious': isContagious,
            'status': 'completed',
            'integrity_hash': hash,
          })
          .eq('id', consultationId)
          .select()
          .single();
      return GenericResponse(success: true, data: Consultation.fromJson(res), message: 'Record saved.');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not save record.', error: e.toString());
    }
  }

  /// Verifies the stored SHA-256 hash matches recomputed hash.
  bool verifyIntegrity(Consultation c) {
    if (c.integrityHash == null || c.diagnosis == null || c.treatment == null) {
      return false;
    }
    final expected = _generateHash(
      consultationId: c.id!,
      diagnosis: c.diagnosis!,
      treatment: c.treatment!,
    );
    return expected == c.integrityHash;
  }

  String _generateHash({
    required int consultationId,
    required String diagnosis,
    required String treatment,
  }) {
    final payload = '$consultationId|$diagnosis|$treatment';
    final bytes = utf8.encode(payload);
    return sha256.convert(bytes).toString();
  }

  Future<GenericResponse<List<Veterinarian>>> fetchVeterinarians() async {
    try {
      final data = await _sb
          .from('veterinarians')
          .select('*, users(first_name, last_name)')
          .order('id');
      final list = (data as List).map((e) => Veterinarian.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load veterinarians.', error: e.toString());
    }
  }
}
