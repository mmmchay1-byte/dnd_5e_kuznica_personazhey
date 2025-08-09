import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/equipment.dart';
import '../models/magic_item.dart';
import '../providers/character_provider.dart';
import '../providers/data_provider.dart';
import '../services/localization.dart';

/// Экран управления инвентарём. Показывает список предметов,
/// экипированных у текущего персонажа, позволяет добавлять новое
/// снаряжение и магические предметы, а также удалять их. Расчёт
/// веса производится автоматически.
class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer2<CharacterProvider, DataProvider>(
      builder: (context, charProvider, dataProvider, _) {
        final character = charProvider.current;
        if (character == null) {
          return Center(
            child: Text(loc.translate('no_character')),
          );
        }
        // Собираем списки экипировки и магических предметов по идентификаторам.
        final equipment = character.equipmentIds
            .map((id) => dataProvider.equipment.firstWhere((e) => e.id == id, orElse: () => Equipment(id: id, name: '???', type: '', subType: '', cost: '', weight: 0, description: '', properties: {})))
            .toList();
        final magicItems = character.magicItemIds
            .map((id) => dataProvider.magicItems.firstWhere((m) => m.id == id, orElse: () => MagicItem(id: id, name: '???', type: '', rarity: '', requiresAttunement: false, description: '', bonuses: {})))
            .toList();
        final totalWeight = equipment.fold<double>(0.0, (sum, item) => sum + item.weight);
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('inventory'), style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 8),
                Text('${loc.translate('total_weight')}: ${totalWeight.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      if (equipment.isNotEmpty)
                        ExpansionTile(
                          title: Text(loc.translate('equipment')),
                          children: equipment.map((e) => ListTile(
                                title: Text(e.name),
                                subtitle: Text('${e.weight} • ${e.cost}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    charProvider.removeEquipmentFromCurrent(e.id);
                                  },
                                ),
                              )).toList(),
                        ),
                      if (magicItems.isNotEmpty)
                        ExpansionTile(
                          title: Text(loc.translate('magic_items')),
                          children: magicItems.map((m) => ListTile(
                                title: Text(m.name),
                                subtitle: Text(m.rarity),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    charProvider.removeMagicItemFromCurrent(m.id);
                                  },
                                ),
                              )).toList(),
                        ),
                      if (equipment.isEmpty && magicItems.isEmpty)
                        Center(child: Text(loc.translate('empty_inventory'))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _openAddItemSheet(context, charProvider, dataProvider, loc);
            },
            label: Text(loc.translate('add_item')),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _openAddItemSheet(BuildContext context, CharacterProvider charProvider, DataProvider dataProvider, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = '';
        int selectedTab = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredEquipment = dataProvider.equipment.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
            final filteredMagicItems = dataProvider.magicItems.where((m) => m.name.toLowerCase().contains(query.toLowerCase())).toList();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DefaultTabController(
                length: 2,
                initialIndex: selectedTab,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      onTap: (index) => setState(() => selectedTab = index),
                      tabs: [
                        Tab(text: loc.translate('equipment')),
                        Tab(text: loc.translate('magic_items')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: loc.translate('search'),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value) => setState(() => query = value),
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ListView.builder(
                            itemCount: filteredEquipment.length,
                            itemBuilder: (context, index) {
                              final item = filteredEquipment[index];
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Text('${item.weight} • ${item.cost}'),
                                onTap: () {
                                  charProvider.addEquipmentToCurrent(item.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                          ListView.builder(
                            itemCount: filteredMagicItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredMagicItems[index];
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Text(item.rarity),
                                onTap: () {
                                  charProvider.addMagicItemToCurrent(item.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ],
                      ),
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