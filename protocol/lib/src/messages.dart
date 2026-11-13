import 'dart:convert';

import 'vocabulary/buttons.dart';

// Send This Messages Instead of Manually Writing Json Between Server and Client

/// Inclusive bounds for a [TriggerMessage] value.
///
/// Triggers are unsigned on real Xbox 360 hardware, reported as a single byte.
const int triggerMin = 0;
const int triggerMax = 255;

/// Inclusive bounds for each axis of a [StickMessage].
///
/// Sticks are *signed* 16-bit, matching what a real Xbox 360 controller
/// reports and what `gamypad_pc/native/Gamepad.cpp` configures for
/// `ABS_X`/`ABS_Y`/`ABS_RX`/`ABS_RY`. This is deliberately different from
/// [triggerMin]/[triggerMax] — the asymmetry is in the hardware, not here.
const int stickMin = -32767;
const int stickMax = 32767;

/// A centred stick. Zero is exactly halfway, so the range is symmetric.
const int stickCenter = 0;

/// Inclusive bounds for each gyroscope axis of a [MotionMessage], in
/// millidegrees per second (±2000 °/s, the usual range of a game-controller
/// IMU).
const int gyroMax = 2000000;
const int gyroMin = -gyroMax;

/// Inclusive bounds for each accelerometer axis of a [MotionMessage], in
/// milli-g (±16 g). A phone at rest reads about 1000 on whichever axis points
/// at the sky.
const int accelMax = 16000;
const int accelMin = -accelMax;

/// Messages exactly as they are on the wire (JSON).
///
/// Every message uses the same two keys. `action` names the input, `value`
/// carries the payload:
///
///   Ping:     {"type":"ping"}
///   Pong:     {"type":"pong"}
///   Button:   {"action":"A","value":1}              1 pressed, 0 released
///   Trigger:  {"action":"LT","value":255}           triggerMin..triggerMax
///   Stick:    {"action":"leftStick","value":{"x":32767,"y":-32767}}
///   Motion:   {"action":"motion","value":{"gx":0,"gy":0,"gz":0,"ax":0,"ay":1000,"az":0}}
///
/// The `type` key is reserved for connection health; everything else is input.
sealed class Message {
  const Message();
  Map<String, dynamic> toJson();

  String encode() => jsonEncode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != null) {
      return switch (type) {
        'ping' => const Ping(),
        'pong' => const Pong(),
        _ => throw FormatException('Unknown message type: $type'),
      };
    }

    final action = json['action'];
    if (action == null) {
      throw FormatException('Message has neither "type" nor "action": $json');
    }
    final value = json['value'];

    if (action == MotionMessage.action) return MotionMessage.parse(value);

    final button = _byName(GamepadButton.values, action);
    if (button != null) {
      return ButtonMessage(button: button, pressed: _asFlag(value));
    }

    final trigger = _byName(GamepadTrigger.values, action);
    if (trigger != null) {
      return TriggerMessage(
        trigger: trigger,
        value: _asInt(value, 'value', triggerMin, triggerMax),
      );
    }

    final stick = _byName(GamepadStick.values, action);
    if (stick != null) {
      return StickMessage.parse(stick, value);
    }

    throw FormatException('Unknown action: $action');
  }
}

T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

/// Reads an int that may have arrived as a JSON number or a numeric string.
int _asInt(Object? raw, String field, int min, int max) {
  int? parsed;
  if (raw is int) {
    parsed = raw;
  } else if (raw is num) {
    parsed = raw.toInt();
  } else if (raw is String) {
    parsed = int.tryParse(raw);
  }
  if (parsed == null) {
    throw FormatException('"$field" must be an int, got: $raw');
  }
  if (parsed < min || parsed > max) {
    throw FormatException('"$field" must be $min..$max, got: $parsed');
  }
  return parsed;
}

/// Buttons carry 1 for pressed and 0 for released.
bool _asFlag(Object? raw) => _asInt(raw, 'value', 0, 1) == 1;

// Watchdogs Functions, to check health of connection
final class Ping extends Message {
  const Ping();

