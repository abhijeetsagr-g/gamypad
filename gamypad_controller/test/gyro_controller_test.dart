import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:gamypad_controller/src/input/gamepad_input.dart';
import 'package:gamypad_controller/src/input/gyro_controller.dart';
import 'package:gamypad_controller/src/input/motion_math.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:protocol/protocol.dart';

class _FakeTransport implements GamepadTransport {
  final sent = <Message>[];

  @override
  Future<void> send(Message message) async => sent.add(message);

  @override
  Stream<ConnectionStatus> get status => const Stream.empty();
  @override
  Stream<Message> get incoming => const Stream.empty();
  @override
  Future<void> connect(ConnectionTarget target) async {}
  @override
  Future<void> disconnect() async {}
}

class _FakeSensors implements MotionSensors {
  final gyro = StreamController<Vec3>(sync: true);
  final accel = StreamController<Vec3>(sync: true);

  @override
  Stream<Vec3> get gyroscope => gyro.stream;
  @override
  Stream<Vec3> get accelerometer => accel.stream;
}

// Phone held landscape, top edge to the left, level.
const _level = Vec3(9.8, 0, 0);

void main() {
  late _FakeTransport transport;
  late _FakeSensors sensors;
  late GamepadInput input;

  setUp(() {
    transport = _FakeTransport();
    sensors = _FakeSensors();
    input = GamepadInput(transport: transport, settings: const SettingModel());
  });

  GyroController make(GyroMode mode) =>
      GyroController(sensors: sensors, input: input, mode: mode)..start();

  List<StickMessage> sticks() =>
      transport.sent.whereType<StickMessage>().toList();

  group('aim', () {
    test('drives the right stick from rotation speed', () {
      make(GyroMode.aim);
      sensors.accel.add(_level);
      // Device y axis turning at -1 rad/s: after the landscape remap, that is
      // rotation about the controller's x axis (pitch).
      sensors.gyro.add(const Vec3(0, -1, 0));
      final sent = sticks();
      expect(sent, isNotEmpty);
      expect(sent.last.stick, GamepadStick.rightStick);
    });

    test('does not resend an unchanged position', () {
      make(GyroMode.aim);
      sensors.accel.add(_level);
      sensors.gyro.add(const Vec3(0, 0, 0)); // centre, nothing to say
      expect(sticks(), isEmpty);

      sensors.gyro.add(const Vec3(1, 0, 0));
      sensors.gyro.add(const Vec3(1, 0, 0));
      expect(sticks(), hasLength(1));
    });

    test('stop returns the stick to centre', () async {
      final gyro = make(GyroMode.aim);
      sensors.accel.add(_level);
      sensors.gyro.add(const Vec3(1, 0, 0));
      await gyro.stop();

      expect(sticks().last, isA<StickMessage>());
      expect(sticks().last.x, 0);
      expect(sticks().last.y, 0);
    });

    test('a finger on the stick wins over the sensors', () {
      make(GyroMode.aim);
      sensors.accel.add(_level);
      input.setStick(GamepadStick.rightStick, 20000, 0);
      final before = transport.sent.length;

      sensors.gyro.add(const Vec3(1, 0, 0));
      expect(transport.sent.length, before);

      input.setStick(GamepadStick.rightStick, 0, 0); // finger lifts
      sensors.gyro.add(const Vec3(1, 0, 0));
      expect(transport.sent.length, greaterThan(before + 1));
    });

    test('never touches the left stick or sends motion', () {
      make(GyroMode.aim);
      sensors.accel.add(_level);
      sensors.gyro.add(const Vec3(1, 1, 1));
      expect(sticks().where((s) => s.stick == GamepadStick.leftStick), isEmpty);
      expect(transport.sent.whereType<MotionMessage>(), isEmpty);
    });
  });

  group('tilt', () {
    test('drives the left stick from the accelerometer', () {
      make(GyroMode.tilt);
      // Rotate the held phone 30 degrees: gravity leans in the device frame.
      final a = 30 * math.pi / 180;
      sensors.accel.add(Vec3(9.8 * math.cos(a), -9.8 * math.sin(a) * -1, 0));
      final sent = sticks();
      expect(sent, isNotEmpty);
      expect(sent.last.stick, GamepadStick.leftStick);
      expect(sent.last.y, 0);
    });

    test('ignores the gyro', () {
      make(GyroMode.tilt);
      sensors.accel.add(_level);
      sensors.gyro.add(const Vec3(5, 5, 5));
      expect(transport.sent.whereType<MotionMessage>(), isEmpty);
      expect(
        sticks().where((s) => s.stick == GamepadStick.rightStick),
        isEmpty,
      );
    });
  });

  group('motion device', () {
    test('sends motion messages carrying the latest accelerometer', () {
      make(GyroMode.motionDevice);
      sensors.accel.add(_level);
      sensors.gyro.add(const Vec3(0, 0, 0.5));

      final motion = transport.sent.whereType<MotionMessage>().single;
      expect(motion.ay, closeTo(1000, 5)); // level -> gravity on controller y
      expect(motion.gz, greaterThan(0));
    });

    test('does not move any stick', () {
      make(GyroMode.motionDevice);
      sensors.accel.add(_level);
      sensors.gyro.add(const Vec3(3, 3, 3));
      expect(sticks(), isEmpty);
    });
  });

  test('stop cancels the sensor subscriptions', () async {
    final gyro = make(GyroMode.motionDevice);
    sensors.accel.add(_level);
    await gyro.stop();
    final before = transport.sent.length;
    sensors.gyro.add(const Vec3(1, 1, 1));
    expect(transport.sent.length, before);
  });
}
