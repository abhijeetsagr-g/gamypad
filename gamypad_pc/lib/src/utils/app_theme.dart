import 'package:flutter/material.dart';

abstract final class ColorPalette {
  static const background = Color(0xFF181617);

  static const accent = Color(0xFF8FAF9F);
  static const waiting = Color(0xFFB09A72);

  static const danger = Color(0xFFB71C1C);
  static const text = Color(0xFFE6E6E6);
  static const muted = Color(0xFF858585);

  static final dangerSurface = danger.withValues(alpha: 0.18);
}

abstract class AppTheme {
  ThemeData get myTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorPalette.background,
    primaryColor: ColorPalette.accent,
    appBarTheme: AppBarTheme(backgroundColor: ColorPalette.background),
  );
}
