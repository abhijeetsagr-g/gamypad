import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';
import 'package:protocol/protocol.dart';

/// A log row split into a control name and a value, so [LogRow] can style
/// them independently.
class LogParts {
  const LogParts(this.name, this.value, {this.valueColor});

  final String name;
  final String value;
  final Color? valueColor;
}

/// Formats a [Message] for display. Exhaustive over the sealed [Message]
/// hierarchy, so a new message type is a compile error here.
LogParts describe(Message message) => switch (message) {
  ButtonMessage(:final button, :final pressed) => LogParts(
    button.name,
    pressed ? 'true' : 'false',
    valueColor: pressed ? ColorPalette.accent : ColorPalette.muted,
  ),
  TriggerMessage(:final trigger, :final value, :final normalized) => LogParts(
    trigger.name,
    '$value  (${normalized.toStringAsFixed(2)})',
    valueColor: ColorPalette.accent,
  ),
  StickMessage(:final stick, :final x, :final y) => LogParts(
    stick.name,
    'x: $x  y: $y',
    valueColor: ColorPalette.accent,
  ),
  MotionMessage(
    :final gx,
    :final gy,
    :final gz,
    :final ax,
    :final ay,
    :final az,
  ) =>
    LogParts(
      'motion',
      // Raw wire values: gyro in millidegrees/s, accelerometer in milli-g.
      'gyro  x:${_pad(gx)} y:${_pad(gy)} z:${_pad(gz)}   '
      'accel x:${_pad(ax)} y:${_pad(ay)} z:${_pad(az)}',
      valueColor: ColorPalette.accent,
    ),
  Ping() => const LogParts('PING', '', valueColor: ColorPalette.muted),
  Pong() => const LogParts('PONG', '', valueColor: ColorPalette.muted),
};

String _pad(int v) => v.toString().padLeft(8);
