import 'dart:math' as math;
import 'dart:ui';

import 'package:protocol/protocol.dart';

final class MinMax {
  final double min;
  final double? max;

  const MinMax(this.min, [this.max]);

  const MinMax.exact(double value) : min = value, max = value;
  static const unbounded = MinMax(0, null);

  bool contains(double value) => value >= min && (max == null || value <= max!);

  @override
  bool operator ==(Object other) =>
      other is MinMax && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'MinMax($min..${max ?? '∞'})';
}

sealed class PadElement {
  const PadElement(this.rect);

  final Rect rect;

  static const ids = <String>[
    'LT',
    'LB',
    'GUIDE',
    'RB',
    'RT',
    'dpad',
    'SELECT',
    'START',
    'LS',
    'RS',
    'leftStick',
    'rightStick',
    'X',
    'B',
    'Y',
    'A',
  ];

  static PadElement fromId(String id, Rect rect) {
    if (id == DpadElement.elementId) return DpadElement(rect: rect);

    if (_dpadDirections.contains(id)) {
      throw FormatException(
        '"$id" belongs to the dpad group and is not addressable on its own',
      );
    }

    for (final button in GamepadButton.values) {
      if (button.name == id) return ButtonElement(button: button, rect: rect);
    }
    for (final trigger in GamepadTrigger.values) {
      if (trigger.name == id) {
        return TriggerElement(trigger: trigger, rect: rect);
      }
    }
    for (final stick in GamepadStick.values) {
      if (stick.name == id) return StickElement(stick: stick, rect: rect);
    }

    throw FormatException('Unknown pad element id: "$id"');
  }

  /// Direction buttons, which live inside [DpadElement] rather than beside it.
  static const _dpadDirections = {'UP', 'DOWN', 'LEFT', 'RIGHT'};

  String get id;

  bool get movable => true;
  bool get resizable => true;

  MinMax get minSize;
  MinMax get maxSize;

  /// Pulls [value] into this element's legal range.
  double fit(double value) =>
      value.clamp(minSize.min, maxSize.max ?? double.infinity);

  /// The size this element would take for a drag of [width] × [height].
  ///
  /// Square types collapse the two into one side; fixed types ignore the drag
  /// entirely and keep their own.
  Size resolveSize(double width, double height);

  /// [requested] with this element's size rules applied, then kept inside
  /// [canvas].
  ///
  /// Total, and free of overlap rules: an editor drag wants to see the position
  /// it asked for even while it is invalid, so rejection happens one layer up.
  Rect constrain(Rect requested, Size canvas) {
    final size = resolveSize(requested.width, requested.height);

    // A canvas smaller than the element clamps to zero rather than to a
    // negative range, which `clamp` would treat as inverted.
    final maxX = math.max(0.0, canvas.width - size.width);
    final maxY = math.max(0.0, canvas.height - size.height);

    return Rect.fromLTWH(
      requested.left.clamp(0.0, maxX),
      requested.top.clamp(0.0, maxY),
      size.width,
      size.height,
    );
  }

  PadElement withRect(Rect rect);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

final class ButtonElement extends PadElement {
  const ButtonElement({required this.button, required Rect rect}) : super(rect);

  final GamepadButton button;

  @override
  String get id => button.name;

  @override
  MinMax get minSize => const MinMax(44);

  @override
  MinMax get maxSize => MinMax.unbounded;

  @override
  Size resolveSize(double width, double height) =>
      Size(fit(width), fit(height));

  @override
  PadElement withRect(Rect rect) => ButtonElement(button: button, rect: rect);

  @override
  bool operator ==(Object other) =>
      other is ButtonElement && other.button == button && other.rect == rect;

  @override
  int get hashCode => Object.hash(button, rect);

  @override
  String toString() => 'ButtonElement($button, $rect)';
}

final class DpadElement extends PadElement {
  const DpadElement({required Rect rect}) : super(rect);

  static const elementId = 'dpad';

  @override
  String get id => elementId;

  @override
  MinMax get minSize => const MinMax(96);

  @override
  MinMax get maxSize => MinMax.unbounded;

  @override
  Size resolveSize(double width, double height) {
    final side = fit(math.max(width, height));
    return Size(side, side);
  }

  @override
  PadElement withRect(Rect rect) => DpadElement(rect: rect);

  @override
  bool operator ==(Object other) => other is DpadElement && other.rect == rect;

  @override
  int get hashCode => rect.hashCode;

  @override
  String toString() => 'DpadElement($rect)';
}

final class StickElement extends PadElement {
  const StickElement({required this.stick, required Rect rect}) : super(rect);

  final GamepadStick stick;

  @override
  String get id => stick.name;

  @override
  MinMax get minSize => const MinMax(88);

  @override
  MinMax get maxSize => MinMax.unbounded;

  @override
  Size resolveSize(double width, double height) {
    final side = fit(math.max(width, height));
    return Size(side, side);
  }

  @override
  PadElement withRect(Rect rect) => StickElement(stick: stick, rect: rect);

  @override
  bool operator ==(Object other) =>
      other is StickElement && other.stick == stick && other.rect == rect;

  @override
  int get hashCode => Object.hash(stick, rect);

  @override
  String toString() => 'StickElement($stick, $rect)';
}

/// An analog trigger: slide up for more travel.
final class TriggerElement extends PadElement {
  const TriggerElement({required this.trigger, required Rect rect})
    : super(rect);

  final GamepadTrigger trigger;

  /// The size is a constant, not a stored value, so travel is the same on every
  /// layout the user has ever had.
  static const double fixedWidth = 132;
  static const double fixedHeight = 48;
  static const Size fixedSize = Size(fixedWidth, fixedHeight);

  @override
  String get id => trigger.name;

  @override
  bool get resizable => false;

  /// Height is the dimension travel comes from, so it is the one quoted here.
  @override
  MinMax get minSize => const MinMax.exact(fixedHeight);

  @override
  MinMax get maxSize => minSize;

  @override
  Size resolveSize(double width, double height) => fixedSize;

  @override
  PadElement withRect(Rect rect) =>
      TriggerElement(trigger: trigger, rect: rect);

  @override
  bool operator ==(Object other) =>
      other is TriggerElement && other.trigger == trigger && other.rect == rect;

  @override
  int get hashCode => Object.hash(trigger, rect);

  @override
  String toString() => 'TriggerElement($trigger, $rect)';
}
