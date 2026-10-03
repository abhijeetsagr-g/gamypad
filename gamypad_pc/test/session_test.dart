import 'dart:async';

import 'package:gamypad_pc/src/device/gamepad_device.dart';
import 'package:gamypad_pc/src/session/gamepad_session.dart';
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:protocol/protocol.dart';
import 'package:test/test.dart';

/// Records every device call instead of touching uinput, so the whole session
/// can be exercised with no root, no /dev/uinput and no native library.
class FakeDevice implements GamepadDevice {
  final calls = <String>[];
  var disposed = false;

  @override
  void setButton(GamepadButton button, bool pressed) =>
      calls.add('button ${button.name} ${pressed ? 1 : 0}');

  @override
  void setTrigger(GamepadTrigger trigger, int value) =>
      calls.add('trigger ${trigger.name} $value');

  @override
  void setStick(GamepadStick stick, int x, int y) =>
      calls.add('stick ${stick.name} $x $y');

  @override
  void dispose() => disposed = true;
}

class FakeSocket implements MessageSocket {
  final sent = <Message>[];
  // Broadcast, like UdpSocket, so the session's subscription can be cancelled
  // and recreated across stop/start cycles.
  final _messages = StreamController<Message>.broadcast();
  final _state = StreamController<ConnectionState>.broadcast();

  var started = false;
  var stopped = false;
  var boundPort = 0;

  /// Queue a message as if it had arrived over the wire.
  void deliver(Message message) => _messages.add(message);

  void emit(ConnectionState state) => _state.add(state);

  @override
  Stream<Message> get messages => _messages.stream;

  @override
  Stream<ConnectionState> get state => _state.stream;

  @override
  int get port => boundPort;

  @override
  void send(Message message) => sent.add(message);

  @override
  Future<void> start() async => started = true;

  @override
  Future<void> stop() async => stopped = true;
}

void main() {
  late FakeDevice device;
  late FakeSocket socket;
  late GamepadSession session;

  setUp(() {
    device = FakeDevice();
    socket = FakeSocket();
    session = GamepadSession(socket: socket, device: device);
  });

  tearDown(() {
    session.dispose();
  });

  /// Lets the stream controller deliver and the listener run.
  Future<void> pump() => Future<void>.delayed(Duration.zero);

  group('startup', () {
    test('starts the socket', () async {
      await session.start();
      expect(socket.started, isTrue);
    });

    test('forwards the bound port from the socket', () {
      // 0 before start(): the port is only known once bind() has completed.
      expect(session.port, 0);
      socket.boundPort = 41234;
      expect(session.port, 41234);
    });
  });

  group('applying messages', () {
    setUp(() => session.start());

    test('a pressed button reaches the device', () async {
      socket.deliver(
        const ButtonMessage(button: GamepadButton.A, pressed: true),
      );
      await pump();
      expect(device.calls, ['button A 1']);
    });

    test('a released button carries 0, not a separate action', () async {
      socket.deliver(
        const ButtonMessage(button: GamepadButton.A, pressed: false),
      );
      await pump();
      expect(device.calls, ['button A 0']);
    });

    test('every button reaches the device by name', () async {
      for (final button in GamepadButton.values) {
        socket.deliver(ButtonMessage(button: button, pressed: true));
      }
      await pump();
      expect(
        device.calls,
        GamepadButton.values.map((b) => 'button ${b.name} 1'),
      );
    });

    test('a trigger passes its value through unscaled', () async {
      socket.deliver(
        const TriggerMessage(trigger: GamepadTrigger.LT, value: triggerMax),
      );
      await pump();
      expect(device.calls, ['trigger LT 255']);
    });

    test('a stick passes signed axes through unscaled', () async {
      socket.deliver(
        const StickMessage(
          stick: GamepadStick.leftStick,
          x: stickMin,
          y: stickMax,
        ),
      );
      await pump();
      // Native configures ABS_X/ABS_Y as -32767..32767, so the protocol range
      // must arrive untouched. A scale here would desync aim from hardware.
      expect(device.calls, ['stick leftStick -32767 32767']);
    });

    test('the dpad arrives as discrete button states, not a hat', () async {
      // The hat synthesis lives in UinputDevice, not here. The session must
      // stay a plain 1:1 mapping so it can be tested without uinput.
      socket.deliver(
        const ButtonMessage(button: GamepadButton.UP, pressed: true),
      );
      socket.deliver(
        const ButtonMessage(button: GamepadButton.RIGHT, pressed: true),
      );
      await pump();
      expect(device.calls, ['button UP 1', 'button RIGHT 1']);
    });

    test('messages are applied in order', () async {
      socket.deliver(
        const ButtonMessage(button: GamepadButton.A, pressed: true),
      );
      socket.deliver(
        const ButtonMessage(button: GamepadButton.B, pressed: true),
      );
      socket.deliver(
        const TriggerMessage(trigger: GamepadTrigger.RT, value: 200),
      );
      await pump();
      expect(device.calls, ['button A 1', 'button B 1', 'trigger RT 200']);
    });
  });

  group('ping', () {
    setUp(() => session.start());

    test('is answered with a pong', () async {
      socket.deliver(const Ping());
      await pump();
      expect(socket.sent, [const Pong()]);
    });

    test('does not reach the device', () async {
      socket.deliver(const Ping());
      await pump();
      expect(device.calls, isEmpty);
    });

    test('an unsolicited pong is ignored', () async {
      socket.deliver(const Pong());
      await pump();
      expect(socket.sent, isEmpty);
      expect(device.calls, isEmpty);
    });
  });

  group('stop', () {
    setUp(() => session.start());

    test('stops the socket', () async {
      await session.stop();
      expect(socket.stopped, isTrue);
    });

    test('does not dispose the device, so start/stop is reversible', () async {
      // Disposing here would free the native handle while the UI's toggle can
      // still start the server again, leaving writes going nowhere silently.
      await session.stop();
      expect(device.disposed, isFalse);

      await session.start();
      socket.deliver(
        const ButtonMessage(button: GamepadButton.A, pressed: true),
      );
      await pump();
      expect(device.calls, ['button A 1']);
    });

    test('ignores messages that arrive after stopping', () async {
      await session.stop();
      socket.deliver(
        const ButtonMessage(button: GamepadButton.A, pressed: true),
      );
      await pump();
      expect(device.calls, isEmpty);
    });
  });

  group('dispose', () {
    test('disposes the device', () {
      session.dispose();
      expect(device.disposed, isTrue);
    });
  });

  group('state', () {
    test('passes through from the socket', () async {
      final seen = <ConnectionState>[];
      final sub = session.state.listen(seen.add);
      await session.start();

      socket.emit(ConnectionState.listening);
      socket.emit(ConnectionState.connected);
      await pump();
      await sub.cancel();

      expect(seen, [ConnectionState.listening, ConnectionState.connected]);
    });
  });
}
