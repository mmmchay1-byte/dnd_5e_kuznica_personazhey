import 'dart:convert';

/// Модель заклинания (Spell) для игры D&D 5e.
///
/// Содержит основные поля, необходимые для отображения и фильтрации
/// заклинаний в приложении. При загрузке данных из JSON используется
/// только русская локализация (поле `ru`), если она доступна. В противном
/// случае используется английский вариант.
class Spell {
  final int id;
  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String components;
  final String duration;
  final String description;
  final List<String> classes;

  Spell({
    required this.id,
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.duration,
    required this.description,
    required this.classes,
  });

  /// Создаёт объект Spell из Map (например, из результата
  /// чтения JSON). Для правильной локализации выбирает поля
  /// `ru`, если они существуют, иначе использует английский `en`.
  factory Spell.fromJson(Map<String, dynamic> json, int id) {
    final nameRu = json['text']?['ru']?['title'] as String?;
    final nameEn = json['text']?['en']?['title'] as String?;
    final schoolRu = json['school']?['text']?['ru']?['title'] as String?;
    final schoolEn = json['school']?['text']?['en']?['title'] as String?;
    final classesList = (json['class'] as List?)?.map((e) => (e as String)).toList() ?? <String>[];
    return Spell(
      id: id,
      name: nameRu ?? nameEn ?? 'Неизвестное заклинание',
      level: json['level'] as int? ?? 0,
      school: schoolRu ?? schoolEn ?? '',
      castingTime: json['time']?['ru'] as String? ?? json['time']?['en'] as String? ?? '',
      range: json['range']?['ru'] as String? ?? json['range']?['en'] as String? ?? '',
      components: json['components']?['ru'] as String? ?? json['components']?['en'] as String? ?? '',
      duration: json['duration']?['ru'] as String? ?? json['duration']?['en'] as String? ?? '',
      description: json['description']?['ru'] as String? ?? json['description']?['en'] as String? ?? '',
      classes: classesList,
    );
  }

  /// Конвертирует объект в Map для хранения в базе данных SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'school': school,
      'castingTime': castingTime,
      'range': range,
      'components': components,
      'duration': duration,
      'description': description,
      'classes': jsonEncode(classes),
    };
  }

  /// Восстанавливает объект из Map (например, строки БД).
  factory Spell.fromMap(Map<String, dynamic> map) {
    return Spell(
      id: map['id'] as int,
      name: map['name'] as String,
      level: map['level'] as int,
      school: map['school'] as String,
      castingTime: map['castingTime'] as String,
      range: map['range'] as String,
      components: map['components'] as String,
      duration: map['duration'] as String,
      description: map['description'] as String,
      classes: (jsonDecode(map['classes'] as String) as List<dynamic>).cast<String>(),
    );
  }
}