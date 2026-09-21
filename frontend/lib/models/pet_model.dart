import 'care_log_model.dart';

class Pet {
  final int? id;
  final String name;
  final String species;
  final String? breed;
  final String? birthDate;
  final List<CareLog> careLogs;

  Pet({
    this.id,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.careLogs = const [],
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    var logsJson = json['care_logs'] as List? ?? [];
    List<CareLog> logs = logsJson.map((log) => CareLog.fromJson(log)).toList();

    return Pet(
      id: json['id'],
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'],
      birthDate: json['birth_date'],
      careLogs: logs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate,
    };
  }
}