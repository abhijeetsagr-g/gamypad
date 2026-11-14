import 'package:flutter/material.dart';

abstract final class ColorPalette {
  static const background = Color(0xFF181617);

  static const accent = Color(0xFF8FAF9F);
  static const waiting = Color(0xFFB09A72);

  static const danger = Color(0xFFB71C1C);
  static const text = Color(0xFFE6E6E6);
  static const muted = Color(0xFF858585);

  static final dangerSurface = danger.withValues(alpha: 0.18);

  static const surface = Color(0xFF1C1C1E);
  static const border = Colors.white10;
  static const label = Colors.white60;
  static const invalid = Color(0xFFFF5252);
}

abstract class AppTheme {
  static ThemeData get myTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorPalette.background,
    primaryColor: ColorPalette.accent,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPalette.background,
      foregroundColor: ColorPalette.text,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: ColorPalette.accent,
      secondary: ColorPalette.accent,
      surface: ColorPalette.background,
      error: ColorPalette.invalid,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorPalette.accent,
      selectionColor: ColorPalette.accent.withValues(alpha: 0.3),
      selectionHandleColor: ColorPalette.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorPalette.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: ColorPalette.muted, fontSize: 13),
      floatingLabelStyle: const TextStyle(
        color: ColorPalette.accent,
        fontSize: 13,
      ),
      helperStyle: const TextStyle(color: ColorPalette.muted, fontSize: 12),
      errorStyle: const TextStyle(color: ColorPalette.invalid, fontSize: 12),
      border: _fieldBorder(ColorPalette.border),
      enabledBorder: _fieldBorder(ColorPalette.border),
      focusedBorder: _fieldBorder(ColorPalette.accent),
      errorBorder: _fieldBorder(ColorPalette.invalid),
      focusedErrorBorder: _fieldBorder(ColorPalette.invalid),
    ),
  );

  static OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: color),
  );
}
