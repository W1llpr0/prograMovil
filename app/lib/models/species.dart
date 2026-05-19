class Species {
  final int id;
  final String name;
  final bool isExotic;

  const Species({required this.id, required this.name, this.isExotic = false});

  factory Species.fromJson(Map<String, dynamic> json) => Species(
        id: json['id'] as int,
        name: json['name'] as String,
        isExotic: json['is_exotic'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'is_exotic': isExotic};
}

class Breed {
  final int id;
  final String name;
  final int speciesId;

  const Breed({required this.id, required this.name, required this.speciesId});

  factory Breed.fromJson(Map<String, dynamic> json) => Breed(
        id: json['id'] as int,
        name: json['name'] as String,
        speciesId: json['species_id'] as int,
      );
}