  @override
  Map<String, dynamic> toJson() => {'type': 'ping'};
}

final class Pong extends Message {
  const Pong();

  @override
  Map<String, dynamic> toJson() => {'type': 'pong'};
}

// Buttons Messages
final class ButtonMessage extends Message {
  final GamepadButton button;
  final bool pressed;

  const ButtonMessage({required this.button, required this.pressed});

  @override
  Map<String, dynamic> toJson() => {
    'action': button.name,
    'value': pressed ? 1 : 0,
  };
}

// Trigger Messages, analog over triggerMin..triggerMax
final class TriggerMessage extends Message {
  final GamepadTrigger trigger;
  final int value;

  const TriggerMessage({required this.trigger, required this.value})
    : assert(value >= triggerMin && value <= triggerMax);

  factory TriggerMessage.parse(GamepadTrigger trigger, Object? raw) {
    return TriggerMessage(
      trigger: trigger,
      value: _asInt(raw, 'value', triggerMin, triggerMax),
    );
  }

  double get normalized => value / triggerMax;

  bool get pressed => value > 0;

  @override
  Map<String, dynamic> toJson() => {'action': trigger.name, 'value': value};
}

// Stick Message, two axes over stickMin..stickMax each
final class StickMessage extends Message {
  final GamepadStick stick;
  final int x;
  final int y;

  const StickMessage({required this.stick, required this.x, required this.y})
    : assert(x >= stickMin && x <= stickMax),
      assert(y >= stickMin && y <= stickMax);

  factory StickMessage.parse(GamepadStick stick, Object? raw) {
    if (raw is! Map) {
      throw FormatException('Stick "value" must be an object, got: $raw');
    }
    final x = raw['x'];
    final y = raw['y'];
    if (x == null || y == null) {
      throw FormatException('Stick "value" needs both x and y: $raw');
    }
    return StickMessage(
      stick: stick,
      x: _asInt(x, 'x', stickMin, stickMax),
      y: _asInt(y, 'y', stickMin, stickMax),
    );
  }

  /// How far this axis is from centre, as -1.0..1.0.
  double get xOffset => x / stickMax;
  double get yOffset => y / stickMax;

  @override
  Map<String, dynamic> toJson() => {
    'action': stick.name,
    'value': {'x': x, 'y': y},
  };
}

/// One reading of the controller's motion sensors, in the *controller* frame:
/// x to the player's right, y up, z towards the player — the same axes a
/// DualShock/DualSense reports. The sender converts from its own device frame.
///
/// Gyro is angular velocity in millidegrees per second, accelerometer is
/// milli-g, both [gyroMin]..[gyroMax] / [accelMin]..[accelMax].
final class MotionMessage extends Message {
  /// The `action` token. Not a button, trigger or stick name.
  static const action = 'motion';

  final int gx, gy, gz;
  final int ax, ay, az;

  const MotionMessage({
    this.gx = 0,
    this.gy = 0,
    this.gz = 0,
    this.ax = 0,
    this.ay = 0,
    this.az = 0,
  }) : assert(gx >= gyroMin && gx <= gyroMax),
       assert(gy >= gyroMin && gy <= gyroMax),
       assert(gz >= gyroMin && gz <= gyroMax),
       assert(ax >= accelMin && ax <= accelMax),
       assert(ay >= accelMin && ay <= accelMax),
       assert(az >= accelMin && az <= accelMax);

  factory MotionMessage.parse(Object? raw) {
    if (raw is! Map) {
      throw FormatException('Motion "value" must be an object, got: $raw');
    }
    int gyro(String key) => _asInt(raw[key], key, gyroMin, gyroMax);
    int accel(String key) => _asInt(raw[key], key, accelMin, accelMax);
    return MotionMessage(
      gx: gyro('gx'),
      gy: gyro('gy'),
      gz: gyro('gz'),
      ax: accel('ax'),
      ay: accel('ay'),
      az: accel('az'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'action': action,
    'value': {'gx': gx, 'gy': gy, 'gz': gz, 'ax': ax, 'ay': ay, 'az': az},
  };
}
