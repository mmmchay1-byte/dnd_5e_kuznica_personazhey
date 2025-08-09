import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/spell.dart';
import '../models/equipment.dart';
import '../models/magic_item.dart';
import '../models/feat.dart';
import '../models/race.dart';
import '../models/character.dart';
import '../models/character_class.dart';

/// Сервис базы данных (SQLite). Отвечает за открытие, создание и
/// инициализацию таблиц, а также предоставляет методы для доступа
/// к данным. Приложение использует оффлайн-хранилище, поэтому
/// вся информация читается из JSON-файлов и сохраняется в БД при
/// первом запуске.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDir.path, 'dnd5e.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _loadInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE spells(
        id INTEGER PRIMARY KEY,
        name TEXT,
        level INTEGER,
        school TEXT,
        castingTime TEXT,
        range TEXT,
        components TEXT,
        duration TEXT,
        description TEXT,
        classes TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE equipment(
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        subType TEXT,
        cost TEXT,
        weight REAL,
        description TEXT,
        properties TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE magic_items(
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        rarity TEXT,
        requiresAttunement INTEGER,
        description TEXT,
        bonuses TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE feats(
        id INTEGER PRIMARY KEY,
        name TEXT,
        prerequisites TEXT,
        description TEXT,
        effects TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE races(
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT,
        abilityBonuses TEXT,
        size TEXT,
        speed TEXT,
        languages TEXT,
        traits TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE characters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        raceId INTEGER,
        classId INTEGER,
        level INTEGER,
        abilityScores TEXT,
        maxHp INTEGER,
        currentHp INTEGER,
        tempHp INTEGER,
        armorClass INTEGER,
        initiativeBonus INTEGER,
        speed INTEGER,
        equipmentIds TEXT,
        magicItemIds TEXT
      );
    ''');
  }

  Future<void> _loadInitialData(Database db) async {
    // Загружаем содержимое JSON-файлов из assets.
    final spellsData = await _loadJsonList('assets/data/spells.json');
    final equipmentData = await _loadJsonList('assets/data/equipment.json');
    final magicItemsData = await _loadJsonList('assets/data/magic_items.json');
    final featsData = await _loadJsonList('assets/data/feats.json');
    final racesData = await _loadJsonList('assets/data/races.json');

    // Заполняем таблицы. Используем транзакцию для атомарности.
    await db.transaction((txn) async {
      int idCounter = 1;
      for (final json in spellsData) {
        final spell = Spell.fromJson(json as Map<String, dynamic>, idCounter);
        await txn.insert('spells', spell.toMap());
        idCounter++;
      }
      idCounter = 1;
      for (final json in equipmentData) {
        final eq = Equipment.fromJson(json as Map<String, dynamic>, idCounter);
        await txn.insert('equipment', eq.toMap());
        idCounter++;
      }
      idCounter = 1;
      for (final json in magicItemsData) {
        final mi = MagicItem.fromJson(json as Map<String, dynamic>, idCounter);
        await txn.insert('magic_items', mi.toMap());
        idCounter++;
      }
      idCounter = 1;
      for (final json in featsData) {
        final feat = Feat.fromJson(json as Map<String, dynamic>, idCounter);
        await txn.insert('feats', feat.toMap());
        idCounter++;
      }
      idCounter = 1;
      for (final json in racesData) {
        final race = Race.fromJson(json as Map<String, dynamic>, idCounter);
        await txn.insert('races', race.toMap());
        idCounter++;
      }
    });
  }

  Future<List<dynamic>> _loadJsonList(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final dynamic jsonData = jsonDecode(jsonString);
    if (jsonData is List) {
      return jsonData;
    } else if (jsonData is Map) {
      // Некоторые файлы (например, spells.json) могут быть объектом, где
      // непосредственно список находится в поле. Пытаемся извлечь
      // ключи верхнего уровня, содержащие массивы.
      if (jsonData.containsKey('list')) {
        return jsonData['list'] as List<dynamic>;
      }
      // В крайнем случае возвращаем список значений.
      return jsonData.values.toList();
    }
    return [];
  }

  /* CRUD методы для доступа к данным */

  Future<List<Spell>> getAllSpells() async {
    final db = await database;
    final maps = await db.query('spells');
    return maps.map((map) => Spell.fromMap(map)).toList();
  }

  Future<List<Equipment>> getAllEquipment() async {
    final db = await database;
    final maps = await db.query('equipment');
    return maps.map((map) => Equipment.fromMap(map)).toList();
  }

  Future<List<MagicItem>> getAllMagicItems() async {
    final db = await database;
    final maps = await db.query('magic_items');
    return maps.map((map) => MagicItem.fromMap(map)).toList();
  }

  Future<List<Feat>> getAllFeats() async {
    final db = await database;
    final maps = await db.query('feats');
    return maps.map((map) => Feat.fromMap(map)).toList();
  }

  Future<List<Race>> getAllRaces() async {
    final db = await database;
    final maps = await db.query('races');
    return maps.map((map) => Race.fromMap(map)).toList();
  }

  // Методы для работы с персонажами.
  Future<int> insertCharacter(Character character) async {
    final db = await database;
    return db.insert('characters', {
      'name': character.name,
      'raceId': character.race.id,
      'classId': character.characterClass.id,
      'level': character.level,
      'abilityScores': jsonEncode(character.abilityScores),
      'maxHp': character.maxHp,
      'currentHp': character.currentHp,
      'tempHp': character.tempHp,
      'armorClass': character.armorClass,
      'initiativeBonus': character.initiativeBonus,
      'speed': character.speed,
      'equipmentIds': jsonEncode(character.equipmentIds),
      'magicItemIds': jsonEncode(character.magicItemIds),
    });
  }

  Future<List<Character>> getAllCharacters(List<Race> races, List<CharacterClass> classes) async {
    final db = await database;
    final maps = await db.query('characters');
    return maps.map((map) {
      final race = races.firstWhere((r) => r.id == map['raceId']);
      final cls = classes.firstWhere((c) => c.id == map['classId']);
      final abilityScores = (jsonDecode(map['abilityScores'] as String) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int));
      final equipmentIds = (jsonDecode(map['equipmentIds'] as String? ?? '[]') as List<dynamic>).cast<int>();
      final magicItemIds = (jsonDecode(map['magicItemIds'] as String? ?? '[]') as List<dynamic>).cast<int>();
      return Character(
        id: map['id'] as int,
        name: map['name'] as String,
        race: race,
        characterClass: cls,
        level: map['level'] as int,
        abilityScores: abilityScores,
        maxHp: map['maxHp'] as int,
        currentHp: map['currentHp'] as int,
        tempHp: map['tempHp'] as int,
        armorClass: map['armorClass'] as int,
        initiativeBonus: map['initiativeBonus'] as int,
        speed: map['speed'] as int,
        equipmentIds: equipmentIds,
        magicItemIds: magicItemIds,
      );
    }).toList();
  }
}