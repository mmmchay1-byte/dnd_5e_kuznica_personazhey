import 'dart:convert';

/// Модель черты (Feat).
///
/// Черты в 5e предоставляют уникальные способности и бонусы. Этот
/// класс хранит только основные поля, необходимые для отображения,
/// описания и проверки предпосылок.
class Feat {
  final int id;
  final String name;
  final String prerequisites;
  final String description;
  final Map<String, dynamic> effects;

  Feat({
    required this.id,
    required this.name,
    required this.prerequisites,
    required this.description,
    required this.effects,
  });

  factory Feat.fromJson(Map<String, dynamic> json, int id) {
    final nameRu = json['text']?['ru']?['title'] as String?;
    final nameEn = json['text']?['en']?['title'] as String?;
    final preRu = json['requirements']?['ru'] as String?;
    final preEn = json['requirements']?['en'] as String?;
    final descRu = json['description']?['ru'] as String?;
    final descEn = json['description']?['en'] as String?;
    final effects = json['effects'] ?? {};
    return Feat(
      id: id,
      name: nameRu ?? nameEn ?? 'Безымянная черта',
      prerequisites: preRu ?? preEn ?? '',
      description: descRu ?? descEn ?? '',
      effects: effects as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'prerequisites': prerequisites,
      'description': description,
      'effects': jsonEncode(effects),
    };
  }

  factory Feat.fromMap(Map<String, dynamic> map) {
    return Feat(
      id: map['id'] as int,
      name: map['name'] as String,
      prerequisites: map['prerequisites'] as String,
      description: map['description'] as String,
      effects: (jsonDecode(map['effects'] as String) as Map<String, dynamic>),
    );
  }
}