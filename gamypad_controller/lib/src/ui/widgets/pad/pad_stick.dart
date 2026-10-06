import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/input/stick_curve.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';
import 'package:protocol/protocol.dart';

class PadStick extends StatefulWidget {
  const PadStick({super.key, required this.onChanged, this.enabled = true});

  final void Function(int x, int y)? onChanged;
  final bool enabled;

  static const double thumbRatio = 0.42;
  static const double travelOvershoot = 1.3;

  @override
  State<PadStick> createState() => _PadStickState();
}

class _PadStickState extends State<PadStick> {
  Offset _thumb = Offset.zero;

  bool get _live => widget.onChanged != null && widget.enabled;

  /// The curve for the size actually rendered.
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
            color: ColorPalette.stickWell,
            border: Border.all(
              color: _live ? ColorPalette.stickRing : ColorPalette.border,
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
                  color: _live ? ColorPalette.stickRing : ColorPalette.dim,
                ),
              ),
            ),
          ),
        );

        if (!_live) return well;

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
