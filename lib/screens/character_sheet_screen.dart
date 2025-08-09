import 'package:dnd_5e_kuznica_personazhey/utils/text_theme_compat.dart';
import '../utils/text_theme_compat.dart';

import 'package:provider/provider.dart';

import '../providers/character_provider.dart';
import '../services/localization.dart';

/// Экран обзора персонажа. Если активный персонаж отсутствует,
/// выводит приглашение создать нового. Иначе отображает основные
/// характеристики: имя, раса, класс, уровень, характеристики,
/// модификаторы, ХП, КД, скорость и бонус мастерства.
class CharacterSheetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        final character = provider.current;
        if (character == null) {
          return Center(
            child: Text(loc.translate('no_character')),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text('${character.race.name} — ${character.characterClass.name}, ${loc.translate('level')} ${character.level}'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('abilities'), style: Theme.of(context).textTheme.subtitle1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: character.abilityScores.keys.map((ability) {
                          final score = character.abilityScores[ability]!;
                          final mod = character.getAbilityMod(ability);
                          return Column(
                            children: [
                              Text(ability, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('$score ( ${mod >= 0 ? '+' : ''}$mod )'),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('defenses'), style: Theme.of(context).textTheme.subtitle1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(loc.translate('armor_class')), Text('${character.armorClass}')
                            ],
                          ),
                          Column(
                            children: [
                              Text(loc.translate('hit_points')),
                              Text('${character.currentHp}/${character.maxHp}${character.tempHp > 0 ? ' +${character.tempHp}' : ''}')
                            ],
                          ),
                          Column(
                            children: [
                              Text(loc.translate('speed')), Text('${character.movementSpeed}')
                            ],
                          ),
                          Column(
                            children: [
                              Text(loc.translate('proficiency_bonus')), Text('+${character.proficiencyBonus}')
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('saving_throws'), style: Theme.of(context).textTheme.subtitle1),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: character.abilityScores.keys.map((ability) {
                          final mod = character.savingThrow(ability);
                          return Chip(label: Text('$ability: ${mod >= 0 ? '+' : ''}$mod'));
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('features'), style: Theme.of(context).textTheme.subtitle1),
                      const SizedBox(height: 8),
                      ...character.characterClass.featuresByLevel.entries
                          .where((e) => e.key <= character.level)
                          .expand((e) => e.value)
                          .map((f) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text('• $f'),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
