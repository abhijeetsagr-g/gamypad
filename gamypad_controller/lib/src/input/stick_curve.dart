import 'dart:math' as math;

import 'package:protocol/protocol.dart';

class StickCurve {
  /// How far the thumb may travel from centre, in the caller's units.
  final double max;

  /// Radius, as a fraction of travel, within which the stick reads as centred.
  final double deadzone;

  final double gamma;

  const StickCurve({this.max = 130.0, this.deadzone = 0.1, this.gamma = 2.0});

  ({int x, int y}) apply(double dx, double dy) {
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return (x: stickCenter, y: stickCenter);

    // How far through the travel the thumb is, 0..1.
    final travel = distance < max ? distance / max : 1.0;
    if (travel < deadzone) return (x: stickCenter, y: stickCenter);

    final ux = dx / distance;
    final uy = dy / distance;

    // Unit direction on the circle -> same direction on the square's edge.
    final edge = math.max(ux.abs(), uy.abs());

    var x = (ux / edge) * travel;
    var y = (uy / edge) * travel;

    x = _shape(x);
    y = _shape(y);

    return (x: _toUnits(x), y: _toUnits(y));
  }

  /// Applies [gamma] to a normalised axis in `-1.0..1.0`.
  double _shape(double value) {
    final shaped = math.pow(value.abs(), gamma).toDouble();
    return value < 0 ? -shaped : shaped;
  }

  /// Truncates rather than rounds, deliberately.
  int _toUnits(double normalized) =>
      (normalized * stickMax).clamp(stickMin, stickMax).toInt();
}
