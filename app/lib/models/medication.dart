class MedicationSchedule {
  final int? id;
  final int consultationId;
  final String medicationName;
  final String? dosage;
  final String? frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const MedicationSchedule({
    this.id,
    required this.consultationId,
    required this.medicationName,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) =>
      MedicationSchedule(
        id: json['id'] as int?,
        consultationId: json['consultation_id'] as int,
        medicationName: json['medication_name'] as String,
        dosage: json['dosage'] as String?,
        frequency: json['frequency'] as String?,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class TreatmentAdherence {
  final int? id;
  final int scheduleId;
  final DateTime takenAt;
  final String? notes;

  const TreatmentAdherence({
    this.id,
    required this.scheduleId,
    required this.takenAt,
    this.notes,
  });

  factory TreatmentAdherence.fromJson(Map<String, dynamic> json) =>
      TreatmentAdherence(
        id: json['id'] as int?,
        scheduleId: json['schedule_id'] as int,
        takenAt: DateTime.parse(json['taken_at'] as String),
        notes: json['notes'] as String?,
      );
}
