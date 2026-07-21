class Consultation {
  final int? id;
  final int petId;
  final String veterinarianId;
  final int? specialtyId;
  final DateTime scheduledAt;
  final String? reason;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final String
      status; // 'scheduled' | 'completed' | 'in_progress' | 'cancelled'
  final bool isContagious;
  final String? integrityHash;
  final Map<String, dynamic> vitals;
  final DateTime? startedAt;
  final DateTime? completedAt;
  // joined
  final String? vetName;
  final String? petName;
  final String? ownerName;
  final String? specialtyName;
  final String? petBreed;
  final String? petSex;
  final double? petWeightKg;
  final String? petAllergies;

  const Consultation({
    this.id,
    required this.petId,
    required this.veterinarianId,
    this.specialtyId,
    required this.scheduledAt,
    this.reason,
    this.diagnosis,
    this.treatment,
    this.notes,
    this.status = 'scheduled',
    this.isContagious = false,
    this.integrityHash,
    this.vitals = const {},
    this.startedAt,
    this.completedAt,
    this.vetName,
    this.petName,
    this.ownerName,
    this.specialtyName,
    this.petBreed,
    this.petSex,
    this.petWeightKg,
    this.petAllergies,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    // ownerName from pets.clients.users join
    String? ownerName;
    String? vetName;
    final pet = json['pets'];
    if (pet is Map) {
      final clientUser = pet['users'] ?? pet['clients']?['users'];
      if (clientUser is Map) {
        final fn = clientUser['first_name'] as String? ?? '';
        final ln = clientUser['last_name'] as String? ?? '';
        final full = '$fn $ln'.trim();
        if (full.isNotEmpty) ownerName = full;
      }
    }
    final vetUser = json['veterinarians']?['users'];
    if (vetUser is Map) {
      vetName =
          '${vetUser['first_name'] ?? ''} ${vetUser['last_name'] ?? ''}'.trim();
    }
    return Consultation(
      id: (json['id'] as num?)?.toInt(),
      petId: (json['pet_id'] as num).toInt(),
      veterinarianId: json['veterinarian_id']?.toString() ?? '',
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      reason: json['reason'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      isContagious: json['is_contagious'] as bool? ?? false,
      integrityHash: json['integrity_hash'] as String?,
      vitals: json['vitals'] is Map
          ? Map<String, dynamic>.from(json['vitals'] as Map)
          : const {},
      startedAt: DateTime.tryParse(json['started_at']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      vetName: vetName,
      petName: pet is Map ? pet['name'] as String? : null,
      ownerName: ownerName,
      specialtyName: json['specialties']?['name'] as String?,
      petBreed: pet is Map
          ? (pet['breeds']?['name'] as String? ??
              pet['species']?['name'] as String?)
          : null,
      petSex: pet is Map ? pet['sex_code'] as String? : null,
      petWeightKg: pet is Map ? (pet['weight_kg'] as num?)?.toDouble() : null,
      petAllergies: pet is Map ? pet['allergies'] as String? : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'pet_id': petId,
        'veterinarian_id': veterinarianId,
        if (specialtyId != null) 'specialty_id': specialtyId,
        'scheduled_at': scheduledAt.toIso8601String(),
        if (reason != null) 'reason': reason,
        'status': status,
        'is_contagious': isContagious,
      };
}
