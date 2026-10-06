import 'package:flutter/material.dart';

/// Colours for the pad, in one place so the two surfaces cannot drift apart.
///
/// Deliberately the same values as `HomePalette.background` and
/// gamypad_pc's `GamepadTestPalette`: the PC's test pad was styled to read as
/// this one, and now that the geometry lives in a model the two halves really
/// are the same device. Duplicated rather than shared across packages, because
/// the three surfaces are separate features and a common theme is a later
/// concern than getting the input path right.
abstract final class PadPalette {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1C1C1E);
  static const surfacePressed = Color(0xFF3A3A3C);
  static const border = Colors.white10;
  static const borderPressed = Colors.white24;
  static const label = Colors.white60;
  static const labelPressed = Colors.white;

  /// A button that is present but inert, because the pad is not connected.
  static const disabled = Colors.white24;

  static const stickWell = Color(0xFF111111);
  static const stickRing = Color(0xFF4DA6FF);

  /// Analog level fill. Deliberately not the stick blue, so a trigger reading is
  /// never mistaken for a stick position.
  static const analogFill = Color(0xFF00FF88);
  static const analogTrack = Color(0xFF1C1C1E);

  // Editor only. Nothing on the play surface uses these, so a stray accent can
  // never be mistaken for a selected element while the pad is being played.
  static const selection = Color(0xFF00FF88);
  static const invalid = Color(0xFFFF5252);
  static const stage = Color(0xFF141414);
}
