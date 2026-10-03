import 'package:flutter/material.dart';

/// Colours for the home screen, in one place so the status dot, the QR hint and
/// the toggle button cannot drift apart.
abstract final class HomePalette {
  static const background = Color(0xFF0D0D0D);
  static const accent = Color(0xFF00FF88);
  static const waiting = Colors.orange;
  static const dim = Colors.white24;
  static const muted = Colors.white38;
  static const danger = Colors.redAccent;
  static const dangerSurface = Color(0x3DB71C1C);
  static const dangerBorder = Color(0xFFB71C1C);
  static const stopSurface = Color(0xFFB71C1C);
}
