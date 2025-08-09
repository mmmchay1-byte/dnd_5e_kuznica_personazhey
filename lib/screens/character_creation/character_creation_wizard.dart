import 'package:dnd_5e_kuznica_personazhey/utils/text_theme_compat.dart';
import 'package:flutter/material.dart';
import '../utils/text_theme_compat.dart';

import '../../models/race.dart';
import '../../models/character_class.dart';
import '../../models/character.dart';
import '../../services/localization.dart';

/// Мастер создания персонажа. Пошагово собирает информацию о
/// расе, классе, характеристиках, имени и других параметрах. После
/// завершения вызывает обратный вызов `onCharacterCreated`.
class CharacterCreationWizard extends StatefulWidget {
  final List<Race> races;
  final List<CharacterClass> classes;
  final void Function(Character) onCharacterCreated;
  const CharacterCreationWizard({
    super.key,
    required this.races,
    required this.classes,
    required this.onCharacterCreated,
  });

  @override
  State<CharacterCreationWizard> createState() => _CharacterCreationWizardState();
}

class _CharacterCreationWizardState extends State<CharacterCreationWizard> {
  int _step = 0;
  Race? _selectedRace;
  CharacterClass? _selectedClass;
  Map<String, int> _abilityScores = {
    'Сила': 15,
    'Ловкость': 14,
    'Телосложение': 13,
    'Интеллект': 12,
    'Мудрость': 10,
    'Харизма': 8,
  };
  String _characterName = '';
  int _level = 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    List<Widget> pages = [
      _buildRaceSelection(loc),
      _buildClassSelection(loc),
      _buildStatsSelection(loc),
      _buildNameAndLevel(loc),
      _buildSummary(loc),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('character_creation')),
      ),
      body: pages[_step],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _step > 0 ? () => setState(() => _step--) : null,
              child: Text(loc.translate('back')),
            ),
            TextButton(
              onPressed: _canProceed() ? () => setState(() => _step++) : null,
              child: Text(_step == pages.length - 1 ? loc.translate('finish') : loc.translate('next')),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_step == 0) return _selectedRace != null;
    if (_step == 1) return _selectedClass != null;
    if (_step == 2) return true;
    if (_step == 3) return _characterName.isNotEmpty;
    if (_step == 4) return true;
    return false;
  }

  Widget _buildRaceSelection(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.translate('choose_race'), style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 8),
        ...widget.races.map((race) => RadioListTile<Race>(
              title: Text(race.name),
              subtitle: Text(race.description),
              value: race,
              groupValue: _selectedRace,
              onChanged: (value) => setState(() => _selectedRace = value),
            )),
      ],
    );
  }

  Widget _buildClassSelection(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.translate('choose_class'), style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 8),
        ...widget.classes.map((cls) => RadioListTile<CharacterClass>(
              title: Text(cls.name),
              subtitle: Text(loc.translate('hit_die') + ': d${cls.hitDie}'),
              value: cls,
              groupValue: _selectedClass,
              onChanged: (value) => setState(() => _selectedClass = value),
            )),
      ],
    );
  }

  Widget _buildStatsSelection(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.translate('assign_stats'), style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 8),
        ..._abilityScores.keys.map((ability) => Row(
              children: [
                Expanded(flex: 2, child: Text(ability)),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: _abilityScores[ability].toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final val = int.tryParse(value) ?? 10;
                      setState(() => _abilityScores[ability] = val);
                    },
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildNameAndLevel(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.translate('name_and_level'), style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(labelText: loc.translate('character_name')),
          onChanged: (value) => _characterName = value,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(loc.translate('level') + ':'),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _level,
              items: List.generate(20, (i) => i + 1)
                  .map((lvl) => DropdownMenuItem(value: lvl, child: Text('$lvl')))
                  .toList(),
              onChanged: (value) => setState(() => _level = value ?? 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary(AppLocalizations loc) {
    final race = _selectedRace;
    final cls = _selectedClass;
    if (race == null || cls == null) {
      return Center(child: Text(loc.translate('incomplete')));
    }
    final tempCharacter = Character(
      id: -1,
      name: _characterName,
      race: race,
      characterClass: cls,
      level: _level,
      abilityScores: _abilityScores,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('summary'), style: Theme.of(context).textTheme.headline6),
          const SizedBox(height: 8),
          Text('${loc.translate('name')}: ${tempCharacter.name}'),
          Text('${loc.translate('race')}: ${race.name}'),
          Text('${loc.translate('class_label')}: ${cls.name}'),
          Text('${loc.translate('level')}: ${tempCharacter.level}'),
          const SizedBox(height: 8),
          Text(loc.translate('abilities')), const SizedBox(height: 4),
          ...tempCharacter.abilityScores.entries.map((e) => Text('${e.key}: ${e.value} ( ${tempCharacter.getAbilityMod(e.key) >= 0 ? '+' : ''}${tempCharacter.getAbilityMod(e.key)} )')),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Создаём персонажа с временным id (id будет перезаписан при сохранении в БД).
                widget.onCharacterCreated(tempCharacter);
                Navigator.pop(context);
              },
              child: Text(loc.translate('create_character')),
            ),
          ),
        ],
      ),
    );
  }
}
