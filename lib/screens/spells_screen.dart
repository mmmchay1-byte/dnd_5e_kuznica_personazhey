import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../services/localization.dart';
import '../models/spell.dart';

/// Экран списка заклинаний. Позволяет искать и фильтровать по уровню и
/// школе. В будущем здесь можно реализовать выбор и подготовку
/// заклинаний для конкретного персонажа.
class SpellsScreen extends StatefulWidget {
  @override
  State<SpellsScreen> createState() => _SpellsScreenState();
}

class _SpellsScreenState extends State<SpellsScreen> {
  String query = '';
  int? level;
  String? school;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final spells = dataProvider.searchSpells(query: query, level: level, school: school);
        final levels = List.generate(10, (i) => i);
        final schools = dataProvider.spells.map((s) => s.school).toSet().toList();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: loc.translate('search'),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() => query = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int?>(
                    value: level,
                    hint: Text(loc.translate('level_filter')),
                    items: [
                      DropdownMenuItem(value: null, child: Text(loc.translate('all_levels'))),
                      ...levels.map((lvl) => DropdownMenuItem(value: lvl, child: Text('$lvl')))
                    ],
                    onChanged: (value) => setState(() => level = value),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String?>(
                    value: school,
                    hint: Text(loc.translate('school_filter')),
                    items: [
                      DropdownMenuItem(value: null, child: Text(loc.translate('all_schools'))),
                      ...schools.map((sch) => DropdownMenuItem(value: sch, child: Text(sch)))
                    ],
                    onChanged: (value) => setState(() => school = value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    return ListTile(
                      title: Text(spell.name),
                      subtitle: Text('${loc.translate('level')} ${spell.level} • ${spell.school}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          _showSpellDetail(context, spell, loc);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpellDetail(BuildContext context, Spell spell, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(spell.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${loc.translate('level')}: ${spell.level}'),
              Text('${loc.translate('school')}: ${spell.school}'),
              const SizedBox(height: 8),
              Text('${loc.translate('casting_time')}: ${spell.castingTime}'),
              Text('${loc.translate('range')}: ${spell.range}'),
              Text('${loc.translate('components')}: ${spell.components}'),
              Text('${loc.translate('duration')}: ${spell.duration}'),
              const SizedBox(height: 8),
              Text(spell.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }
}