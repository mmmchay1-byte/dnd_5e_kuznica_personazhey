import 'package:flutter/material.dart';

/// Provider, управляющий выбором темы. Пользователь может включать
/// тёмный режим через настройки.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}