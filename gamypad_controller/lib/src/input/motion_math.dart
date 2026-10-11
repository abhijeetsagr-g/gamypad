import 'dart:math' as math;

import 'package:protocol/protocol.dart';

/// A sensor reading. Gyro in rad/s, accelerometer in m/s² (gravity included),
/// exactly as Android reports them.
class Vec3 {
  const Vec3(this.x, this.y, this.z);
  final double x, y, z;

  static const zero = Vec3(0, 0, 0);

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

/// Rotation speed that pushes the stick fully over.
const double aimFullScaleDps = 90;

/// Rotation slower than this reads as still, so sensor noise and hand tremor
/// do not creep the camera.
const double aimDeadzoneDps = 2.5;

/// Gyro -> right stick. Turning the phone right looks right; raising the far
/// edge looks up (stick up is negative y, as on the touch stick).
///
/// [gyro] is in the controller frame, rad/s. The stick is proportional to
/// rotation *speed* — stop turning and it returns to centre — which is how
/// "gyro to joystick" mappings in Steam Input behave.
({int x, int y}) aimStick(Vec3 gyro) {
  final yaw = -gyro.y * _degPerRad; // + = turning right
  final pitch = gyro.x * _degPerRad; // + = far edge down, i.e. look down

  final speed = math.sqrt(yaw * yaw + pitch * pitch);
  if (speed < aimDeadzoneDps) return (x: stickCenter, y: stickCenter);

  // Rescale so leaving the deadzone starts from 0, not a jump.
  final scale = (speed - aimDeadzoneDps) / (aimFullScaleDps - aimDeadzoneDps);
  final k = math.min(scale, 1.0) / speed;
  return (x: _units(yaw * k), y: _units(pitch * k));
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
