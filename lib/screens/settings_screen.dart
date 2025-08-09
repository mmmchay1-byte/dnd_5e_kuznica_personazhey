import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/localization.dart';

/// Экран настроек. Пользователь может переключать тёмный режим
/// и менять другие параметры (будущие расширения).
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text(loc.translate('dark_mode')),
              subtitle: Text(loc.translate('dark_mode_desc')),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleDarkMode(value),
            ),
            // Можно добавить дополнительные настройки, например размер шрифта или
            // выбор языка, но русский язык по умолчанию.
          ],
        );
      },
    );
  }
}