import 'dart:convert';

/// Модель магического предмета.
///
/// Магические предметы в 5e обладают рядом дополнительных свойств: редкость,
/// требования к настройке (attunement) и уникальные эффекты. При
/// локализации отдаётся предпочтение русскому тексту, если он задан.
class MagicItem {
  final int id;
  final String name;
  final String type;
  final String rarity;
  final bool requiresAttunement;
  final String description;
  final Map<String, dynamic> bonuses;

  MagicItem({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.requiresAttunement,
    required this.description,
    required this.bonuses,
  });

  factory MagicItem.fromJson(Map<String, dynamic> json, int id) {
    final nameRu = json['text']?['ru']?['title'] as String?;
    final nameEn = json['text']?['en']?['title'] as String?;
    final type = json['type'] as String? ?? '';
    final rarity = json['rarity']?['ru'] as String? ?? json['rarity']?['en'] as String? ?? '';
    final requiresAttunement = json['requiresAttunement'] as bool? ?? false;
    final descriptionRu = json['description']?['ru'] as String?;
    final descriptionEn = json['description']?['en'] as String?;
    final bonuses = json['bonuses'] ?? {};
    return MagicItem(
      id: id,
      name: nameRu ?? nameEn ?? 'Неизвестный магический предмет',
      type: type,
      rarity: rarity,
      requiresAttunement: requiresAttunement,
      description: descriptionRu ?? descriptionEn ?? '',
      bonuses: bonuses as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rarity': rarity,
      'requiresAttunement': requiresAttunement ? 1 : 0,
      'description': description,
      'bonuses': jsonEncode(bonuses),
    };
  }

  factory MagicItem.fromMap(Map<String, dynamic> map) {
    return MagicItem(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      rarity: map['rarity'] as String,
      requiresAttunement: (map['requiresAttunement'] as int) == 1,
      description: map['description'] as String,
      bonuses: (jsonDecode(map['bonuses'] as String) as Map<String, dynamic>),
    );
  }
}