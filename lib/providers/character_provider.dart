import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/race.dart';
import '../models/character_class.dart';
import '../services/database_service.dart';

/// Provider, управляющий активным персонажем, списком сохранённых
/// персонажей и действиями над ними (создание, обновление, удаление).
class CharacterProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final List<Character> _characters = [];
  Character? _current;

  List<Character> get characters => List.unmodifiable(_characters);
  Character? get current => _current;

  /// Загружает персонажей из базы данных.
  Future<void> loadCharacters(List<Race> races, List<CharacterClass> classes) async {
    _characters.clear();
    final loaded = await _dbService.getAllCharacters(races, classes);
    _characters.addAll(loaded);
    if (_current == null && _characters.isNotEmpty) {
      _current = _characters.first;
    }
    notifyListeners();
  }

  void selectCharacter(Character character) {
    _current = character;
    notifyListeners();
  }

  Future<void> addCharacter(Character character) async {
    final id = await _dbService.insertCharacter(character);
    character.id = id;
    _characters.add(character);
    _current = character;
    notifyListeners();
  }

  /// Обновляет ХП персонажа (используется в трекере боя).
  void adjustHp(Character character, int delta) {
    character.currentHp = (character.currentHp + delta).clamp(0, character.maxHp);
    notifyListeners();
  }

  /// Добавляет снаряжение к текущему персонажу.
  void addEquipmentToCurrent(int equipmentId) {
    if (_current == null) return;
    if (!_current!.equipmentIds.contains(equipmentId)) {
      _current!.equipmentIds.add(equipmentId);
      notifyListeners();
    }
  }

  /// Удаляет снаряжение у текущего персонажа.
  void removeEquipmentFromCurrent(int equipmentId) {
    if (_current == null) return;
    _current!.equipmentIds.remove(equipmentId);
    notifyListeners();
  }

  /// Аналогичные методы для магических предметов.
  void addMagicItemToCurrent(int magicItemId) {
    if (_current == null) return;
    if (!_current!.magicItemIds.contains(magicItemId)) {
      _current!.magicItemIds.add(magicItemId);
      notifyListeners();
    }
  }

  void removeMagicItemFromCurrent(int magicItemId) {
    if (_current == null) return;
    _current!.magicItemIds.remove(magicItemId);
    notifyListeners();
  }
}