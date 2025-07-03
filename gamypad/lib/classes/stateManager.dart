import 'dart:ui';

import 'package:flutter/widgets.dart';

class Statemanager {
  Statemanager({
    this.up = false,
    this.down = false,
    this.left = false,
    this.right = false,
  });

  final bool up;
  final bool down;
  final bool left;
  final bool right;

  // Check If The Actual Botton Value
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Statemanager &&
        other.up == up &&
        other.down == down &&
        other.left == left &&
        other.right == right;
  }

  @override
  int get hashCode =>
      up.hashCode ^ down.hashCode ^ left.hashCode ^ right.hashCode;
}

void updateDirections(
  Offset localPosition,
  Size containerSize,
  ValueNotifier<Statemanager> activeDirections,
  onDirectionChanged,
) {
  bool up = false;
  bool down = false;
  bool left = false;
  bool right = false;

  final centerX = containerSize.width / 2;
  final centerY = containerSize.height / 2;

  final deadZoneX = containerSize.width * 0.2;
  final deadZoneY = containerSize.height * 0.2;

  // Check vertical directions
  if (localPosition.dy < centerY - deadZoneY) {
    up = true;
  } else if (localPosition.dy > centerY + deadZoneY) {
    down = true;
  }

  // Check horizontal directions
  if (localPosition.dx < centerX - deadZoneX) {
    left = true;
  } else if (localPosition.dx > centerX + deadZoneX) {
    right = true;
  }

  final newDirections = Statemanager(
    up: up,
    down: down,
    left: left,
    right: right,
  );
  // Update the state if it has changed
  if (newDirections != activeDirections.value) {
    activeDirections.value = newDirections;
    onDirectionChanged?.call(newDirections);

    //TODO: SENDJSON
    if (newDirections.up) {
      print("SENDJSON up is pressed");
    }
    if (newDirections.left) {
      print("SENDJSON left is pressed");
    }
    if (newDirections.right) {
      print("SENDJSON right is pressed");
    }
    if (newDirections.down) {
      print("SENDJSON down is pressed");
    }
  }
}

void clearDirections(activeDirections, onDirectionChanged) {
  final previous = activeDirections.value;
  final newDirections = Statemanager();
  if (newDirections != activeDirections.value) {
    activeDirections.value = newDirections;
    onDirectionChanged?.call(newDirections);
    //TODO: SENDJSON
    if (previous.up) {
      print("SENDJSON up is released");
    }
    if (previous.left) {
      print("SENDJSON left is released");
    }
    if (previous.right) {
      print("SENDJSON right is released");
    }
    if (previous.down) {
      print("SENDJSON down is released");
    }
  }
}
