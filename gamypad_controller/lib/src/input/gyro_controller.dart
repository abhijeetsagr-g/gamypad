import 'dart:async';

import 'package:gamypad_controller/src/input/gamepad_input.dart';
import 'package:gamypad_controller/src/input/motion_math.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:protocol/protocol.dart';

/// The phone's motion sensors, in Android's units and device frame.
abstract interface class MotionSensors {
  Stream<Vec3> get gyroscope;
  Stream<Vec3> get accelerometer;
}

/// Per-mode tweaks, taken from the settings.
class GyroOptions {
  const GyroOptions({
    this.invertY = false,
    this.holdPosition = false,
    this.sixAxis = true,
  });

  factory GyroOptions.from(SettingModel settings) => GyroOptions(
    invertY: settings.gyroInvertY,
    holdPosition: settings.gyroHold,
    sixAxis: settings.gyroSixAxis,
  );

  /// Aim: flip the vertical axis.
  final bool invertY;

  /// Aim: the stick stays deflected when turning stops.
  final bool holdPosition;

  /// Aim and tilt: fuse gyro and accelerometer to track gravity.
  final bool sixAxis;
}

/// Turns sensor readings into controller input according to a [GyroMode].
///
/// Pure Dart: no Flutter, no Riverpod, no plugin. The sensors come in through
/// [MotionSensors] and time through [clock], so tests can drive it directly.
class GyroController {
  GyroController({
    required MotionSensors sensors,
    required GamepadInput input,
    required this.mode,
    this.options = const GyroOptions(),
    Duration Function()? clock,
  }) : _sensors = sensors,
       _input = input,
       _clock = clock ?? _stopwatchClock();

  final MotionSensors _sensors;
  final GamepadInput _input;
  final GyroMode mode;
  final GyroOptions options;
  final Duration Function() _clock;

  static Duration Function() _stopwatchClock() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  final _side = LandscapeSide();
  final _gravity = GravityTracker();
  final _hold = AimHold();
  Vec3 _gyro = Vec3.zero;
  Vec3 _accel = Vec3.zero;
  Duration? _lastGyroAt;

  StreamSubscription<Vec3>? _gyroSub;
  StreamSubscription<Vec3>? _accelSub;

  /// The stick this mode drives, if it drives one.
  GamepadStick? get _stick => switch (mode) {
    GyroMode.aim => GamepadStick.rightStick,
    GyroMode.tilt => GamepadStick.leftStick,
    GyroMode.motionDevice => null,
  };

  void start() {
    // Both sensors in every mode: the accelerometer is also how the landscape
    // side is found, and the gyro mode needs that to know which way is right.
    _accelSub = _sensors.accelerometer.listen(_onAccel);
    _gyroSub = _sensors.gyroscope.listen(_onGyro);
  }

  Future<void> stop() async {
    await _gyroSub?.cancel();
    await _accelSub?.cancel();
    _gyroSub = _accelSub = null;
    _hold.reset();
    final stick = _stick;
    if (stick != null) _input.releaseMotionStick(stick);
  }

  void _onAccel(Vec3 raw) {
    _side.update(raw);
    _accel = _side.toController(raw);
    if (options.sixAxis) _gravity.accel(_accel);

    if (mode == GyroMode.tilt) _emitTilt();
  }

  void _onGyro(Vec3 raw) {
    _gyro = _side.toController(raw);

    final now = _clock();
    final last = _lastGyroAt;
    _lastGyroAt = now;
    // A long gap (sensor paused, app suspended) is not rotation to integrate.
    final dt = last == null
        ? 0.0
        : ((now - last).inMicroseconds / 1e6).clamp(0.0, 0.1);

    if (options.sixAxis) _gravity.gyro(_gyro, dt);

    switch (mode) {
      case GyroMode.aim:
        _emitAim(dt);
      case GyroMode.motionDevice:
        _input.sendMotion(motionMessage(_gyro, _accel));
      case GyroMode.tilt:
        // The fused estimate moves with the gyro, not only on accelerometer
        // ticks, so steering responds as the phone turns.
        if (options.sixAxis) _emitTilt();
    }
  }

  void _emitAim(double dt) {
    const stick = GamepadStick.rightStick;
    final rates = aimRates(
      _gyro,
      up: options.sixAxis ? _gravity.up : null,
      invertY: options.invertY,
    );

    if (!options.holdPosition) {
      final p = aimStickFromRates(rates);
      _input.setMotionStick(stick, p.x, p.y);
      return;
    }

    // A finger on the stick takes over, and lifting it starts again from
    // centre — that is also how the held position is recentred.
    if (_input.isTouched(stick)) {
      _hold.reset();
      return;
    }
    final p = _hold.update(rates, dt);
    _input.setMotionStick(stick, p.x, p.y);
  }

  void _emitTilt() {
    // The fused up-vector is a unit vector; tiltStick wants m/s² only for its
    // "lying flat" check, so scale it to one g.
    final up = options.sixAxis ? _gravity.up : null;
    final p = tiltStick(up != null ? up * 9.80665 : _accel);
    _input.setMotionStick(GamepadStick.leftStick, p.x, p.y);
  }
}
