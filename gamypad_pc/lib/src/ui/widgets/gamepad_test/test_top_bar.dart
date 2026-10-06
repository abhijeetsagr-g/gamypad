import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/analog_trigger.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_button.dart';
import 'package:protocol/protocol.dart';

/// LT, LB, GUIDE, RB, RT across the top, matching the controller's top bar.
///
/// The two triggers are analog; the three shoulder/centre buttons are not. That
/// split is the reason [AnalogTrigger] exists as its own widget.
class TestTopBar extends StatelessWidget {
  const TestTopBar({
    super.key,
    required this.onButton,
    required this.onTrigger,
  });

  final void Function(GamepadButton button, bool pressed) onButton;
  final void Function(GamepadTrigger trigger, int value) onTrigger;

  @override
  Widget build(BuildContext context) {
    Widget btn(GamepadButton button, String label, double width) => TestButton(
      label: label,
      width: width,
      height: 40,
      onChanged: (pressed) => onButton(button, pressed),
    );

    Widget trigger(GamepadTrigger trigger, double width) => AnalogTrigger(
      label: trigger.name,
      width: width,
      onChanged: (value) => onTrigger(trigger, value),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        trigger(GamepadTrigger.LT, 160),
        const SizedBox(width: 10),
        btn(GamepadButton.LB, 'LB', 140),
        const SizedBox(width: 20),
        btn(GamepadButton.GUIDE, 'Guide', 120),
        const SizedBox(width: 20),
        btn(GamepadButton.RB, 'RB', 140),
        const SizedBox(width: 10),
        trigger(GamepadTrigger.RT, 160),
      ],
    );
  }
}