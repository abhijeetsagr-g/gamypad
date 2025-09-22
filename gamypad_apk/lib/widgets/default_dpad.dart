import 'package:flutter/material.dart';
import 'package:gamypad_apk/widgets/gamepad_button.dart';

class DefaultDpad extends StatelessWidget {
  const DefaultDpad({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        GamepadButton(btnName: "", width: 120, height: 40, btnCode: "UP"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GamepadButton(btnName: "", width: 120, height: 40, btnCode: "LEFT"),
            SizedBox(width: 40),
            GamepadButton(
              btnName: "",
              width: 120,
              height: 40,
              btnCode: "RIGHT",
            ),
          ],
        ),
        GamepadButton(btnName: "", width: 120, height: 40, btnCode: "DOWN"),
      ],
    );
  }
}
