import 'package:flutter/material.dart';

abstract final class ColorPalette {
  static const background = Color(0xFF181617);

  static const accent = Color(0xFF8FAF9F);
  static const waiting = Color(0xFFB09A72);

  static const danger = Color(0xFFB71C1C);
  static const text = Color(0xFFE6E6E6);
  static const muted = Color(0xFF858585);
  static const dim = Colors.white24;

  static final dangerSurface = danger.withValues(alpha: 0.18);

  static const surfacePressed = Color(0xFF3A3A3C);
  static const border = Colors.white10;
  static const borderPressed = Colors.white24;
  static const label = Colors.white60;
  static const labelPressed = Colors.white;

  static const stickWell = Color(0xFF111111);
  static const stickRing = accent;

  static const analogFill = Color(0xFF00FF88);
  static const analogTrack = Color(0xFF1C1C1E);
  static const selection = Color(0xFF00FF88);
  static const invalid = Color(0xFFFF5252);
  static const stage = Color(0xFF141414);
}

abstract class AppTheme {
  static ThemeData get myTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorPalette.background,
    primaryColor: ColorPalette.accent,
    appBarTheme: AppBarTheme(backgroundColor: ColorPalette.background),
  );
}
