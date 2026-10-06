import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_button.dart';
import 'package:protocol/protocol.dart';

/// The four directions as independent buttons, in the controller's cross layout.
///
/// Each is a separate [GamepadButton], so holding UP and clicking RIGHT emits
/// two presses. `UinputDevice` combines them into a single hat position — which
/// is exactly the diagonal behaviour worth verifying here.
class TestDpad extends StatelessWidget {
  const TestDpad({super.key, required this.onChanged});

  final void Function(GamepadButton button, bool pressed) onChanged;

  static const _w = 120.0;
  static const _h = 40.0;

  @override
  Widget build(BuildContext context) {
    Widget dir(GamepadButton button, String glyph) => TestButton(
      // The controller leaves these blank for touch, but a mouse-driven test
      // surface needs to show what is where.
      label: glyph,
      width: _w,
      height: _h,
      onChanged: (pressed) => onChanged(button, pressed),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dir(GamepadButton.UP, '▲'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dir(GamepadButton.LEFT, '◀'),
            const SizedBox(width: 40),
            dir(GamepadButton.RIGHT, '▶'),
          ],
        ),
        dir(GamepadButton.DOWN, '▼'),
      ],
    );
  }
}