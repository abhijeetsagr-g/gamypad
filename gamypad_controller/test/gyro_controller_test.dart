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

  group('options', () {
    // Phone level in landscape: controller y is up. A device-x rotation of -1
    // rad/s is the controller turning right at ~57 deg/s.
    const turnRight = Vec3(-1, 0, 0);
    const still = Vec3(0, 0, 0);

    var now = Duration.zero;
    Duration clock() => now;

    GyroController build(GyroOptions options, {GyroMode mode = GyroMode.aim}) {
      now = Duration.zero;
      return GyroController(
        sensors: sensors,
        input: input,
        mode: mode,
        options: options,
        clock: clock,
      )..start();
    }

    void feed(Vec3 gyro, int events) {
      for (var i = 0; i < events; i++) {
        now += const Duration(milliseconds: 20);
        sensors.gyro.add(gyro);
      }
    }

    test('default: the stick returns to centre when turning stops', () {
      build(const GyroOptions());
      sensors.accel.add(_level);
      feed(turnRight, 10);
      expect(sticks().last.x, greaterThan(0));
      feed(still, 1);
      expect(sticks().last.x, 0);
    });

    test('hold: the stick keeps its deflection when turning stops', () {
      build(const GyroOptions(holdPosition: true));
      sensors.accel.add(_level);
      feed(turnRight, 11); // first event has no elapsed time
      final held = sticks().last.x;
      expect(held, greaterThan(10000));

      feed(still, 50);
      expect(sticks().last.x, held); // never sent a return to centre
      expect(sticks().where((s) => s.x == 0), isEmpty);
    });

    test('hold: touching the stick recentres it', () {
      build(const GyroOptions(holdPosition: true));
      sensors.accel.add(_level);
      feed(turnRight, 11);

      input.setStick(GamepadStick.rightStick, 15000, 0); // finger down
      feed(still, 1); // controller notices and resets
      input.setStick(GamepadStick.rightStick, 0, 0); // finger up
      feed(still, 5);

      expect(sticks().last.x, 0);
    });

    // Device y rotation is controller pitch: +1 raises the far edge (look up).
    const pitchUp = Vec3(0, 1, 0);

    test('raising the far edge looks up by default (stick y negative)', () {
      build(const GyroOptions());
      sensors.accel.add(_level);
      feed(pitchUp, 3);
      expect(sticks().last.y, lessThan(0));
    });

    test('invertY: the same movement looks down (stick y positive)', () {
      build(const GyroOptions(invertY: true));
      sensors.accel.add(_level);
      feed(pitchUp, 3);
      expect(sticks().last.y, greaterThan(0));
      expect(sticks().last.x, 0); // horizontal untouched
    });

    test('6-axis: spinning a flat phone aims; without it, it does not', () {
      // Lying on a table screen-up: gravity on device z.
      const flat = Vec3(0, 0, 9.8);
      const spinRight = Vec3(0, 0, -1);

      build(const GyroOptions(sixAxis: false));
      sensors.accel.add(flat);
      feed(spinRight, 5);
      expect(sticks(), isEmpty);
    });

    test('6-axis on: the same spin turns the camera right', () {
      const flat = Vec3(0, 0, 9.8);
      const spinRight = Vec3(0, 0, -1);

      build(const GyroOptions());
      sensors.accel.add(flat);
      feed(spinRight, 5);
      expect(sticks().last.x, greaterThan(0));
    });

    test('tilt with 6-axis still steers', () {
      build(const GyroOptions(), mode: GyroMode.tilt);
      // About 30 degrees of wheel.
      sensors.accel.add(const Vec3(8.5, -4.9, 0));
      expect(sticks().last.stick, GamepadStick.leftStick);
      expect(sticks().last.x, isNot(0));
    });
  });
}
