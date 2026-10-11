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

/// Turns sensor readings into controller input according to a [GyroMode].
///
/// Pure Dart: no Flutter, no Riverpod, no plugin. The sensors come in through
/// [MotionSensors], so tests can feed it readings directly.
class GyroController {
  GyroController({
    required MotionSensors sensors,
    required GamepadInput input,
    required this.mode,
  }) : _sensors = sensors,
       _input = input;

  final MotionSensors _sensors;
  final GamepadInput _input;
  final GyroMode mode;

  final _side = LandscapeSide();
  Vec3 _gyro = Vec3.zero;
  Vec3 _accel = Vec3.zero;

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
    final stick = _stick;
    if (stick != null) _input.releaseMotionStick(stick);
  }

  void _onAccel(Vec3 raw) {
    _side.update(raw);
    _accel = _side.toController(raw);

    if (mode == GyroMode.tilt) {
      final p = tiltStick(_accel);
      _input.setMotionStick(GamepadStick.leftStick, p.x, p.y);
    }
  }

  void _onGyro(Vec3 raw) {
    _gyro = _side.toController(raw);

    switch (mode) {
      case GyroMode.aim:
        final p = aimStick(_gyro);
        _input.setMotionStick(GamepadStick.rightStick, p.x, p.y);
      case GyroMode.motionDevice:
        _input.sendMotion(motionMessage(_gyro, _accel));
      case GyroMode.tilt:
        break;
    }
  }
}
