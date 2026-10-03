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

Map<String, dynamic> _decode(String encoded) =>
    jsonDecode(encoded) as Map<String, dynamic>;

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

    test('left comes first, so index 0 is left', () {
      // Same reason as GamepadStick: the index crosses into native, where 0
      // must mean left for both sticks and triggers to agree.
      expect(GamepadTrigger.LT.index, 0);
      expect(GamepadTrigger.RT.index, 1);
    });
  });

  group('GamepadStick', () {
    test('uses the leftStick/rightStick wire tokens', () {
      expect(GamepadStick.values.map((s) => s.name).toList(), [
        'leftStick',
        'rightStick',
      ]);
    });

    test('left comes first, so index 0 is left', () {
      // `gamypad_pc` passes `stick.index` straight through FFI and the native
      // setAxis treats 0 as left. Reordering this enum would silently swap the
      // sticks with no error, so the order is pinned here.
      expect(GamepadStick.leftStick.index, 0);
      expect(GamepadStick.rightStick.index, 1);
    });
  });

  group('the two-key shape', () {
    test('every input message uses "action" and "value"', () {
      final messages = <Message>[
        const ButtonMessage(button: GamepadButton.A, pressed: true),
        const TriggerMessage(trigger: GamepadTrigger.LT, value: 128),
        const StickMessage(stick: GamepadStick.leftStick, x: 1, y: 2),
      ];
      for (final message in messages) {
        expect(message.toJson().keys.toSet(), {'action', 'value'});
      }
    });

    test('no input message collides with the health "type" key', () {
      for (final button in GamepadButton.values) {
        expect(
          const ButtonMessage(
            button: GamepadButton.A,
            pressed: true,
          ).toJson().containsKey('type'),
          isFalse,
        );
        expect(button.name, isNot('ping'));
        expect(button.name, isNot('pong'));
      }
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
    test('pressed encodes as action=A value=1', () {
      expect(
        const ButtonMessage(button: GamepadButton.A, pressed: true).encode(),
        '{"action":"A","value":1}',
      );
    });

    test('released encodes as action=A value=0', () {
      expect(
        const ButtonMessage(button: GamepadButton.A, pressed: false).encode(),
        '{"action":"A","value":0}',
      );
    });

    test('every button uses its uppercase token as the action', () {
      for (final button in GamepadButton.values) {
        expect(
          ButtonMessage(button: button, pressed: true).toJson()['action'],
          button.name,
        );
      }
    });

    test('round-trips every button in both directions', () {
      for (final button in GamepadButton.values) {
        for (final pressed in [true, false]) {
          final original = ButtonMessage(button: button, pressed: pressed);
          final decoded = Message.fromJson(_decode(original.encode()));
          expect(decoded, isA<ButtonMessage>());
          final message = decoded as ButtonMessage;
          expect(message.button, button);
          expect(message.pressed, pressed);
        }
      }
    });

    test('an unknown button name is rejected', () {
      expect(
        () => Message.fromJson({'action': 'TURBO', 'value': 1}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a lowercase button name is rejected', () {
      // Guards against a silent revert to lowercase tokens, which would miss
      // every key in the native keyMap.
      expect(
        () => Message.fromJson({'action': 'a', 'value': 1}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a button value other than 0 or 1 is rejected', () {
      expect(
        () => Message.fromJson({'action': 'A', 'value': 2}),
        throwsA(isA<FormatException>()),
      );
    });

    test('accepts a numeric string for the value', () {
      final decoded =
          Message.fromJson({'action': 'A', 'value': '1'}) as ButtonMessage;
      expect(decoded.pressed, isTrue);
    });
  });

  group('TriggerMessage', () {
    test('action carries the LT/RT token', () {
      expect(
        const TriggerMessage(
          trigger: GamepadTrigger.LT,
          value: 255,
        ).toJson()['action'],
        'LT',
      );
      expect(
        const TriggerMessage(
          trigger: GamepadTrigger.RT,
          value: 0,
        ).toJson()['action'],
        'RT',
      );
    });

    test('round-trips across the full analog range', () {
      for (final value in [triggerMin, 1, 64, 128, 254, triggerMax]) {
        for (final trigger in GamepadTrigger.values) {
          final original = TriggerMessage(trigger: trigger, value: value);
          final decoded = Message.fromJson(original.toJson()) as TriggerMessage;
          expect(decoded.trigger, trigger);
          expect(decoded.value, value);
        }
      }
    });

    test('normalized maps the range onto 0.0..1.0', () {
      expect(
        const TriggerMessage(trigger: GamepadTrigger.LT, value: 0).normalized,
        0.0,
      );
      expect(
        const TriggerMessage(
          trigger: GamepadTrigger.LT,
          value: triggerMax,
        ).normalized,
        1.0,
      );
    });

    test('pressed is true above zero only', () {
      expect(
        const TriggerMessage(trigger: GamepadTrigger.LT, value: 0).pressed,
        isFalse,
      );
      expect(
        const TriggerMessage(trigger: GamepadTrigger.LT, value: 1).pressed,
        isTrue,
      );
    });

    test('out-of-range values are rejected', () {
      expect(
        () => TriggerMessage.parse(GamepadTrigger.LT, 256),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => TriggerMessage.parse(GamepadTrigger.LT, -1),
        throwsA(isA<FormatException>()),
      );
    });

    test('asserts reject out-of-range values at construction', () {
      expect(
        () => TriggerMessage(trigger: GamepadTrigger.LT, value: 256),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('StickMessage', () {
    test('action carries the leftStick/rightStick token', () {
      expect(
        const StickMessage(
          stick: GamepadStick.leftStick,
          x: 0,
          y: 0,
        ).toJson()['action'],
        'leftStick',
      );
    });

    test('carries both axes under value', () {
      final json = const StickMessage(
        stick: GamepadStick.rightStick,
        x: 255,
        y: 0,
      ).toJson();
      expect(json['value'], {'x': 255, 'y': 0});
    });

    test('xOffset and yOffset are centred on stickCenter', () {
      final centred = StickMessage(
        stick: GamepadStick.leftStick,
        x: stickCenter,
        y: stickCenter,
      );
      expect(centred.xOffset, 0.0);
      expect(centred.yOffset, 0.0);
    });

    test('both ends reach exactly 1.0 and -1.0', () {
      // The range is signed and symmetric, so neither direction is favoured.
      final high = const StickMessage(
        stick: GamepadStick.leftStick,
        x: stickMax,
        y: stickMax,
      );
      expect(high.xOffset, 1.0);
      expect(high.yOffset, 1.0);

      final low = const StickMessage(
        stick: GamepadStick.leftStick,
        x: stickMin,
        y: stickMin,
      );
      expect(low.xOffset, -1.0);
      expect(low.yOffset, -1.0);
    });

    test('is signed 16-bit, matching real Xbox 360 hardware', () {
      // Not 0..255: the Linux xpad driver reports sticks as signed 16-bit, and
      // gamypad_pc configures ABS_X/ABS_Y to -32767..32767 to match.
      expect(stickMin, -32767);
      expect(stickMax, 32767);
      expect(stickCenter, 0);
    });

    test('triggers stay unsigned 0..255, unlike sticks', () {
      // The asymmetry is in the hardware, so it is deliberate here too.
      expect(triggerMin, 0);
      expect(triggerMax, 255);
    });

    test('round-trips both sticks at the range bounds', () {
      for (final stick in GamepadStick.values) {
        for (final pair in [
          [stickMin, stickMin],
          [stickCenter, stickCenter],
          [stickMax, stickMax],
        ]) {
          final original = StickMessage(stick: stick, x: pair[0], y: pair[1]);
          final decoded = Message.fromJson(original.toJson()) as StickMessage;
          expect(decoded.stick, stick);
          expect(decoded.x, pair[0]);
          expect(decoded.y, pair[1]);
        }
      }
    });

    test('a missing axis is rejected', () {
      expect(
        () => StickMessage.parse(GamepadStick.leftStick, {'x': 10}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a non-object value is rejected', () {
      expect(
        () => StickMessage.parse(GamepadStick.leftStick, 128),
        throwsA(isA<FormatException>()),
      );
    });

    test('an out-of-range axis is rejected', () {
      expect(
        () => StickMessage.parse(GamepadStick.leftStick, {
          'x': stickMax + 1,
          'y': 0,
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => StickMessage.parse(GamepadStick.leftStick, {
          'x': 0,
          'y': stickMin - 1,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('asserts reject out-of-range axes at construction', () {
      expect(
        () =>
            StickMessage(stick: GamepadStick.leftStick, x: stickMax + 1, y: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('malformed messages', () {
    test('an unknown action is rejected', () {
      expect(
        () => Message.fromJson({'action': 'teleport', 'value': 1}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a message with neither type nor action is rejected', () {
      expect(
        () => Message.fromJson({'value': 1}),
        throwsA(isA<FormatException>()),
      );
    });

    test('a missing value is rejected', () {
      expect(
        () => Message.fromJson({'action': 'A'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
