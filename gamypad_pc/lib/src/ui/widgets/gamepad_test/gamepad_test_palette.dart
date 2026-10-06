import 'package:flutter/material.dart';

/// Styling for the testing ground, matching gamypad_controller's gamepad so the
/// two read as the same device.
///
/// `background` duplicates `HomePalette.background` on purpose: the two screens
/// are separate features, and a shared theme is a later concern than getting the
/// input path verified.
abstract final class GamepadTestPalette {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1C1C1E);
  static const surfacePressed = Color(0xFF3A3A3C);
  static const border = Colors.white10;
  static const borderPressed = Colors.white24;
  static const label = Colors.white60;
  static const labelPressed = Colors.white;

  static const stickWell = Color(0xFF111111);
  static const stickRing = Color(0xFF4DA6FF);

  /// Analog level fill. Deliberately not the stick blue, so a trigger reading
  /// is never mistaken for a stick position.
  static const analogFill = Color(0xFF00FF88);
  static const analogTrack = Color(0xFF1C1C1E);
}