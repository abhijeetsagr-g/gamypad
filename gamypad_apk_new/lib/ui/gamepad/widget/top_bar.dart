import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/gamepad_button.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        GamepadButton(btnName: "LT", width: 160, height: 40, btnCode: "LT"),
        SizedBox(width: 10),
        GamepadButton(btnName: "LB", width: 140, height: 40, btnCode: "LB"),
        SizedBox(width: 20),
        GamepadButton(
          btnName: "Guide",
          width: 120,
          height: 40,
          btnCode: "GUIDE",
        ),
        SizedBox(width: 20),
        GamepadButton(btnName: "RB", width: 160, height: 40, btnCode: "RB"),
        SizedBox(width: 10),
        GamepadButton(btnName: "RT", width: 140, height: 40, btnCode: "RT"),
      ],
    );
  }
}
