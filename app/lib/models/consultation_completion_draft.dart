import 'consultation.dart';

/// Data entered in mockup 12 and finalized only from mockup 13.
class ConsultationCompletionDraft {
  final Consultation consultation;
  final String diagnosis;
  final String treatment;
  final String? notes;
  final bool isContagious;
  final Map<String, dynamic> vitals;
  final List<Map<String, dynamic>> medications;

  const ConsultationCompletionDraft({
    required this.consultation,
    required this.diagnosis,
    required this.treatment,
    this.notes,
    required this.isContagious,
    this.vitals = const {},
    this.medications = const [],
  });
}
