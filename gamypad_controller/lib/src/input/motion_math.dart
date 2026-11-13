import 'dart:math' as math;

import 'package:protocol/protocol.dart';

/// A sensor reading. Gyro in rad/s, accelerometer in m/s² (gravity included),
/// exactly as Android reports them.
class Vec3 {
  const Vec3(this.x, this.y, this.z);
  final double x, y, z;

  static const zero = Vec3(0, 0, 0);

  double get length => math.sqrt(x * x + y * y + z * z);

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double k) => Vec3(x * k, y * k, z * k);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;
  Vec3 cross(Vec3 o) =>
      Vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  /// Unit vector in the same direction, or [zero] if there is none.
  Vec3 get unit {
    final l = length;
    return l == 0 ? zero : this * (1 / l);
  }

  @override
  String toString() => 'Vec3($x, $y, $z)';
}

const double _gravity = 9.80665;
const double _degPerRad = 180 / math.pi;

/// Which landscape the phone is held in, read from gravity.
///
/// Android reports sensors in the phone's natural *portrait* frame. Held
/// sideways, gravity lies along the device x axis: positive when the top edge
/// points left, negative when it points right. The app allows both landscapes,
/// so the side has to be found at runtime.
class LandscapeSide {
  /// +1: top edge to the left. -1: top edge to the right.
  int sign = 1;

  /// Gravity must clearly dominate x before the side is changed, so a phone
  /// lying flat (x ≈ 0) keeps the last known side instead of flickering.
  void update(Vec3 accelerometer) {
    if (accelerometer.x.abs() > 3) sign = accelerometer.x > 0 ? 1 : -1;
  }

  /// Device frame -> controller frame: x to the player's right, y up, z towards
  /// the player. Works for a gyro vector too, since it is a pure rotation of
  /// the axes.
  Vec3 toController(Vec3 v) => Vec3(-sign * v.y, sign * v.x, v.z);
}

/// Which way is up, in the controller frame, tracked by fusing both sensors:
/// the gyro carries it smoothly through fast movement, and the accelerometer
/// slowly pulls it back to the true direction of gravity so it cannot drift.
/// That is what makes this a 6-axis reading rather than a 3-axis one.
class GravityTracker {
  GravityTracker({this.pull = 0.02});

  /// How strongly each accelerometer reading corrects the estimate, 0..1.
  /// Small: the gyro is trusted over short spans, gravity over long ones.
  final double pull;

  Vec3? _up;

  /// Unit vector pointing at the sky, or null until the first accelerometer
  /// reading.
  Vec3? get up => _up;

  /// Carries the estimate through a rotation of [gyro] rad/s lasting [dt]
  /// seconds. A fixed world vector appears to turn the opposite way in the
  /// frame of the thing that is rotating.
  void gyro(Vec3 gyro, double dt) {
    final up = _up;
    if (up == null || dt <= 0) return;
    _up = (up - gyro.cross(up) * dt).unit;
  }

  /// Corrects the estimate from an accelerometer reading in m/s².
  void accel(Vec3 accel) {
    final length = accel.length;
    if (length < 1) return; // free fall: no usable direction
    final measured = accel * (1 / length);
    final up = _up;
    if (up == null) {
      _up = measured;
      return;
    }
    // While the phone is being accelerated (a shake, a swing) the reading is
    // gravity plus motion and points the wrong way; do not learn from it.
    final steady = (length - _gravity).abs() < 1.5;
    _up = steady ? (up * (1 - pull) + measured * pull).unit : up;
  }
}

/// Turning speeds, in degrees per second. [yaw] is positive turning right,
/// [pitch] is positive when the far edge of the phone goes down (look down).
typedef AimRates = ({double yaw, double pitch});

/// Reads [gyro] (controller frame, rad/s) as aim rates.
///
/// Without [up], yaw is the rotation about the controller's own vertical axis.
/// With it, yaw is the rotation about *true* vertical, so the camera still
/// turns the right way when the phone is rolled or tipped back — "world
/// space" gyro, as used by Steam Input. Pitch is always about the controller's
/// own right axis.
AimRates aimRates(Vec3 gyro, {Vec3? up, bool invertY = false}) {
  final vertical = up ?? const Vec3(0, 1, 0);
  final yaw = -gyro.dot(vertical) * _degPerRad;
  final pitch = gyro.x * _degPerRad;
  return (yaw: yaw, pitch: invertY ? -pitch : pitch);
}

