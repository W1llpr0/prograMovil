class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? document;
  final String? address;
  final String? profilePicture;
  final double? latitude;
  final double? longitude;
  final String role; // 'client' | 'veterinarian'
  final String? licenseNumber; // from veterinarians table join
  final int? yearsExperience; // from veterinarians table join

  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.document,
    this.address,
    this.profilePicture,
    this.latitude,
    this.longitude,
    required this.role,
    this.licenseNumber,
    this.yearsExperience,
  });

  String get fullName => '$firstName $lastName';

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? document,
    String? address,
    String? profilePicture,
    double? latitude,
    double? longitude,
    String? licenseNumber,
    int? yearsExperience,
  }) =>
      AppUser(
        id: id,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        document: document ?? this.document,
        address: address ?? this.address,
        profilePicture: profilePicture ?? this.profilePicture,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        role: role,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        yearsExperience: yearsExperience ?? this.yearsExperience,
      );

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // veterinarians join can be List (one-to-many) or Map (object), handle both
    String? licenseNum;
    int? yearsExp;
    final vetData = json['veterinarians'];
    if (vetData is List && vetData.isNotEmpty) {
      licenseNum = vetData.first['license_number'] as String?;
      yearsExp = vetData.first['years_experience'] as int?;
    } else if (vetData is Map) {
      licenseNum = vetData['license_number'] as String?;
      yearsExp = vetData['years_experience'] as int?;
    }
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      document: json['document'] as String?,
      address: json['address'] as String?,
      profilePicture: json['profile_picture'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      role: json['role'] as String? ?? 'client',
      licenseNumber: licenseNum,
      yearsExperience: yearsExp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'document': document,
        'address': address,
        'profile_picture': profilePicture,
        'latitude': latitude,
        'longitude': longitude,
        'role': role,
      };
}
