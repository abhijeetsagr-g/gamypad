import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_button.dart';
import 'package:protocol/protocol.dart';

/// SELECT, START, LS and RS — the middle block, in the controller's two rows.
class TestCenterButtons extends StatelessWidget {
  const TestCenterButtons({super.key, required this.onChanged});

  final void Function(GamepadButton button, bool pressed) onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(GamepadButton button, String label) => TestButton(
      label: label,
      width: 100,
      height: 40,
      onChanged: (pressed) => onChanged(button, pressed),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn(GamepadButton.SELECT, 'Select'),
            const SizedBox(width: 10),
            btn(GamepadButton.START, 'Start'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn(GamepadButton.LS, 'LS'),
            const SizedBox(width: 10),
            btn(GamepadButton.RS, 'RS'),
          ],
        ),
      ],
    );
  }
}