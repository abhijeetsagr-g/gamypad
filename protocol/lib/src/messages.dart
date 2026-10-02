import 'dart:convert';

import 'vocabulary/buttons.dart';

// Send This Messages Instead of Manually Writing Json Between Server and Client

/// Messages exactly as they are on the wire today (JSON).
///
/// Wire shapes, captured as-is:
///   Ping:     {"type":"ping"}
///   Pong:     {"type":"pong"}
///   Button:   {"action":"press"|"release","btn":"A"}
///   Stick:    {"action":"leftStick"|"rightStick","value":{"x":"..","y":".."}}
///   Trigger:  {"action":"LT"|"RT","value":"0".."255"}

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
    final value = json['value'];
    final btn = json['btn'];
    return switch (action) {
      'press' => ButtonMessage(button: _parseButton(btn), pressed: true),
      'release' => ButtonMessage(button: _parseButton(btn), pressed: false),
      'LT' => TriggerMessage.parse(GamepadTrigger.LT, value),
      'RT' => TriggerMessage.parse(GamepadTrigger.RT, value),
      'leftStick' => StickMessage.parse(GamepadStick.leftStick, value),
      'rightStick' => StickMessage.parse(GamepadStick.rightStick, value),
      _ => throw FormatException('Unknown Action: $action'),
    };
  }
}

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

  ButtonMessage({required this.button, required this.pressed});

  @override
  Map<String, dynamic> toJson() {
    return {'action': pressed ? 'press' : 'release', 'btn': button.name};
  }
}

GamepadButton _parseButton(Object? name) {
  for (final b in GamepadButton.values) {
    if (b.name == name) return b;
  }
  throw FormatException('Unknown button: $name');
}

// Trigger Messages, not with value
final class TriggerMessage extends Message {
  final GamepadTrigger trigger;
  final int value;

  TriggerMessage({required this.trigger, required this.value})
    : assert(value >= 0 && value <= 255, 'Trigger Must Be Between 0 to 255');

  factory TriggerMessage.parse(GamepadTrigger trigger, Object? val) {
    final v = int.tryParse(val.toString());
    if (v == null || v < 0 || v > 255) {
      throw FormatException('Trigger "val" must be an int 0..255, got: $val');
    }
    return TriggerMessage(trigger: trigger, value: v);
  }

  double get normalized => value / 255;

  bool get pressed => value > 0;

  @override
  Map<String, dynamic> toJson() => {
    'action': trigger.name,
    'value': value.toString(),
  };
}

// Stick Message, with two string to find value
final class StickMessage extends Message {
  final GamepadStick stick;
  final String x;
  final String y;

  StickMessage({required this.stick, required this.x, required this.y});

  factory StickMessage.parse(GamepadStick stick, Object? val) {
    if (val is! Map) {
      throw FormatException('Stick "val" must be an object, got: $val');
    }
    final x = val['x'];
    final y = val['y'];
    if (x == null || y == null) {
      throw FormatException('Stick "val" needs both x and y: $val');
    }
    return StickMessage(stick: stick, x: x.toString(), y: y.toString());
  }

  double _parseDouble(String s) =>
      double.tryParse(s) ?? (throw FormatException('Not a number: $s'));

  double get xValue => _parseDouble(x);
  double get yValue => _parseDouble(y);

  @override
  Map<String, dynamic> toJson() => {
    'action': stick.name,
    'value': {'x': xValue, 'y': yValue},
  };
}
