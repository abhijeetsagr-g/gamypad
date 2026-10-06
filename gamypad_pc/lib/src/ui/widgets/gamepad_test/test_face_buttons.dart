import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_button.dart';
import 'package:protocol/protocol.dart';

/// A, B, X and Y in the controller's diamond: Y on top, X and B across the
/// middle, A at the bottom.
class TestFaceButtons extends StatelessWidget {
  const TestFaceButtons({super.key, required this.onChanged});

  final void Function(GamepadButton button, bool pressed) onChanged;

  static const _w = 100.0;
  static const _h = 60.0;

  @override
  Widget build(BuildContext context) {
    Widget face(GamepadButton button) => TestButton(
      label: button.name,
      width: _w,
      height: _h,
      onChanged: (pressed) => onChanged(button, pressed),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 60),
        face(GamepadButton.Y),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            face(GamepadButton.X),
            const SizedBox(width: 60),
            face(GamepadButton.B),
          ],
        ),
        const SizedBox(height: 10),
        face(GamepadButton.A),
      ],
    );
  }
}