import 'package:flutter/material.dart';

/// Colours for the connect screen, in one place so the status dot, the field
/// outline, the error banner and the connect button cannot drift apart.
///
/// Deliberately the same values as gamypad_pc's `HomePalette`: the two screens
/// are read side by side during pairing, and a phone that looks like a
/// different product from the window showing the QR code makes the pairing
/// harder to follow than it needs to be.
abstract final class HomePalette {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const accent = Color(0xFF00FF88);
  static const waiting = Colors.orange;
  static const dim = Colors.white24;
  static const muted = Colors.white38;
  static const danger = Colors.redAccent;
  static const dangerSurface = Color(0x3DB71C1C);
  static const dangerBorder = Color(0xFFB71C1C);
}