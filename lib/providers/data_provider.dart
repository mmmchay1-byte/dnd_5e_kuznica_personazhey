import 'package:flutter/material.dart';

import '../models/spell.dart';
import '../models/equipment.dart';
import '../models/magic_item.dart';
import '../models/feat.dart';
import '../models/race.dart';
import '../services/database_service.dart';

/// Provider для глобального доступа к справочным данным (заклинания,
/// снаряжение, магические предметы, черты и расы). Загружает
/// данные из базы при первом обращении и кэширует их в памяти.
class DataProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  bool _initialized = false;

  List<Spell> spells = [];
  List<Equipment> equipment = [];
  List<MagicItem> magicItems = [];
  List<Feat> feats = [];
  List<Race> races = [];

  Future<void> initialize() async {
    if (_initialized) return;
    spells = await _dbService.getAllSpells();
    equipment = await _dbService.getAllEquipment();
    magicItems = await _dbService.getAllMagicItems();
    feats = await _dbService.getAllFeats();
    races = await _dbService.getAllRaces();
    _initialized = true;
    notifyListeners();
  }

  List<Spell> searchSpells({String query = '', int? level, String? school}) {
    return spells.where((spell) {
      final matchQuery = query.isEmpty || spell.name.toLowerCase().contains(query.toLowerCase());
      final matchLevel = level == null || spell.level == level;
      final matchSchool = school == null || spell.school.toLowerCase() == school.toLowerCase();
      return matchQuery && matchLevel && matchSchool;
    }).toList();
  }

  List<Equipment> searchEquipment({String query = '', String? type}) {
    return equipment.where((eq) {
      final matchQuery = query.isEmpty || eq.name.toLowerCase().contains(query.toLowerCase());
      final matchType = type == null || eq.type.toLowerCase() == type.toLowerCase();
      return matchQuery && matchType;
    }).toList();
  }
}