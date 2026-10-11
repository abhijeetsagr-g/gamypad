import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/input/motion_math.dart';
import 'package:protocol/protocol.dart';

double _rad(double deg) => deg * math.pi / 180;

void main() {
  group('LandscapeSide', () {
    test(
      'gravity reads as "up" in the controller frame on either landscape',
      () {
        final left = LandscapeSide()..update(const Vec3(9.8, 0, 0));
        final right = LandscapeSide()..update(const Vec3(-9.8, 0, 0));

        final a = left.toController(const Vec3(9.8, 0, 0));
        final b = right.toController(const Vec3(-9.8, 0, 0));
        expect(a.y, closeTo(9.8, 1e-9));
        expect(b.y, closeTo(9.8, 1e-9));
        expect(a.x, closeTo(0, 1e-9));
        expect(b.x, closeTo(0, 1e-9));
      },
    );

    test('keeps the last side while the phone lies flat', () {
      final side = LandscapeSide()..update(const Vec3(-9.8, 0, 0));
      side.update(const Vec3(0.5, 0.2, 9.8));
      expect(side.sign, -1);
    });

    test('z (towards the player) is unchanged', () {
      final side = LandscapeSide();
      expect(side.toController(const Vec3(1, 2, 3)).z, 3);
    });
  });

  group('aimStick', () {
    test('still and tiny rotation read as centred', () {
      expect(aimStick(Vec3.zero), (x: 0, y: 0));
      expect(aimStick(Vec3(0, _rad(-1), 0)), (x: 0, y: 0));
    });

    test('turning right pushes the stick right, proportionally', () {
      final p = aimStick(Vec3(0, _rad(-45), 0));
      expect(p.x, inInclusiveRange(14000, 17500));
      expect(p.y, 0);
      expect(aimStick(Vec3(0, _rad(-60), 0)).x, greaterThan(p.x));
    });

    test('turning left pushes it left', () {
      expect(aimStick(Vec3(0, _rad(45), 0)).x, lessThan(0));
    });

    test('raising the far edge looks up: negative y, like the touch stick', () {
      expect(aimStick(Vec3(_rad(-45), 0, 0)).y, lessThan(0));
      expect(aimStick(Vec3(_rad(45), 0, 0)).y, greaterThan(0));
    });

    test('saturates at the stick range', () {
      final p = aimStick(const Vec3(0, -10, 0));
      expect(p.x, stickMax);
      expect(aimStick(const Vec3(0, 10, 0)).x, -stickMax);
    });

    test('diagonals never exceed the stick range', () {
      final p = aimStick(const Vec3(-10, -10, 0));
      expect(math.sqrt(p.x * p.x + p.y * p.y), lessThanOrEqualTo(stickMax + 1));
    });
  });

  group('tiltStick', () {
    Vec3 held(double clockwiseDeg) {
      final a = _rad(clockwiseDeg);
      return Vec3(-math.sin(a) * 9.8, math.cos(a) * 9.8, 0);
    }

    test('level is centre', () {
      expect(tiltStick(held(0)), (x: 0, y: 0));
      expect(tiltStick(held(2)), (x: 0, y: 0));
    });

    test('clockwise like a wheel goes right, anticlockwise left', () {
      expect(tiltStick(held(20)).x, greaterThan(0));
      expect(tiltStick(held(-20)).x, lessThan(0));
    });

    test('45 degrees and beyond is full lock', () {
      expect(tiltStick(held(45)).x, stickMax);
      expect(tiltStick(held(80)).x, stickMax);
      expect(tiltStick(held(-80)).x, -stickMax);
    });

    test('lying flat has no wheel angle', () {
      expect(tiltStick(const Vec3(0.3, 0.2, 9.8)), (x: 0, y: 0));
    });

    test('never drives y', () {
      expect(tiltStick(held(30)).y, 0);
    });
  });

  group('motionMessage', () {
    test('converts rad/s and m/s² to wire units', () {
      final m = motionMessage(const Vec3(1, 0, 0), const Vec3(0, 9.80665, 0));
      expect(m.gx, closeTo(57296, 1));
      expect(m.ay, 1000);
    });

    test('clamps to the protocol ranges', () {
      final m = motionMessage(
        const Vec3(1000, -1000, 0),
        const Vec3(500, 0, 0),
      );
      expect(m.gx, gyroMax);
      expect(m.gy, gyroMin);
      expect(m.ax, accelMax);
    });
  });
}
