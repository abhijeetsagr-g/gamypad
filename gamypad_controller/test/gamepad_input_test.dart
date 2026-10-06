import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/input/gamepad_input.dart';
import 'package:protocol/protocol.dart';

import 'fake_transport.dart';

void main() {
  late FakeTransport transport;
  late GamepadInput input;

  /// Buttons in `sent`, as `action:value` pairs. Comparing pairs rather than
  /// `Message` instances because `protocol` gives them no `operator==`.
  List<String> wire() => [
    for (final message in transport.sent)
      if (message is ButtonMessage)
        '${message.button.name}:${message.pressed ? 1 : 0}'
      else if (message is StickMessage)
        '${message.stick.name}:${message.x},${message.y}'
      else if (message is TriggerMessage)
        '${message.trigger.name}:${message.value}',
  ];

  setUp(() {
    transport = FakeTransport();
    input = GamepadInput(transport: transport);
  });

  tearDown(() async {
    input.dispose();
    await transport.close();
  });

  group('translating intent', () {
    test('press becomes a pressed button message', () async {
      input.press(GamepadButton.A);
      await settle();

      expect(wire(), ['A:1']);
    });

    test('release becomes a released button message', () async {
      input.release(GamepadButton.B);
      await settle();

      expect(wire(), ['B:0']);
    });

    test('a stick position is passed through unscaled', () async {
      input.setStick(GamepadStick.leftStick, 16000, -9000);
      await settle();

      expect(wire(), ['leftStick:16000,-9000']);
    });

    test('a trigger value is passed through unscaled', () async {
      input.setTrigger(GamepadTrigger.RT, 200);
      await settle();

      expect(wire(), ['RT:200']);
    });

    test('only buttons the protocol declares are reachable', () {
      // The old layer took a `String`, so a stale button name typechecked fine
      // and arrived at the PC as a dead key. There is no runtime assertion here
      // that could regress — the guarantee *is* the enum, and the analyzer
      // rejecting `GamepadButton.turbo` is what enforces it.
      expect(GamepadButton.values, isNot(contains('Turbo')));
      expect(
        GamepadButton.values,
        containsAll(<GamepadButton>[
          GamepadButton.A,
          GamepadButton.B,
          GamepadButton.START,
          GamepadButton.GUIDE,
        ]),
      );
    });
  });

  group('held state survives a disconnect', () {
    test('reconnecting replays what is still held', () async {
      input.press(GamepadButton.A);
      input.press(GamepadButton.B);
      await settle();
      transport.sent.clear();

      transport.emit(ConnectionStatus.connecting);
      transport.emit(ConnectionStatus.connected);
      await settle();

      expect(wire(), ['A:1', 'B:1']);
    });

    test('a button released while disconnected is not replayed', () async {
      // The subtle case, and the reason replay exists at all. The release could
      // not be delivered, so only local state knows it happened.
      input.press(GamepadButton.A);
      await settle();
      transport.emit(ConnectionStatus.lost);
      await settle();
      transport.sent.clear();

      // The real transport drops this — `udp_transport_test.dart` pins that — so
      // only local state knows the user let go.
      input.release(GamepadButton.A);
      await settle();
      transport.sent.clear();

      transport.emit(ConnectionStatus.connecting);
      transport.emit(ConnectionStatus.connected);
      await settle();

      expect(
        wire(),
        isEmpty,
        reason: 'the user let go, so a replay would wrongly hold A down',
      );
    });

    test('pressing while disconnected is replayed on reconnect', () async {
      input.press(GamepadButton.A);
      await settle();
      transport.sent.clear();

      transport.emit(ConnectionStatus.connected);
      await settle();

      expect(wire(), ['A:1']);
    });

    test('a lost link does not by itself clear held state', () async {
      input.press(GamepadButton.A);
      await settle();
      transport.sent.clear();

      transport.emit(ConnectionStatus.lost);
      await settle();

      transport.emit(ConnectionStatus.connected);
      await settle();

      expect(wire(), [
        'A:1',
      ], reason: 'still holding the button when the link came back');
    });

    test('connecting does not replay, only being connected does', () async {
      input.press(GamepadButton.A);
      await settle();
      transport.sent.clear();

      transport.emit(ConnectionStatus.connecting);
      await settle();

      expect(wire(), isEmpty);
    });
  });

  group('releaseAll', () {
    test('releases every held button', () async {
      input.press(GamepadButton.A);
      input.press(GamepadButton.B);
      await settle();
      transport.sent.clear();

      input.releaseAll();
      await settle();

      expect(wire(), containsAll(<String>['A:0', 'B:0']));
    });

    test('centres both sticks and rests both triggers', () async {
      input.releaseAll();
      await settle();

      expect(
        wire(),
        containsAll(<String>[
          'leftStick:$stickCenter,$stickCenter',
          'rightStick:$stickCenter,$stickCenter',
          'LT:$triggerMin',
          'RT:$triggerMin',
        ]),
        reason: 'rest is absolute, so a deflected stick gets unwedged',
      );
    });

    test(
      'held state is empty afterwards, so a reconnect replays nothing',
      () async {
        input.press(GamepadButton.A);
        await settle();

        input.releaseAll();
        await settle();
        transport.sent.clear();

        transport.emit(ConnectionStatus.connected);
        await settle();

        expect(wire(), isEmpty);
      },
    );

    test('is safe to call twice', () async {
      input.releaseAll();
      await settle();
      input.releaseAll();
      await settle();

      expect(
        wire().length,
        8,
        reason: 'four per call — two sticks, two triggers — and no throw',
      );
    });
  });

  group('dispose', () {
    test('releases the pad, so it is not left stuck', () async {
      input.press(GamepadButton.A);
      await settle();
      transport.sent.clear();

      input.dispose();
      await settle();

      expect(wire(), contains('A:0'));
    });

    test('stops listening, so a later reconnect replays nothing', () async {
      input.press(GamepadButton.A);
      await settle();
      input.dispose();
      await settle();
      transport.sent.clear();

      transport.emit(ConnectionStatus.connected);
      await settle();

      expect(
        wire(),
        isEmpty,
        reason: 'the subscription must not outlive the object',
      );
    });
  });
}
