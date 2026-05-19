class Consultation {
  final int? id;
  final int petId;
  final String veterinarianId;
  final DateTime scheduledAt;
  final String? reason;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final String status; // 'scheduled' | 'completed' | 'cancelled'
  final bool isContagious;
  final String? integrityHash;
  // joined
  final String? vetName;
  final String? petName;

  const Consultation({
    this.id,
    required this.petId,
    required this.veterinarianId,
    required this.scheduledAt,
    this.reason,
    this.diagnosis,
    this.treatment,
    this.notes,
    this.status = 'scheduled',
    this.isContagious = false,
    this.integrityHash,
    this.vetName,
    this.petName,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
        id: json['id'] as int?,
        petId: json['pet_id'] as int,
        veterinarianId: json['veterinarian_id'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        reason: json['reason'] as String?,
        diagnosis: json['diagnosis'] as String?,
        treatment: json['treatment'] as String?,
        notes: json['notes'] as String?,
        status: json['status'] as String? ?? 'scheduled',
        isContagious: json['is_contagious'] as bool? ?? false,
        integrityHash: json['integrity_hash'] as String?,
        vetName: json['veterinarians']?['users']?['first_name'] as String?,
        petName: json['pets']?['name'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'pet_id': petId,
        'veterinarian_id': veterinarianId,
        'scheduled_at': scheduledAt.toIso8601String(),
        if (reason != null) 'reason': reason,
        'status': status,
        'is_contagious': isContagious,
      };
}
