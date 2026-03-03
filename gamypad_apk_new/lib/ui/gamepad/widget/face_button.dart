import 'package:flutter/material.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/gamepad_button.dart';

class FaceButton extends StatelessWidget {
  const FaceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60),
        Column(
          children: [
            // Y on top
            GamepadButton(btnName: "Y", width: 100, height: 60, btnCode: "Y"),
            SizedBox(height: 10),
            // X left + B right
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GamepadButton(
                  btnName: "X",
                  width: 100,
                  height: 60,
                  btnCode: "X",
                ),
                SizedBox(width: 60),
                GamepadButton(
                  btnName: "B",
                  width: 100,
                  height: 60,
                  btnCode: "B",
                ),
              ],
            ),
            SizedBox(height: 10),
            // A bottom
            GamepadButton(btnName: "A", width: 100, height: 60, btnCode: "A"),
          ],
        ),
      ],
    );
  }
}
