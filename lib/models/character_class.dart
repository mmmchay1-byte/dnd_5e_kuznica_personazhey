/// Модель класса персонажа (CharacterClass).
///
/// Этот класс описывает базовые параметры классов D&D 5e. Полный набор
/// особенностей и заклинаний можно расширять, однако в текущей версии
/// представлены основные атрибуты: кубик хитов, способность к
/// сотворению заклинаний, спасброски, список навыков и особенности по
/// уровням.
class CharacterClass {
  final int id;
  final String name;
  final int hitDie;
  final bool canCastSpells;
  final List<String> savingThrows;
  final List<String> skillOptions;
  final Map<int, List<String>> featuresByLevel;

  CharacterClass({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.canCastSpells,
    required this.savingThrows,
    required this.skillOptions,
    required this.featuresByLevel,
  });
}

/// Предварительно определённые классы. По желанию список можно
/// пополнить или загрузить из внешнего источника. При локализации
/// названия представлены на русском языке.
final List<CharacterClass> predefinedClasses = [
  CharacterClass(
    id: 1,
    name: 'Варвар',
    hitDie: 12,
    canCastSpells: false,
    savingThrows: ['Сила', 'Телосложение'],
    skillOptions: ['Атлетика', 'Внимательность', 'Запугивание', 'Выживание'],
    featuresByLevel: {
      1: ['Ярость', 'Необузданная атака'],
      2: ['Бездоспешная защита'],
      3: ['Путь варвара'],
    },
  ),
  CharacterClass(
    id: 2,
    name: 'Бард',
    hitDie: 8,
    canCastSpells: true,
    savingThrows: ['Ловкость', 'Харизма'],
    skillOptions: ['Акробатика', 'Обман', 'Атлетика', 'Выживание', 'История', 'Внимательность', 'Интуиция'],
    featuresByLevel: {
      1: ['Вдохновение барда', 'Заклинания'],
      2: ['Песнь покоя'],
      3: ['Колледж'],
    },
  ),
  CharacterClass(
    id: 3,
    name: 'Жрец',
    hitDie: 8,
    canCastSpells: true,
    savingThrows: ['Мудрость', 'Харизма'],
    skillOptions: ['История', 'Внимательность', 'Интуиция', 'Религия'],
    featuresByLevel: {
      1: ['Божественное заклинание', 'Домены божества'],
      2: ['Каналирование божественной энергии'],
    },
  ),
  CharacterClass(
    id: 4,
    name: 'Боец',
    hitDie: 10,
    canCastSpells: false,
    savingThrows: ['Сила', 'Ловкость'],
    skillOptions: ['Атлетика', 'Выживание', 'История', 'Восприятие'],
    featuresByLevel: {
      1: ['Боевая подготовка', 'Боевая специализация'],
      2: ['Действие героя'],
    },
  ),
  CharacterClass(
    id: 5,
    name: 'Маг',
    hitDie: 6,
    canCastSpells: true,
    savingThrows: ['Интеллект', 'Мудрость'],
    skillOptions: ['История', 'Магия', 'Аркан'],
    featuresByLevel: {
      1: ['Заклинания', 'Колдовская школа'],
      2: ['Восстановление заклинателя'],
    },
  ),
  // Другие классы можно добавить аналогично
];