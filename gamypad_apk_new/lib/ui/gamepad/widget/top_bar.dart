import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/gamepad_button.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btnH = height;
    final triggerW = 100.0;
    final bumperW = height * 2.5;
    final guideW = height * 1.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: LT + LB
        Row(
          children: [
            GamepadButton(
              btnName: 'LT',
              btnCode: 'LT',
              width: triggerW,
              height: btnH,
            ),
            const SizedBox(width: 4),
            GamepadButton(
              btnName: 'LB',
              btnCode: 'LB',
              width: bumperW,
              height: btnH,
            ),
          ],
        ),

        // Center: Guide
        GamepadButton(
          btnName: '⊙',
          btnCode: 'GUIDE',
          width: guideW,
          height: btnH,
        ),

        // Right: RB + RT
        Row(
          children: [
            GamepadButton(
              btnName: 'RB',
              btnCode: 'RB',
              width: bumperW,
              height: btnH,
            ),
            const SizedBox(width: 4),
            GamepadButton(
              btnName: 'RT',
              btnCode: 'RT',
              width: triggerW,
              height: btnH,
            ),
          ],
        ),
      ],
    );
  }
}
