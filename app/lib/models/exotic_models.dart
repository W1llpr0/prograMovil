class MorphologicalRecord {
  final int? id;
  final int petId;
  final DateTime recordedAt;
  final double? lengthCm;
  final double? weightKg;
  final String? scaleCondition;
  final String? colorPattern;
  final String? notes;

  const MorphologicalRecord({
    this.id,
    required this.petId,
    required this.recordedAt,
    this.lengthCm,
    this.weightKg,
    this.scaleCondition,
    this.colorPattern,
    this.notes,
  });

  factory MorphologicalRecord.fromJson(Map<String, dynamic> json) =>
      MorphologicalRecord(
        id: json['id'] as int?,
        petId: json['pet_id'] as int,
        recordedAt: DateTime.parse(json['recorded_at'] as String),
        lengthCm: (json['length_cm'] as num?)?.toDouble(),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        scaleCondition: json['scale_condition'] as String?,
        colorPattern: json['color_pattern'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'pet_id': petId,
        'recorded_at': recordedAt.toIso8601String(),
        if (lengthCm != null) 'length_cm': lengthCm,
        if (weightKg != null) 'weight_kg': weightKg,
        if (scaleCondition != null) 'scale_condition': scaleCondition,
        if (colorPattern != null) 'color_pattern': colorPattern,
        if (notes != null) 'notes': notes,
      };
}

class LegalDocument {
  final int? id;
  final int petId;
  final String docType; // 'CITES' | 'import_permit' | 'ownership'
  final String fileUrl;
  final DateTime? expiresAt;
  final String? notes;

  const LegalDocument({
    this.id,
    required this.petId,
    required this.docType,
    required this.fileUrl,
    this.expiresAt,
    this.notes,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
        id: json['id'] as int?,
        petId: json['pet_id'] as int,
        docType: json['doc_type'] as String,
        fileUrl: json['file_url'] as String,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        notes: json['notes'] as String?,
      );
}
