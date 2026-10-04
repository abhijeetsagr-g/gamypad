import 'dart:math' as math;

import 'package:protocol/protocol.dart';

class StickCurve {
  /// How far the thumb may travel from centre, in the caller's units.
  final double max;

  /// Radius, as a fraction of travel, within which the stick reads as centred.
  final double deadzone;

  /// Set below 1.0 to give fine control near centre at the cost of reaching full
  /// deflection sooner. Above 1.0 does the opposite. 2.0 is quadratic.
  final double gamma;

  const StickCurve({this.max = 130.0, this.deadzone = 0.1, this.gamma = 2.0});

  /// Maps a thumb at [dx], [dy] from centre to protocol units.
  ({int x, int y}) apply(double dx, double dy) {
    final distance = math.sqrt(dx * dx + dy * dy);
    var x = dx;
    var y = dy;
    if (distance > max && distance > 0) {
      final scale = max / distance;
      x *= scale;
      y *= scale;
    }

    x /= max;
    y /= max;

    if (math.sqrt(x * x + y * y) < deadzone) {
      return (x: stickCenter, y: stickCenter);
    }

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
