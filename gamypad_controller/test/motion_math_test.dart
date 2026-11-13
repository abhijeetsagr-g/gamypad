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

  group('Vec3', () {
    test('cross, dot and unit', () {
      const x = Vec3(1, 0, 0);
      const y = Vec3(0, 1, 0);
      expect(x.cross(y).z, 1);
      expect(x.dot(y), 0);
      expect(const Vec3(0, 3, 4).unit.length, closeTo(1, 1e-12));
      expect(Vec3.zero.unit.length, 0);
    });
  });

  group('GravityTracker', () {
    test('has no estimate until the first accelerometer reading', () {
      expect(GravityTracker().up, isNull);
      final t = GravityTracker()..accel(const Vec3(0, 9.8, 0));
      expect(t.up!.y, closeTo(1, 1e-12));
    });

    test('the gyro carries it through a rotation', () {
      final t = GravityTracker()..accel(const Vec3(0, 9.8, 0));
      // 1 rad/s about the right axis for one second, no accelerometer help.
      for (var i = 0; i < 100; i++) {
        t.gyro(const Vec3(1, 0, 0), 0.01);
      }
      expect(t.up!.y, closeTo(math.cos(1), 0.02));
      expect(t.up!.z, closeTo(-math.sin(1), 0.02));
      expect(t.up!.length, closeTo(1, 1e-9));
    });

    test('the accelerometer pulls a wrong estimate back to gravity', () {
      final t = GravityTracker()..accel(const Vec3(9.8, 0, 0));
      for (var i = 0; i < 400; i++) {
        t.accel(const Vec3(0, 9.8, 0));
      }
      expect(t.up!.y, closeTo(1, 0.01));
    });

    test('ignores readings taken while the phone is being shaken', () {
      final t = GravityTracker()..accel(const Vec3(0, 9.8, 0));
      for (var i = 0; i < 100; i++) {
        t.accel(const Vec3(25, 0, 0));
      }
      expect(t.up!.y, closeTo(1, 1e-9));
    });

    test('ignores free fall', () {
      final t = GravityTracker()..accel(const Vec3(0, 9.8, 0));
      t.accel(const Vec3(0.1, 0.1, 0.1));
      expect(t.up!.y, closeTo(1, 1e-9));
    });
  });

  group('aimRates', () {
    test('without gravity, yaw is about the controller\'s own up axis', () {
      final r = aimRates(Vec3(0, _rad(-30), 0));
      expect(r.yaw, closeTo(30, 1e-9));
      expect(r.pitch, 0);
    });

    test('world space: spinning a flat phone still turns the camera', () {
      // Phone lying on a table, spun clockwise as seen from above.
      const spin = Vec3(0, 0, -1);
      expect(aimRates(spin).yaw, closeTo(0, 1e-9)); // local axes miss it
      final r = aimRates(spin, up: const Vec3(0, 0, 1));
      expect(r.yaw, closeTo(180 / math.pi, 1e-9));
    });

    test('invertY flips pitch only', () {
      final normal = aimRates(Vec3(_rad(20), _rad(-10), 0));
      final flipped = aimRates(Vec3(_rad(20), _rad(-10), 0), invertY: true);
      expect(flipped.pitch, closeTo(-normal.pitch, 1e-12));
      expect(flipped.yaw, closeTo(normal.yaw, 1e-12));
    });

    test('aimStick honours invertY', () {
      final up = aimStick(Vec3(_rad(-45), 0, 0));
      final down = aimStick(Vec3(_rad(-45), 0, 0), invertY: true);
      expect(up.y, lessThan(0));
      expect(down.y, -up.y);
    });
  });

  group('AimHold', () {
    const turningRight = (yaw: 60.0, pitch: 0.0);
    const still = (yaw: 0.0, pitch: 0.0);

    test('accumulates the angle turned', () {
      final hold = AimHold();
      // 0.25 s at 60 deg/s = 15 degrees = half of the 30 degree full scale.
      ({int x, int y}) p = (x: 0, y: 0);
      for (var i = 0; i < 25; i++) {
        p = hold.update(turningRight, 0.01);
      }
      expect(p.x, closeTo(stickMax / 2, 50));
    });

    test('stays put when turning stops', () {
      final hold = AimHold();
      for (var i = 0; i < 25; i++) {
        hold.update(turningRight, 0.01);
      }
      final held = hold.update(still, 0.01);
      expect(held.x, closeTo(stickMax / 2, 50));
      expect(hold.update(still, 5).x, held.x);
    });

    test('turning back brings it back', () {
      final hold = AimHold();
      for (var i = 0; i < 25; i++) {
        hold.update(turningRight, 0.01);
      }
      ({int x, int y}) p = (x: 0, y: 0);
      for (var i = 0; i < 25; i++) {
        p = hold.update((yaw: -60.0, pitch: 0.0), 0.01);
      }
      expect(p.x.abs(), lessThan(50));
    });

    test('saturates, and then needs only as much turning back as it took', () {
      final hold = AimHold();
      ({int x, int y}) p = (x: 0, y: 0);
      for (var i = 0; i < 500; i++) {
        p = hold.update(turningRight, 0.01); // 300 degrees
      }
      expect(p.x, stickMax);
      // 15 degrees back is half way, not 270 degrees' worth.
      for (var i = 0; i < 25; i++) {
        p = hold.update((yaw: -60.0, pitch: 0.0), 0.01);
      }
      expect(p.x, closeTo(stickMax / 2, 50));
    });

    test('rotation inside the deadzone does not creep the stick', () {
      final hold = AimHold();
      ({int x, int y}) p = (x: 0, y: 0);
      for (var i = 0; i < 1000; i++) {
        p = hold.update((yaw: 1.0, pitch: 1.0), 0.01);
      }
      expect(p, (x: 0, y: 0));
    });

    test('reset recentres', () {
      final hold = AimHold();
      for (var i = 0; i < 25; i++) {
        hold.update(turningRight, 0.01);
      }
      hold.reset();
      expect(hold.update(still, 0.01), (x: 0, y: 0));
    });
  });
}
