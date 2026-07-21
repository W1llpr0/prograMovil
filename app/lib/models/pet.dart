class Pet {
  final int? id;
  final String clientId;
  final String name;
  final int speciesId;
  final int? breedId;
  final String? sexCode; // 'M' | 'F'
  final DateTime? birthDate;
  final double? weightKg;
  final String? microchip;
  final String? photoUrl;
  final String? allergies;
  final bool isExotic;
  // joined
  final String? speciesName;
  final String? breedName;

  const Pet({
    this.id,
    required this.clientId,
    required this.name,
    required this.speciesId,
    this.breedId,
    this.sexCode,
    this.birthDate,
    this.weightKg,
    this.microchip,
    this.photoUrl,
    this.allergies,
    this.isExotic = false,
    this.speciesName,
    this.breedName,
  });

  int get ageYears {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: (json['id'] as num?)?.toInt(),
        clientId: json['client_id'] as String,
        name: json['name'] as String,
        speciesId: (json['species_id'] as num).toInt(),
        breedId: (json['breed_id'] as num?)?.toInt(),
        sexCode: json['sex_code'] as String?,
        birthDate: json['birth_date'] != null
            ? DateTime.parse(json['birth_date'] as String)
            : null,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        microchip: json['microchip'] as String?,
        photoUrl: json['photo_url'] as String?,
        allergies: json['allergies'] as String?,
        isExotic: json['is_exotic'] as bool? ?? false,
        speciesName: json['species']?['name'] as String?,
        breedName: json['breeds']?['name'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'client_id': clientId,
        'name': name,
        'species_id': speciesId,
        if (breedId != null) 'breed_id': breedId,
        if (sexCode != null) 'sex_code': sexCode,
        if (birthDate != null)
          'birth_date': birthDate!.toIso8601String().split('T').first,
        if (weightKg != null) 'weight_kg': weightKg,
        if (microchip != null) 'microchip': microchip,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (allergies != null) 'allergies': allergies,
        'is_exotic': isExotic,
      };
}
