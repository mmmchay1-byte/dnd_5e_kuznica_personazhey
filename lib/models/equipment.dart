import 'dart:convert';

/// Модель снаряжения и оружия.
///
/// Поля охватывают основные характеристики предметов, включая
/// стоимость, вес, описание и свойства. Информация читается из
/// JSON-файлов, где имеется русская и английская локализация.
class Equipment {
  final int id;
  final String name;
  final String type;
  final String subType;
  final String cost;
  final double weight;
  final String description;
  final Map<String, dynamic> properties;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.subType,
    required this.cost,
    required this.weight,
    required this.description,
    required this.properties,
  });

  factory Equipment.fromJson(Map<String, dynamic> json, int id) {
    final nameRu = json['text']?['ru']?['title'] as String?;
    final nameEn = json['text']?['en']?['title'] as String?;
    final type = json['type'] as String? ?? '';
    final subType = json['subType'] as String? ?? '';
    final cost = json['cost']?['ru'] as String? ?? json['cost']?['en'] as String? ?? '';
    final weight = (json['weight'] as num?)?.toDouble() ?? 0.0;
    final descriptionRu = json['description']?['ru'] as String?;
    final descriptionEn = json['description']?['en'] as String?;
    final props = json['properties'] ?? {};
    return Equipment(
      id: id,
      name: nameRu ?? nameEn ?? 'Неизвестный предмет',
      type: type,
      subType: subType,
      cost: cost,
      weight: weight,
      description: descriptionRu ?? descriptionEn ?? '',
      properties: props as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'subType': subType,
      'cost': cost,
      'weight': weight,
      'description': description,
      'properties': jsonEncode(properties),
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      subType: map['subType'] as String,
      cost: map['cost'] as String,
      weight: (map['weight'] as num).toDouble(),
      description: map['description'] as String,
      properties: (jsonDecode(map['properties'] as String) as Map<String, dynamic>),
    );
  }
}