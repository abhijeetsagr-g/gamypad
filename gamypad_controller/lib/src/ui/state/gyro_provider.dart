import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/input/gyro_controller.dart';
import 'package:gamypad_controller/src/input/sensors_plus_motion.dart';
import 'package:gamypad_controller/src/ui/state/connection_controller.dart';
import 'package:gamypad_controller/src/ui/state/input_provider.dart';
import 'package:gamypad_controller/src/ui/state/setting_controller.dart';

final motionSensorsProvider = Provider<MotionSensors>(
  (ref) => const SensorsPlusMotion(),
);

/// The running gyro controller, or null when gyro is off or there is no link.
///
/// `autoDispose`, and watched by the controller screen: the sensors are only
/// listened to while the pad is on screen, and not at all while gyro is off.
final gyroControllerProvider = Provider.autoDispose<GyroController?>((ref) {
  final settings = ref.watch(settingControllerProvider).value;
  final connected = ref.watch(
    connectionControllerProvider.select((c) => c.isConnected),
  );
  if (settings == null || !settings.gyroEnabled || !connected) return null;

  final controller = GyroController(
    sensors: ref.watch(motionSensorsProvider),
    input: ref.watch(inputProvider),
    mode: settings.gyroMode,
  )..start();
  ref.onDispose(controller.stop);
  return controller;
});
