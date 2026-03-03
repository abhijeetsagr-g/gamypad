import 'package:flutter/material.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/gamepad_button.dart';

class CenterButtons extends StatelessWidget {
  const CenterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GamepadButton(
              btnName: "Back",
              width: 100,
              height: 40,
              btnCode: "SELECT",
            ),
            SizedBox(width: 10),
            GamepadButton(
              btnName: "Start",
              width: 100,
              height: 40,
              btnCode: "START",
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            GamepadButton(btnName: "LS", width: 100, height: 40, btnCode: "LS"),
            SizedBox(width: 10),
            GamepadButton(btnName: "RS", width: 100, height: 40, btnCode: "RS"),
          ],
        ),
      ],
    );
  }
}
