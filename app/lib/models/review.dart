class Review {
  final int id;
  final int consultationId;
  final String clientId;
  final String veterinarianId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? petName;
  final String? specialtyName;
  final String? diagnosis;
  final DateTime? consultationDate;

  const Review({
    required this.id,
    required this.consultationId,
    required this.clientId,
    required this.veterinarianId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.petName,
    this.specialtyName,
    this.diagnosis,
    this.consultationDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final consultation = json['consultations'];
    final consultationMap = consultation is Map ? consultation : null;
    final pet = consultationMap?['pets'];
    final specialty = consultationMap?['specialties'];
    return Review(
      id: (json['id'] as num).toInt(),
      consultationId: (json['consultation_id'] as num).toInt(),
      clientId: json['client_id'] as String,
      veterinarianId: json['veterinarian_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      petName: pet is Map ? pet['name']?.toString() : null,
      specialtyName: specialty is Map ? specialty['name']?.toString() : null,
      diagnosis: consultationMap?['diagnosis']?.toString(),
      consultationDate: DateTime.tryParse(
        consultationMap?['scheduled_at']?.toString() ?? '',
      ),
    );
  }
}
