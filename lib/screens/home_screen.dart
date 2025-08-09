import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd_5e_kuznica_personazhey/models/character_class.dart';
import '../providers/data_provider.dart';
import '../providers/character_provider.dart';
import '../services/localization.dart';
import 'character_sheet_screen.dart';
import 'inventory_screen.dart';
import 'spells_screen.dart';
import 'combat_screen.dart';
import 'settings_screen.dart';
import 'character_creation/character_creation_wizard.dart';

/// Главный экран приложения. Содержит нижнюю навигацию и
/// переключение между основными разделами: Обзор персонажа,
/// Инвентарь, Заклинания, Бой и Настройки. В правом нижнем углу
/// отображается кнопка добавления нового персонажа.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tabs = [
      CharacterSheetScreen(),
      InventoryScreen(),
      SpellsScreen(),
      CombatScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: loc.translate('tab_overview'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: loc.translate('tab_inventory'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_stories),
            label: loc.translate('tab_spells'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_kabaddi),
            label: loc.translate('tab_combat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: loc.translate('tab_settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Открываем мастер создания персонажа.
          final dataProvider = context.read<DataProvider>();
          final characterProvider = context.read<CharacterProvider>();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CharacterCreationWizard(
                races: dataProvider.races,
                classes: predefinedClasses,
                onCharacterCreated: (character) async {
                  await characterProvider.addCharacter(character);
                },
              ),
            ),
          );
        },
        tooltip: loc.translate('tooltip_add_character'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
