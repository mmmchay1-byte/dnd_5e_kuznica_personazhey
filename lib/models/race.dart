import 'dart:convert';

/// Модель расы.
///
/// Раса определяет базовые способности персонажа: бонусы к характеристикам,
/// размер, скорость и уникальные свойства. Описание полностью на русском.
class Race {
  final int id;
  final String name;
  final String description;
  final Map<String, int> abilityBonuses;
  final String size;
  final String speed;
  final List<String> languages;
  final Map<String, dynamic> traits;

  Race({
    required this.id,
    required this.name,
    required this.description,
    required this.abilityBonuses,
    required this.size,
    required this.speed,
    required this.languages,
    required this.traits,
  });

  factory Race.fromJson(Map<String, dynamic> json, int id) {
    final name = json['name'] as String? ?? 'Неизвестная раса';
    final description = json['description'] as String? ?? '';
    final abilityBonuses = (json['ability_bonuses'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as int)) ??
        <String, int>{};
    final size = json['size'] as String? ?? '';
    final speed = json['speed'] as String? ?? '';
    final languages = (json['languages'] as List?)?.cast<String>() ?? <String>[];
    final traits = json['traits'] as Map<String, dynamic>? ?? {};
    return Race(
      id: id,
      name: name,
      description: description,
      abilityBonuses: abilityBonuses,
      size: size,
      speed: speed,
      languages: languages,
      traits: traits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'abilityBonuses': jsonEncode(abilityBonuses),
      'size': size,
      'speed': speed,
      'languages': jsonEncode(languages),
      'traits': jsonEncode(traits),
    };
  }

  factory Race.fromMap(Map<String, dynamic> map) {
    return Race(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      abilityBonuses: (jsonDecode(map['abilityBonuses'] as String) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int)),
      size: map['size'] as String,
      speed: map['speed'] as String,
      languages: (jsonDecode(map['languages'] as String) as List<dynamic>).cast<String>(),
      traits: (jsonDecode(map['traits'] as String) as Map<String, dynamic>),
    );
  }
}