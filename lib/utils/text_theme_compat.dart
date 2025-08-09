// lib/utils/text_theme_compat.dart
import 'package:flutter/material.dart';

// Совместимость M2 -> M3 (старые геттеры поверх новых полей)
extension TextThemeCompat on TextTheme {
  TextStyle? get subtitle1  => titleMedium;
  TextStyle? get subtitle2  => titleSmall;
  TextStyle? get headline6  => titleLarge;
  TextStyle? get headline5  => headlineSmall;
  TextStyle? get bodyText1  => bodyLarge;
  TextStyle? get bodyText2  => bodyMedium;
  TextStyle? get caption    => bodySmall;
  TextStyle? get button     => labelLarge;
  TextStyle? get overline   => labelSmall;
}
