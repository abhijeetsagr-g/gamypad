import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/input/trigger_curve.dart';
import 'package:protocol/protocol.dart';

void main() {
  const travel = 48.0;
  const curve = TriggerCurve(travel: travel);

  /// Thumb [distance] up from the resting edge.
  int at(double distance) => curve.apply(distance);

  group('rest', () {
    test('at the resting edge reads exactly triggerMin', () {
      expect(at(0), triggerMin);
    });

    test('inside the deadzone still reads triggerMin', () {
      expect(at(travel * curve.deadzone * 0.9), triggerMin);
    });

    test('below the resting edge does not go negative', () {
      expect(at(-travel), triggerMin);
    });
  });

  group('full travel', () {
    test('reading at exactly travel is triggerMax', () {
      expect(at(travel), triggerMax);
    });

    test('reading past travel saturates rather than overshoots', () {
      // A thumb can slide off the top of the element mid-gesture. Anything over
      // 255 would be rejected by the PC.
      expect(at(travel * 4), triggerMax);
      expect(at(travel * 1000), triggerMax);
    });

    test('never leaves the protocol range over the whole input space', () {
      for (var distance = -travel * 2; distance <= travel * 3; distance += 1) {
        expect(
          at(distance),
          inInclusiveRange(triggerMin, triggerMax),
          reason: 'at $distance',
        );
      }
    });
  });

  group('shape', () {
    test('is monotonic: no amount of travel is unreachable', () {
      var previous = -1;
      for (var step = 0; step <= 40; step++) {
        final value = at(travel * step / 40);

        expect(value, greaterThanOrEqualTo(previous), reason: 'at $step/40');
        previous = value;
      }
    });

    test('is linear, so the fill and the number are the same quantity', () {
      // The whole point against the PC's timed ramp: travel maps straight onto
      // pressure, not onto some eased curve. Checked above the deadzone, which
      // is the one deliberate departure and has its own test.
      const above = TriggerCurve(travel: travel, deadzone: 0);

      expect(above.apply(travel * 0.5), closeTo(triggerMax * 0.5, 1));
      expect(above.apply(travel * 0.25), closeTo(triggerMax * 0.25, 1));
      expect(above.apply(travel * 0.75), closeTo(triggerMax * 0.75, 1));
    });

    test('the default deadzone shifts the ramp, but keeps it straight', () {
      // Same slope everywhere, just starting a little further along.
      expect(at(travel * 0.5), closeTo(triggerMax * 0.468, 1));
      expect(
        at(travel * 0.6) - at(travel * 0.5),
        closeTo(at(travel * 0.7) - at(travel * 0.6), 1),
        reason: 'constant steps stay constant',
      );
    });

    test('the deadzone costs the first few percent, not a gamma', () {
      const deadzone = TriggerCurve(travel: travel, deadzone: 0.5);

      expect(deadzone.apply(travel * 0.25), triggerMin);
      expect(deadzone.apply(travel * 0.75), closeTo(triggerMax * 0.5, 2));
      expect(deadzone.apply(travel), triggerMax, reason: 'endpoint is exact');
    });
  });

  group('travel', () {
    test('travel comes from the caller, so a resize cannot change the feel', () {
      const short = TriggerCurve(travel: 20.0);
      const long = TriggerCurve(travel: 120.0);

      expect(short.apply(10), long.apply(60), reason: 'same fraction');
    });

    test('the endpoints hold at any travel', () {
      for (final t in [8.0, 20.0, 48.0, 200.0]) {
        final sized = TriggerCurve(travel: t);

        expect(sized.apply(0), triggerMin, reason: 'travel $t');
        expect(sized.apply(t), triggerMax, reason: 'travel $t');
      }
    });
  });
}