import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_button.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';
import 'package:protocol/protocol.dart';

class PadDpad extends StatelessWidget {
  const PadDpad({super.key, required this.onChanged, this.enabled = true});

  final void Function(GamepadButton button, bool pressed)? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;

        Widget arm(GamepadButton button, String glyph) => Expanded(
          child: PadButton(
            label: glyph,
            labelScale: 0.42,
            enabled: enabled,
            onChanged: onChanged == null
                ? null
                : (pressed) => onChanged!(button, pressed),
          ),
        );

        return Padding(
          padding: EdgeInsets.all(size * 0.05),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ColorPalette.stickWell,
              borderRadius: BorderRadius.circular(size * 0.12),
              border: Border.all(color: ColorPalette.border),
            ),
            child: Column(
              children: [
                arm(GamepadButton.UP, 'UP'),
                Expanded(flex: 1, child: const SizedBox.shrink()),
                Row(
                  children: [
                    arm(GamepadButton.LEFT, 'LEFT'),
                    Expanded(flex: 1, child: const SizedBox.shrink()),
                    arm(GamepadButton.RIGHT, 'RIGHT'),
                  ],
                ),
                Expanded(flex: 1, child: const SizedBox.shrink()),
                arm(GamepadButton.DOWN, 'DOWN'),
              ],
            ),
          ),
        );
      },
    );
  }
}
