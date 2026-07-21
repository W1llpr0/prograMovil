import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../configs/generic_response.dart';
import '../models/consultation.dart';
import '../models/specialty.dart';
import '../models/veterinarian.dart';

class ConsultationService {
  final SupabaseClient _sb;

  ConsultationService({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  Future<GenericResponse<List<Consultation>>> fetchForPet(int petId) async {
    try {
      final data = await _sb
          .from('consultations')
          .select(
            '*, specialties(name), veterinarians(user_id, users(first_name, last_name))',
          )
          .eq('pet_id', petId)
          .order('scheduled_at', ascending: false);
      return GenericResponse(
        success: true,
        data: (data as List)
            .map((row) =>
                Consultation.fromJson(Map<String, dynamic>.from(row as Map)))
            .toList(),
      );
    } catch (error) {
      return _failure(
          'HISTORY_ERROR', 'No se pudo cargar el historial.', error);
    }
  }

  Future<GenericResponse<List<Consultation>>> fetchForVet(String userId) async {
    try {
      final vet = await _sb
          .from('veterinarians')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      if (vet == null) {
        return const GenericResponse(success: true, data: []);
      }
      final data = await _sb
          .from('consultations')
          .select(
            '*, specialties(name), pets(name, sex_code, allergies, weight_kg, species(name), breeds(name), users!pets_client_profile_fkey(first_name, last_name))',
          )
          .eq('veterinarian_id', vet['id'])
          .order('scheduled_at');
      return GenericResponse(
        success: true,
        data: (data as List)
            .map((row) =>
                Consultation.fromJson(Map<String, dynamic>.from(row as Map)))
            .toList(),
      );
    } catch (error) {
      return _failure('AGENDA_ERROR', 'No se pudo cargar la agenda.', error);
    }
  }

  Future<GenericResponse<Consultation>> bookAppointment(
    Consultation consultation,
  ) async {
    try {
      final payload = await _sb.rpc('book_consultation', params: {
        'p_pet_id': consultation.petId,
        'p_veterinarian_id': consultation.veterinarianId,
        'p_specialty_id': consultation.specialtyId,
        'p_scheduled_at': consultation.scheduledAt.toIso8601String(),
        'p_reason': consultation.reason,
      });
      return GenericResponse<Consultation>.fromRpc(
        payload,
        decode: Consultation.fromJson,
      );
    } catch (error) {
      return _failure('BOOKING_ERROR', 'No se pudo agendar la cita.', error);
    }
  }

  Future<GenericResponse<Consultation>> startConsultation(int id) async {
    try {
      final payload = await _sb
          .rpc('start_consultation', params: {'p_consultation_id': id});
      return GenericResponse<Consultation>.fromRpc(
        payload,
        decode: Consultation.fromJson,
      );
    } catch (error) {
      return _failure('START_ERROR', 'No se pudo iniciar la consulta.', error);
    }
  }

  Future<GenericResponse<Consultation>> completeConsultation({
    required int consultationId,
    required String diagnosis,
    required String treatment,
    String? notes,
    required bool isContagious,
    Map<String, dynamic> vitals = const {},
    List<Map<String, dynamic>> medications = const [],
  }) async {
    try {
      final payload = await _sb.rpc('complete_consultation', params: {
        'p_consultation_id': consultationId,
        'p_diagnosis': diagnosis,
        'p_treatment': treatment,
        'p_notes': notes,
        'p_is_contagious': isContagious,
        'p_vitals': vitals,
        'p_medications': medications,
      });
      return GenericResponse<Consultation>.fromRpc(
        payload,
        decode: Consultation.fromJson,
      );
    } catch (error) {
      return _failure(
          'COMPLETION_ERROR', 'No se pudo finalizar la consulta.', error);
    }
  }

  Future<GenericResponse<void>> updateStatus(int id, String status) async {
    const allowed = {'pending', 'confirmed', 'cancelled'};
    if (!allowed.contains(status)) {
      return const GenericResponse(
        success: false,
        code: 'INVALID_STATUS',
        message: 'Estado de consulta no permitido.',
      );
    }
    try {
      await _sb.from('consultations').update({'status': status}).eq('id', id);
      return const GenericResponse(
          success: true, message: 'Estado actualizado.');
    } catch (error) {
      return _failure(
          'STATUS_ERROR', 'No se pudo actualizar el estado.', error);
    }
  }

  Future<GenericResponse<void>> saveDraft({
    required int consultationId,
    required String diagnosis,
    required String treatment,
    String? notes,
    Map<String, dynamic> vitals = const {},
  }) async {
    try {
      await _sb.from('consultations').update({
        'diagnosis': diagnosis.trim().isEmpty ? null : diagnosis.trim(),
        'treatment': treatment.trim().isEmpty ? null : treatment.trim(),
        'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
        'vitals': vitals,
        'status': 'in_progress',
      }).eq('id', consultationId);
      return const GenericResponse(
        success: true,
        code: 'DRAFT_SAVED',
        message: 'Borrador guardado.',
      );
    } catch (error) {
      return _failure('DRAFT_ERROR', 'No se pudo guardar el borrador.', error);
    }
  }

  Future<GenericResponse<List<Veterinarian>>> fetchVeterinarians({
    int? specialtyId,
  }) async {
    try {
      final data = await _sb
          .from('veterinarians')
          .select(
            '*, users(first_name, last_name), veterinarian_specialties(specialty_id), reviews(rating)',
          )
          .eq('is_active', true)
          .order('id');
      var list = (data as List)
          .map((row) =>
              Veterinarian.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
      if (specialtyId != null) {
        list = list
            .where((vet) => vet.specialtyIds.contains(specialtyId))
            .toList();
      }
      return GenericResponse(success: true, data: list);
    } catch (error) {
      return _failure(
          'VETS_ERROR', 'No se pudieron cargar los veterinarios.', error);
    }
  }

  Future<GenericResponse<List<Specialty>>> fetchSpecialties() async {
    try {
      final data = await _sb
          .from('specialties')
          .select()
          .eq('is_active', true)
          .order('name');
      return GenericResponse(
        success: true,
        data: (data as List)
            .map((row) =>
                Specialty.fromJson(Map<String, dynamic>.from(row as Map)))
            .toList(),
      );
    } catch (error) {
      return _failure(
        'SPECIALTIES_ERROR',
        'No se pudieron cargar las especialidades.',
        error,
      );
    }
  }

  Future<GenericResponse<List<DateTime>>> fetchAvailableSlots({
    required String veterinarianId,
    required DateTime date,
  }) async {
    try {
      final data = await _sb.rpc('available_slots', params: {
        'p_veterinarian_id': veterinarianId,
        'p_date': date.toIso8601String().split('T').first,
      });
      final slots = (data as List)
          .map((row) =>
              DateTime.parse((row as Map)['slot_at'].toString()).toLocal())
          .toList();
      return GenericResponse(success: true, data: slots);
    } catch (error) {
      return _failure(
          'SLOTS_ERROR', 'No se pudieron cargar los horarios.', error);
    }
  }

  bool verifyIntegrity(Consultation consultation) {
    if (consultation.id == null ||
        consultation.integrityHash == null ||
        consultation.diagnosis == null ||
        consultation.treatment == null) {
      return false;
    }
    final source =
        '${consultation.id}|${consultation.diagnosis!.trim()}|${consultation.treatment!.trim()}';
    return sha256.convert(utf8.encode(source)).toString() ==
        consultation.integrityHash;
  }

  GenericResponse<T> _failure<T>(
    String code,
    String message,
    Object error,
  ) =>
      GenericResponse<T>(
        success: false,
        code: code,
        message: message,
        error: error.toString(),
      );
}
