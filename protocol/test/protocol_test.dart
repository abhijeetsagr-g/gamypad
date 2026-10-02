import 'dart:convert';

import 'package:protocol/protocol.dart';
import 'package:test/test.dart';

/// The wire tokens as they appear in `gamypad_pc/native/Gamepad.cpp` `keyMap`,
/// in declaration order. If this list and that map ever disagree, input breaks
/// on the PC with a silently missed key.
const _keyMapKeys = [
  'A',
  'B',
  'X',
  'Y',
  'UP',
  'DOWN',
  'LEFT',
  'RIGHT',
  'LB',
  'RB',
  'START',
  'SELECT',
  'LS',
  'RS',
  'GUIDE',
];

void main() {
  group('GamepadButton', () {
    test('matches the native keyMap exactly, in order', () {
      expect(GamepadButton.values.map((b) => b.name).toList(), _keyMapKeys);
    });

    test('every value round-trips through its name', () {
      for (final b in GamepadButton.values) {
        expect(GamepadButton.values.byName(b.name), b);
      }
    });

    test('has no duplicate wire tokens', () {
      final names = GamepadButton.values.map((b) => b.name).toList();
      expect(names.toSet().length, names.length);
    });
  });

  group('GamepadTrigger', () {
    test('uses the LT/RT wire tokens', () {
      expect(GamepadTrigger.values.map((t) => t.name).toList(), ['LT', 'RT']);
    });
  });

  group('GamepadStick', () {
    test('uses the leftStick/rightStick wire tokens', () {
      expect(GamepadStick.values.map((s) => s.name).toList(), [
        'leftStick',
        'rightStick',
      ]);
    });
  });

  group('Ping / Pong', () {
    test('Ping encodes to the exact wire bytes', () {
      expect(const Ping().encode(), '{"type":"ping"}');
    });

    test('Pong encodes to the exact wire bytes', () {
      expect(const Pong().encode(), '{"type":"pong"}');
    });

    test('both decode back to their own type', () {
      expect(Message.fromJson({'type': 'ping'}), isA<Ping>());
      expect(Message.fromJson({'type': 'pong'}), isA<Pong>());
    });

    test('an unknown type is rejected', () {
      expect(
        () => Message.fromJson({'type': 'nope'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ButtonMessage', () {
    test('press encodes with an uppercase btn token', () {
      expect(
        ButtonMessage(button: GamepadButton.A, pressed: true).encode(),
        '{"action":"press","btn":"A"}',
      );
    });

    test('release encodes with an uppercase btn token', () {
      expect(
        ButtonMessage(button: GamepadButton.GUIDE, pressed: false).encode(),
        '{"action":"release","btn":"GUIDE"}',
      );
    });

    test('round-trips every button in both directions', () {
      for (final button in GamepadButton.values) {
        for (final pressed in [true, false]) {
          final original = ButtonMessage(button: button, pressed: pressed);
          final decoded = Message.fromJson(
            jsonDecode(original.encode()) as Map<String, dynamic>,
          );
          expect(decoded, isA<ButtonMessage>());
          final message = decoded as ButtonMessage;
          expect(message.button, button);
          expect(message.pressed, pressed);
        }
      }
    });

    test('an unknown button name is rejected', () {
      expect(
        () => Message.fromJson({'action': 'press', 'btn': 'TURBO'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a lowercase button name is rejected', () {
      // Guards against a silent revert to lowercase tokens, which would miss
      // every key in the native keyMap.
      expect(
        () => Message.fromJson({'action': 'press', 'btn': 'a'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TriggerMessage', () {
    test('action carries the LT/RT token', () {
      expect(
        TriggerMessage(
          trigger: GamepadTrigger.LT,
          value: 255,
        ).toJson()['action'],
        'LT',
      );
      expect(
        TriggerMessage(trigger: GamepadTrigger.RT, value: 0).toJson()['action'],
        'RT',
      );
    });

    test('normalized maps 0..255 onto 0.0..1.0', () {
      expect(
        TriggerMessage(trigger: GamepadTrigger.LT, value: 0).normalized,
        0.0,
      );
      expect(
        TriggerMessage(trigger: GamepadTrigger.LT, value: 255).normalized,
        1.0,
      );
    });

    test('pressed is true above zero only', () {
      expect(
        TriggerMessage(trigger: GamepadTrigger.LT, value: 0).pressed,
        isFalse,
      );
      expect(
        TriggerMessage(trigger: GamepadTrigger.LT, value: 1).pressed,
        isTrue,
      );
    });

    test('out-of-range values are rejected on decode', () {
      expect(
        () => Message.fromJson({'action': 'LT', 'value': '256'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => Message.fromJson({'action': 'RT', 'value': '-1'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('round-trips across the full analog range', () {
      for (final value in [0, 1, 64, 128, 254, 255]) {
        for (final trigger in GamepadTrigger.values) {
          final original = TriggerMessage(trigger: trigger, value: value);
          final decoded = Message.fromJson(original.toJson()) as TriggerMessage;
          expect(decoded.trigger, trigger);
          expect(decoded.value, value);
        }
      }
    });
  });

  group('StickMessage', () {
    test('action carries the leftStick/rightStick token', () {
      final message = StickMessage(
        stick: GamepadStick.leftStick,
        x: '0',
        y: '0',
      );
      expect(message.toJson()['action'], 'leftStick');
    });

    test('parses x and y into numeric getters', () {
      final message = StickMessage(
        stick: GamepadStick.rightStick,
        x: '-32767',
        y: '32767',
      );
      expect(message.xValue, -32767.0);
      expect(message.yValue, 32767.0);
    });

    test('a non-numeric axis is rejected', () {
      final message = StickMessage(
        stick: GamepadStick.leftStick,
        x: 'left',
        y: '0',
      );
      expect(() => message.xValue, throwsA(isA<FormatException>()));
    });

    test('a missing axis is rejected on decode', () {
      expect(
        () => Message.fromJson({
          'action': 'leftStick',
          'value': {'x': '10'},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('round-trips both sticks', () {
      for (final stick in GamepadStick.values) {
        final original = StickMessage(stick: stick, x: '128', y: '-128');
        final decoded = Message.fromJson(original.toJson()) as StickMessage;
        expect(decoded.stick, stick);
        expect(decoded.xValue, 128.0);
        expect(decoded.yValue, -128.0);
      }
    });
  });

  group('unknown actions', () {
    test('are rejected', () {
      expect(
        () => Message.fromJson({'action': 'teleport'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a message with no type and no action is rejected', () {
      expect(
        () => Message.fromJson({'btn': 'A'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
