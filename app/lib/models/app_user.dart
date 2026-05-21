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
  });

  String get fullName => '$firstName $lastName';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
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
      );

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
