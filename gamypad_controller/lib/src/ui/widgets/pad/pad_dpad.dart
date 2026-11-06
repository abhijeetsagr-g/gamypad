import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_button.dart';
import 'package:protocol/protocol.dart';

class PadDpad extends StatelessWidget {
  const PadDpad({super.key, required this.onChanged, this.enabled = true});

  final void Function(GamepadButton button, bool pressed)? onChanged;
  final bool enabled;

  static const double _shrink = 0.88;


  static const double _armFraction = 0.40;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final shortest = w < h ? w : h;

        final armThickness = shortest * _armFraction;
        final taper = armThickness * 0.5;

        Widget arm(GamepadButton button, _DpadSide side) => Transform.scale(
              scale: _shrink,
              child: ClipPath(
                clipper: _PentagonClipper(side: side, taper: taper),
                child: Padding(
                  padding: EdgeInsets.all(shortest * 0.015),
                  child: PadButton(
                    label: '',
                    labelScale: 0.42,
                    enabled: enabled,
                    onChanged: onChanged == null
                        ? null
                        : (pressed) => onChanged!(button, pressed),
                  ),
                ),
              ),
            );

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: (w - armThickness) / 2,
              width: armThickness,
              height: h / 2,
              child: arm(GamepadButton.UP, _DpadSide.up),
            ),
            Positioned(
              bottom: 0,
              left: (w - armThickness) / 2,
              width: armThickness,
              height: h / 2,
              child: arm(GamepadButton.DOWN, _DpadSide.down),
            ),
            Positioned(
              left: 0,
              top: (h - armThickness) / 2,
              width: w / 2,
              height: armThickness,
              child: arm(GamepadButton.LEFT, _DpadSide.left),
            ),
            Positioned(
              right: 0,
              top: (h - armThickness) / 2,
              width: w / 2,
              height: armThickness,
              child: arm(GamepadButton.RIGHT, _DpadSide.right),
            ),
          ],
        );
      },
    );
  }
}

enum _DpadSide { up, down, left, right }

class _PentagonClipper extends CustomClipper<Path> {
  const _PentagonClipper({required this.side, required this.taper});

  final _DpadSide side;
  final double taper;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    switch (side) {
      case _DpadSide.up:
        path
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w, h - taper)
          ..lineTo(w / 2, h)
          ..lineTo(0, h - taper);
        break;

      case _DpadSide.down:
        path
          ..moveTo(0, h)
          ..lineTo(w, h)
          ..lineTo(w, taper)
          ..lineTo(w / 2, 0)
          ..lineTo(0, taper);
        break;

      case _DpadSide.left:
        path
          ..moveTo(0, 0)
          ..lineTo(w - taper, 0)
          ..lineTo(w, h / 2)
          ..lineTo(w - taper, h)
          ..lineTo(0, h);
        break;

      case _DpadSide.right:
        path
          ..moveTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(taper, h)
          ..lineTo(0, h / 2)
          ..lineTo(taper, 0);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _PentagonClipper oldClipper) =>
      oldClipper.side != side || oldClipper.taper != taper;
}