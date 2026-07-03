class Veterinarian {
  final String id;
  final String userId;
  final String? licenseNumber;
  final String firstName;
  final String lastName;

  const Veterinarian({
    required this.id,
    required this.userId,
    this.licenseNumber,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory Veterinarian.fromJson(Map<String, dynamic> json) => Veterinarian(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        licenseNumber: json['license_number'] as String?,
        firstName: json['users']?['first_name'] as String? ?? '',
        lastName: json['users']?['last_name'] as String? ?? '',
      );
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
