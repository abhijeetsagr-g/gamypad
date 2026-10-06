import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/input/stick_curve.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';
import 'package:protocol/protocol.dart';

/// A thumb stick in a square well.
///
/// Absolute rather than relative: the stick jumps to where the thumb lands, as on
/// a real pad. A relative stick has nothing under the thumb to grab, so a thumb
/// that lands slightly off-centre reads as the stick having slipped.
///
/// The proportions are gamypad_pc's `TestJoystick` — see [thumbRatio] and
/// [travelOvershoot] — so a stick tuned there feels the same here.
///
/// A null [onChanged] means appearance only — see [PadButton].
class PadStick extends StatefulWidget {
  const PadStick({super.key, required this.onChanged, this.enabled = true});

  /// Emits protocol units per axis. Null disables input.
  final void Function(int x, int y)? onChanged;

  final bool enabled;

  /// Thumb diameter as a fraction of the well's radius.
  static const double thumbRatio = 0.42;

  /// Travel reaches past the visible ring, so the thumb gets there before it
  /// saturates — otherwise the outer fifth of the well would be dead.
  static const double travelOvershoot = 1.3;

  @override
  State<PadStick> createState() => _PadStickState();
}

class _PadStickState extends State<PadStick> {
  Offset _thumb = Offset.zero;

  bool get _live => widget.onChanged != null && widget.enabled;

  /// The curve for the size actually rendered.
  ///
  /// This is the trap the design doc calls out: `StickCurve.max` defaults to
  /// `130.0` and is caller-supplied, and the old joystick normalised by its own
  /// `_maxDis` — so resizing a stick used to change how far the thumb had to
  /// travel to reach full deflection, and a cosmetic resize changed the feel.
  /// Deriving `max` from the rendered radius means the fraction of the well that
  /// reads as full deflection never moves.
  StickCurve curveFor(double radius) =>
      StickCurve(max: radius * PadStick.travelOvershoot);

  void _move(double radius, Offset local) {
    if (!_live) return;

    final curve = curveFor(radius);
    var offset = local - Offset(radius, radius);

    final limit = radius * PadStick.travelOvershoot;
    if (offset.distance > limit) {
      offset = Offset.fromDirection(offset.direction, limit);
    }

    setState(() => _thumb = offset);

    final point = curve.apply(offset.dx, offset.dy);
    widget.onChanged!(point.x, point.y);
  }

  /// Springs back to centre, as a real stick does when a thumb lifts.
  void _rest() {
    if (!_live) return;
    setState(() => _thumb = Offset.zero);
    widget.onChanged!(stickCenter, stickCenter);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final radius = constraints.biggest.shortestSide / 2;

        final well = DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PadPalette.stickWell,
            border: Border.all(
              color: _live ? PadPalette.stickRing : PadPalette.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Transform.translate(
              offset: _thumb,
              child: Container(
                width: radius * PadStick.thumbRatio * 2,
                height: radius * PadStick.thumbRatio * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _live ? PadPalette.stickRing : PadPalette.disabled,
                ),
              ),
            ),
          ),
        );

        if (!_live) return well;

        // Listener rather than a pan recognizer: the stick has to answer on
        // pointer down rather than after the arena decides the drag was a pan.
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _move(radius, event.localPosition),
          onPointerMove: (event) => _move(radius, event.localPosition),
          onPointerUp: (_) => _rest(),
          onPointerCancel: (_) => _rest(),
          child: well,
        );
      },
    );
  }
}
