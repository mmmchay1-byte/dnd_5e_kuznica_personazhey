import 'dart:math';

import 'package:dnd_5e_kuznica_personazhey/models/race.dart';
import 'package:dnd_5e_kuznica_personazhey/models/character_class.dart';

/// Модель персонажа.
///
/// Хранит выбранную расу, класс, уровень, характеристики и
/// позволяет вычислять модификаторы, бонусы мастерства и другие
/// показатели. Дополнительно поддерживает текущее и максимальное
/// количество очков здоровья, временные ОЗ, значение КД и скорость.
class Character {
  int id;
  String name;
  Race race;
  CharacterClass characterClass;
  int level;
  Map<String, int> abilityScores; // Сила, Ловкость, Телосложение, Интеллект, Мудрость, Харизма
  int maxHp;
  int currentHp;
  int tempHp;
  int armorClass;
  int initiativeBonus;
  int speed;

  /// Идентификаторы экипированного снаряжения. Каждое число соответствует
  /// записи в таблице equipment.
  List<int> equipmentIds;

  /// Идентификаторы экипированных магических предметов. Для ограничений
  /// настройки (attunement) можно контролировать длину списка.
  List<int> magicItemIds;

  Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    this.level = 1,
    Map<String, int>? abilityScores,
    this.maxHp = 0,
    this.currentHp = 0,
    this.tempHp = 0,
    this.armorClass = 10,
    this.initiativeBonus = 0,
    this.speed = 30,
    List<int>? equipmentIds,
    List<int>? magicItemIds,
  }) : abilityScores = abilityScores ?? {
          'Сила': 10,
          'Ловкость': 10,
          'Телосложение': 10,
          'Интеллект': 10,
          'Мудрость': 10,
          'Харизма': 10,
        },
        equipmentIds = equipmentIds ?? <int>[],
        magicItemIds = magicItemIds ?? <int>[];

  /// Вычисляет модификатор характеристики: floor((score - 10) / 2).
  int getAbilityMod(String ability) {
    final score = abilityScores[ability] ?? 10;
    return ((score - 10) / 2).floor();
  }

  /// Бонус мастерства: 2 на уровнях 1–4, 3 на уровнях 5–8, 4 на 9–12, 5 на 13–16, 6 на 17–20.
  int get proficiencyBonus {
    if (level >= 17) return 6;
    if (level >= 13) return 5;
    if (level >= 9) return 4;
    if (level >= 5) return 3;
    return 2;
  }

  /// Бросок спасброска для указанной характеристики учитывает бонус
  /// мастерства, если персонаж владеет этим спасброском.
  int savingThrow(String ability) {
    int mod = getAbilityMod(ability);
    if (characterClass.savingThrows.contains(ability)) {
      mod += proficiencyBonus;
    }
    return mod;
  }

  /// Получить скорость персонажа в футах, учитывая расу.
  int get movementSpeed {
    // Извлекаем число из строки скорости (например, "30 футов")
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(race.speed);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? speed;
    }
    return speed;
  }

  /// Сериализация в Map для сохранения в базе данных.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'raceId': race.id,
      'classId': characterClass.id,
      'level': level,
      'abilityScores': abilityScores,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'tempHp': tempHp,
      'armorClass': armorClass,
      'initiativeBonus': initiativeBonus,
      'speed': speed,
      'equipmentIds': equipmentIds,
      'magicItemIds': magicItemIds,
    };
  }
}