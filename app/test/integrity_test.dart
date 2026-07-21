import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetcare_app/models/consultation.dart';
import 'package:vetcare_app/services/consultation_service.dart';

void main() {
  test('SHA-256 verifier matches the database canonical payload', () {
    const diagnosis = 'Otitis externa';
    const treatment = 'Gotas cada 8 horas';
    final hash =
        sha256.convert(utf8.encode('9|$diagnosis|$treatment')).toString();
    final consultation = Consultation(
      id: 9,
      petId: 1,
      veterinarianId: 'vet-1',
      scheduledAt: DateTime.utc(2026, 10, 18),
      diagnosis: diagnosis,
      treatment: treatment,
      integrityHash: hash,
      status: 'completed',
    );
    final service = ConsultationService(
      client: SupabaseClient('http://localhost:54321', 'anon-test-key'),
    );

    expect(service.verifyIntegrity(consultation), isTrue);
  });

  test('tampering invalidates the signature', () {
    final service = ConsultationService(
      client: SupabaseClient('http://localhost:54321', 'anon-test-key'),
    );
    final consultation = Consultation(
      id: 9,
      petId: 1,
      veterinarianId: 'vet-1',
      scheduledAt: DateTime.utc(2026, 10, 18),
      diagnosis: 'Alterado',
      treatment: 'Tratamiento',
      integrityHash: 'invalid',
      status: 'completed',
    );

    expect(service.verifyIntegrity(consultation), isFalse);
  });
}
