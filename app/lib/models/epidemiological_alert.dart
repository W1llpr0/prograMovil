class EpidemiologicalAlert {
  final int? id;
  final int? consultationId;
  final String disease;
  final double? latitude;
  final double? longitude;
  final double radiusKm;
  final DateTime createdAt;
  final bool isActive;

  const EpidemiologicalAlert({
    this.id,
    this.consultationId,
    required this.disease,
    this.latitude,
    this.longitude,
    this.radiusKm = 5.0,
    required this.createdAt,
    this.isActive = true,
  });

  factory EpidemiologicalAlert.fromJson(Map<String, dynamic> json) =>
      EpidemiologicalAlert(
        id: json['id'] as int?,
        consultationId: json['consultation_id'] as int?,
        disease: json['disease'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 5.0,
        createdAt: DateTime.parse(json['created_at'] as String),
        isActive: json['is_active'] as bool? ?? true,
      );
}
