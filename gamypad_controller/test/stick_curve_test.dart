import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/input/stick_curve.dart';
import 'package:protocol/protocol.dart';

void main() {
  const curve = StickCurve();

  ({int x, int y}) at(double dx, double dy) => curve.apply(dx, dy);

  group('origin', () {
    test('at rest is exactly centre, not approximately', () {
      expect(at(0, 0), (x: stickCenter, y: stickCenter));
    });

    test('inside the deadzone is centre', () {
      expect(at(curve.max * 0.05, 0), (x: stickCenter, y: stickCenter));
    });

    test('just past the deadzone has moved', () {
      expect(at(curve.max * 0.5, 0).x, greaterThan(0));
    });
  });

  group('deadzone', () {
    test('is a circle, so off-axis rest is centred too', () {
      // Per-axis testing would let this through as a square corner.
      final diagonal = curve.max * 0.06;

      expect(at(diagonal, diagonal), (x: stickCenter, y: stickCenter));
    });

    test('a diagonal outside it is not centred', () {
      final diagonal = curve.max * 0.3;

      expect(at(diagonal, diagonal).x, greaterThan(0));
      expect(at(diagonal, diagonal).y, greaterThan(0));
    });
  });

  group('clamping', () {
    test('a drag past the travel limit stops at full deflection', () {
      expect(
        at(curve.max * 5, 0).x,
        at(curve.max, 0).x,
        reason: 'clamped, not extrapolated',
      );
    });

    test('never exceeds the protocol range', () {
      // The widget's own arithmetic being slightly wrong must not become an
      // out-of-range message that the PC rejects.
      final far = at(curve.max * 100, curve.max * 100);

      expect(far.x, lessThanOrEqualTo(stickMax));
      expect(far.y, lessThanOrEqualTo(stickMax));
      expect(
        at(-curve.max * 100, -curve.max * 100).x,
        greaterThanOrEqualTo(stickMin),
      );
    });

    test('preserves direction when clamping, rather than squaring', () {
      final corner = at(curve.max * 4, curve.max * 4);

      expect(
        corner.x / stickMax,
        closeTo(corner.y / stickMax, 1e-6),
        reason: 'a diagonal stays diagonal',
      );
    });
  });

  group('response curve', () {
    test('is quadratic: half travel gives less than half output', () {
      expect(at(curve.max * 0.5, 0).x, lessThan(stickMax * 0.5));
    });

    test('is monotonic, so no movement is unreachable', () {
      var previous = 0;
      for (var step = 1; step <= 10; step++) {
        final value = at(curve.max * step / 10, 0).x;

        expect(value, greaterThan(previous), reason: 'at $step/10 of travel');
        previous = value;
      }
    });

    test('reaches full deflection exactly at the travel limit', () {
      expect(at(curve.max, 0).x, stickMax);
      expect(at(0, curve.max).y, stickMax);
    });
  });

  group('sign', () {
    test('negative axes come out negative, so `pow` never sees one', () {
      // `math.pow(-0.8, 2.0)` would be NaN and reach the wire as such.
      final corner = at(-curve.max * 0.8, -curve.max * 0.8);

      expect(corner.x, lessThan(0));
      expect(corner.y, lessThan(0));
    });

    test('is symmetric about the origin', () {
      final point = at(curve.max * 0.6, -curve.max * 0.3);
      final mirrored = at(-curve.max * 0.6, curve.max * 0.3);

      expect(mirrored.x, -point.x);
      expect(mirrored.y, -point.y);
    });

    test('a diagonal has both axes scaled equally', () {
      expect(
        at(curve.max * 0.7, curve.max * 0.7).x,
        at(curve.max * 0.7, curve.max * 0.7).y,
      );
    });
  });

  group('tuning', () {
    test('a larger max ramps more gently', () {
      const gentle = StickCurve(max: 260.0);

      expect(gentle.apply(130, 0).x, lessThan(curve.apply(130, 0).x));
    });

    test('gamma 1.0 leaves a linear ramp', () {
      const linear = StickCurve(gamma: 1.0);

      expect(linear.apply(linear.max * 0.5, 0).x, closeTo(stickMax * 0.5, 1));
    });

    test('a wider deadzone ignores more of the travel', () {
      const wide = StickCurve(deadzone: 0.3);

      expect(wide.apply(curve.max * 0.2, 0).x, stickCenter);
      expect(curve.apply(curve.max * 0.2, 0).x, greaterThan(0));
    });
  });

  group('totality', () {
    test('every position on a sweep yields an in-range message', () {
      // The guard the deadzone and the clamp exist for, checked across the
      // whole input space rather than case by case.
      for (var dx = -400.0; dx <= 400.0; dx += 7) {
        for (var dy = -400.0; dy <= 400.0; dy += 7) {
          final point = curve.apply(dx, dy);

          expect(
            point.x,
            inInclusiveRange(stickMin, stickMax),
            reason: 'x at $dx,$dy',
          );
          expect(
            point.y,
            inInclusiveRange(stickMin, stickMax),
            reason: 'y at $dx,$dy',
          );
        }
      }
    });
  });
}
