import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/character_provider.dart';
import '../services/localization.dart';

/// Экран отслеживания боя. Позволяет управлять текущими очками
/// здоровья каждого персонажа и отображает инициативу и состояния.
/// Пока реализован только простой счётчик ХП.
class CombatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        final characters = provider.characters;
        if (characters.isEmpty) {
          return Center(child: Text(loc.translate('no_character')));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final c = characters[index];
            return Card(
              child: ListTile(
                title: Text(c.name),
                subtitle: Text('${loc.translate('hit_points')}: ${c.currentHp}/${c.maxHp}${c.tempHp > 0 ? ' +${c.tempHp}' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => provider.adjustHp(c, -1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => provider.adjustHp(c, 1),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}