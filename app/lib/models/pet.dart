class Pet {
  final int? id;
  final String clientId;
  final String name;
  final int speciesId;
  final int? breedId;
  final int? sexId;
  final DateTime? birthDate;
  final double? weightKg;
  final String? microchip;
  final String? photoUrl;
  // joined
  final String? speciesName;
  final String? breedName;

  const Pet({
    this.id,
    required this.clientId,
    required this.name,
    required this.speciesId,
    this.breedId,
    this.sexId,
    this.birthDate,
    this.weightKg,
    this.microchip,
    this.photoUrl,
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
        id: json['id'] as int?,
        clientId: json['client_id'] as String,
        name: json['name'] as String,
        speciesId: json['species_id'] as int,
        breedId: json['breed_id'] as int?,
        sexId: json['sex_id'] as int,
        birthDate: json['birth_date'] != null
            ? DateTime.parse(json['birth_date'] as String)
            : null,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        microchip: json['microchip'] as String?,
        photoUrl: json['photo_url'] as String?,
        speciesName: json['species']?['name'] as String?,
        breedName: json['breeds']?['name'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'client_id': clientId,
        'name': name,
        'species_id': speciesId,
        if (breedId != null) 'breed_id': breedId,
        if (sexId != null) 'sex_id': sexId,
        if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T').first,
        if (weightKg != null) 'weight_kg': weightKg,
        if (microchip != null) 'microchip': microchip,
        if (photoUrl != null) 'photo_url': photoUrl,
      };
}