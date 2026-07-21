class Veterinarian {
  final String id;
  final String userId;
  final String? licenseNumber;
  final String firstName;
  final String lastName;
  final int yearsExperience;
  final double rating;
  final int reviewCount;
  final List<int> specialtyIds;

  const Veterinarian({
    required this.id,
    required this.userId,
    this.licenseNumber,
    required this.firstName,
    required this.lastName,
    this.yearsExperience = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.specialtyIds = const [],
  });

  String get fullName => '$firstName $lastName';

  factory Veterinarian.fromJson(Map<String, dynamic> json) {
    final specialties = json['veterinarian_specialties'];
    final reviews = json['reviews'];
    final reviewRows = reviews is List ? reviews : const [];
    final ratings = reviewRows
        .map(
            (item) => item is Map ? (item['rating'] as num?)?.toDouble() : null)
        .whereType<double>()
        .toList();
    return Veterinarian(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      licenseNumber: json['license_number'] as String?,
      firstName: json['users']?['first_name'] as String? ?? '',
      lastName: json['users']?['last_name'] as String? ?? '',
      yearsExperience: (json['years_experience'] as num?)?.toInt() ?? 0,
      rating: ratings.isEmpty
          ? 0
          : ratings.reduce((a, b) => a + b) / ratings.length,
      reviewCount: ratings.length,
      specialtyIds: specialties is List
          ? specialties
              .map((item) =>
                  item is Map ? (item['specialty_id'] as num?)?.toInt() : null)
              .whereType<int>()
              .toList()
          : const [],
    );
  }
}

class VeterinarianAvailability {
  final int? id;
  final String veterinarianId;
  final int dayOfWeek; // 0=Sun … 6=Sat
  final String startTime; // 'HH:mm'
  final String endTime;

  const VeterinarianAvailability({
    this.id,
    required this.veterinarianId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory VeterinarianAvailability.fromJson(Map<String, dynamic> json) =>
      VeterinarianAvailability(
        id: json['id'] as int?,
        veterinarianId: json['veterinarian_id'] as String,
        dayOfWeek: json['day_of_week'] as int,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
      );
}