/// Rotation speed that pushes the stick fully over.
const double aimFullScaleDps = 90;

/// Rotation slower than this reads as still, so sensor noise and hand tremor
/// do not creep the camera.
const double aimDeadzoneDps = 2.5;

/// Aim rates -> right stick. The stick is proportional to rotation *speed*:
/// stop turning and it returns to centre, which is how "gyro to joystick"
/// mappings in Steam Input behave.
({int x, int y}) aimStickFromRates(AimRates rates) {
  final speed = math.sqrt(rates.yaw * rates.yaw + rates.pitch * rates.pitch);
  if (speed < aimDeadzoneDps) return (x: stickCenter, y: stickCenter);

  // Rescale so leaving the deadzone starts from 0, not a jump.
  final scale = (speed - aimDeadzoneDps) / (aimFullScaleDps - aimDeadzoneDps);
  final k = math.min(scale, 1.0) / speed;
  return (x: _units(rates.yaw * k), y: _units(rates.pitch * k));
}

/// Gyro -> right stick. Turning the phone right looks right; raising the far
/// edge looks up (stick up is negative y, as on the touch stick).
({int x, int y}) aimStick(Vec3 gyro, {Vec3? up, bool invertY = false}) =>
    aimStickFromRates(aimRates(gyro, up: up, invertY: invertY));

/// Accumulated turn that pushes the held stick fully over.
const double holdFullScaleDeg = 30;

/// The "hold" variant of aim: instead of following rotation *speed*, the stick
/// follows the total angle turned, so it stays where it is when you stop and
/// only moves back when you turn back. [reset] recentres it.
class AimHold {
  double _yaw = 0;
  double _pitch = 0;

  void reset() => _yaw = _pitch = 0;

  /// Adds [dt] seconds of turning at [rates] and returns the stick position.
  ({int x, int y}) update(AimRates rates, double dt) {
    final speed = math.sqrt(rates.yaw * rates.yaw + rates.pitch * rates.pitch);
    if (speed >= aimDeadzoneDps) {
      _yaw = (_yaw + rates.yaw * dt).clamp(-holdFullScaleDeg, holdFullScaleDeg);
      _pitch = (_pitch + rates.pitch * dt).clamp(
        -holdFullScaleDeg,
        holdFullScaleDeg,
      );
    }
    return (
      x: _units(_yaw / holdFullScaleDeg),
      y: _units(_pitch / holdFullScaleDeg),
    );
  }
}

/// Tilt that pushes the stick fully over, like turning a steering wheel.
const double tiltFullScaleDeg = 45;
const double tiltDeadzoneDeg = 4;

/// Accelerometer -> left stick X. Turning the phone clockwise, as a wheel, goes
/// right. [accel] is in the controller frame, m/s².
///
/// Only the wheel angle is used. Pitch would need a calibrated neutral pose,
/// which nothing here can know.
({int x, int y}) tiltStick(Vec3 accel) {
  // Lying flat: gravity is along z and the wheel angle is undefined.
  if (math.sqrt(accel.x * accel.x + accel.y * accel.y) < 2) {
    return (x: stickCenter, y: stickCenter);
  }
  final angle = math.atan2(-accel.x, accel.y) * _degPerRad;
  if (angle.abs() < tiltDeadzoneDeg) return (x: stickCenter, y: stickCenter);

  final scale =
      (angle.abs() - tiltDeadzoneDeg) / (tiltFullScaleDeg - tiltDeadzoneDeg);
  final value = math.min(scale, 1.0) * angle.sign;
  return (x: _units(value), y: stickCenter);
}

/// Controller-frame readings -> wire units, clamped to the protocol's ranges.
MotionMessage motionMessage(Vec3 gyro, Vec3 accel) {
  int mdps(double radPerSecond) =>
      (radPerSecond * _degPerRad * 1000).round().clamp(gyroMin, gyroMax);
  int mg(double metresPerSecondSquared) =>
      (metresPerSecondSquared / _gravity * 1000).round().clamp(
        accelMin,
        accelMax,
      );

  return MotionMessage(
    gx: mdps(gyro.x),
    gy: mdps(gyro.y),
    gz: mdps(gyro.z),
    ax: mg(accel.x),
    ay: mg(accel.y),
    az: mg(accel.z),
  );
}

int _units(double normalized) =>
    (normalized * stickMax).clamp(stickMin, stickMax).toInt();
