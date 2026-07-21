import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all fifteen mockups have an implemented page contract', () {
    final root = Directory.current.parent.path;
    for (var index = 1; index <= 15; index++) {
      expect(File('$root/Docs/mockups/m_$index.jpg').existsSync(), isTrue,
          reason: 'mockup m_$index is missing');
    }

    final contracts = <String, List<String>>{
      'lib/pages/sign_in/sign_in_page.dart': [
        'VetCare',
        'Correo electrónico',
        'Iniciar sesión'
      ],
      'lib/pages/sign_up/sign_up_page.dart': [
        'Crear cuenta',
        'Dueño',
        'Veterinario',
        'Completar registro'
      ],
      'lib/pages/home/home_page.dart': [
        'Servicios',
        'Agendar cita',
        'Mis mascotas',
        'Mis citas'
      ],
      'lib/pages/pet_profile/pet_profile_page.dart': [
        'Expediente:',
        'Historial médico',
        'Agendar cita'
      ],
      'lib/pages/book_appointment/book_appointment_page.dart': [
        'Nueva cita',
        'Selecciona la mascota',
        'Fecha y doctor',
        'Confirmar'
      ],
      'lib/pages/profile/profile_page.dart': [
        'Mi cuenta',
        'Mis reseñas',
        'Mi perfil médico',
        'Especialidades'
      ],
      'lib/pages/vet_dashboard/vet_dashboard_page.dart': [
        'Resumen diario',
        'Paciente en sala',
        'Mi agenda médica'
      ],
      'lib/pages/pre_consultation/pre_consultation_page.dart': [
        'Expediente clínico',
        'Motivo escrito por el cliente',
        'Iniciar consulta'
      ],
      'lib/pages/register_medical/register_medical_page.dart': [
        'Atendiendo:',
        'Diagnóstico clínico',
        'Tratamiento prescrito',
        'Adjuntar'
      ],
      'lib/pages/consultation_documents/consultation_documents_page.dart': [
        'Resultados clínicos',
        'Tocar para examinar',
        'Guardar y finalizar cita'
      ],
      'lib/pages/review_consultation/review_consultation_page.dart': [
        'Evaluar atención',
        '¿Qué tal te pareció el servicio?',
        'Enviar reseña'
      ],
    };

    for (final entry in contracts.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final label in entry.value) {
        expect(source, contains(label), reason: '${entry.key} misses $label');
      }
    }
  });

  test('mockup actions are connected to Supabase services', () {
    final booking =
        File('lib/services/consultation_service.dart').readAsStringSync();
    final documents =
        File('lib/services/document_service.dart').readAsStringSync();
    final reviews = File('lib/services/review_service.dart').readAsStringSync();
    final clinicalHistory =
        File('lib/pages/clinical_history/clinical_history_page.dart')
            .readAsStringSync();
    final auth = File('lib/services/auth_service.dart').readAsStringSync();
    final medications =
        File('lib/services/medication_service.dart').readAsStringSync();
    final medicationPage =
        File('lib/pages/medication_adherence/medication_adherence_page.dart')
            .readAsStringSync();
    final profile =
        File('lib/pages/profile/profile_page.dart').readAsStringSync();

    for (final rpc in [
      'book_consultation',
      'start_consultation',
      'complete_consultation',
    ]) {
      expect(booking, contains("rpc('$rpc'"));
    }
    expect(documents, contains("from('consultation_documents')"));
    expect(documents, contains('.uploadBinary('));
    expect(reviews, contains("rpc('submit_review'"));
    expect(clinicalHistory, contains('fetchForConsultation'));
    expect(clinicalHistory, contains('submitted == true'));
    expect(auth, contains('.signInWithPassword('));
    expect(auth, contains('.signUp('));
    expect(medications, contains("rpc('record_medication_dose'"));
    expect(medicationPage, contains('final selectedPetId'));
    expect(medicationPage, contains('final marking = ctrl.marking.toSet()'));
    expect(profile, contains('review.petName'));
    expect(profile, contains('review.consultationDate'));
  });
}
