import 'package:gamypad_controller/src/input/gyro_controller.dart';
import 'package:gamypad_controller/src/input/motion_math.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// [MotionSensors] backed by the `sensors_plus` plugin.
class SensorsPlusMotion implements MotionSensors {
  const SensorsPlusMotion();

  // ~50 Hz: plenty for aiming, and a packet per sample stays cheap.
  static const _interval = SensorInterval.gameInterval;

  @override
  Stream<Vec3> get gyroscope => gyroscopeEventStream(
    samplingPeriod: _interval,
  ).map((e) => Vec3(e.x, e.y, e.z));

  @override
  Stream<Vec3> get accelerometer => accelerometerEventStream(
    samplingPeriod: _interval,
  ).map((e) => Vec3(e.x, e.y, e.z));
}
