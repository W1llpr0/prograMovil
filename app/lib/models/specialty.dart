class Specialty {
  final int id;
  final String name;
  final String? icon;

  const Specialty({required this.id, required this.name, this.icon});

  factory Specialty.fromJson(Map<String, dynamic> json) => Specialty(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        icon: json['icon'] as String?,
      );
}
