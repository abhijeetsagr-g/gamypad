import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_button.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';
import 'package:protocol/protocol.dart';

/// The four directions as independent buttons inside one square.
///
/// Each direction is a separate [GamepadButton], so holding UP and pressing
/// RIGHT emits two presses and `UinputDevice` folds them into a diagonal hat —
/// which is the behaviour that has to survive a resize.
///
/// Arm thickness and the centre gap are both derived from the box, at a third
/// each. That is the whole reason for the group existing: hardcoded `120 × 40`
/// arms with a fixed 40px gap look right at exactly one size and distort into a
/// lopsided cross at every other.
///
/// A null [onChanged] means appearance only — see [PadButton].
class PadDpad extends StatelessWidget {
  const PadDpad({super.key, required this.onChanged, this.enabled = true});

  /// Emits the direction and whether it is pressed. Null disables input.
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
            // Arrows want more of the arm than a word does.
            labelScale: 0.42,
            enabled: enabled,
            onChanged: onChanged == null
                ? null
                : (pressed) => onChanged!(button, pressed),
          ),
        );

        return Padding(
          // A well behind the cross, and enough inset that the arms read as one
          // control rather than four buttons at small sizes.
          padding: EdgeInsets.all(size * 0.05),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: PadPalette.stickWell,
              borderRadius: BorderRadius.circular(size * 0.12),
              border: Border.all(color: PadPalette.border),
            ),
            child: Column(
              children: [
                arm(GamepadButton.UP, 'UP'),
                // The gap is the same third the arms are, which is what keeps
                // the cross from closing up as the group grows.
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
