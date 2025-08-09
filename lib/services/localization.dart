import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Простейший класс локализации, загружающий переводы из JSON/ARB.
///
/// Обычно локализации генерируются командой `flutter gen-l10n`. Но для
/// автономности проекта, который может использовать кастомные строки и
/// динамическую загрузку, мы реализуем класс вручную. Он ищет файл
/// `assets/l10n/intl_ru.arb` и сохраняет словарь переводов.
class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString('assets/l10n/intl_${locale.languageCode}.arb');
    final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}