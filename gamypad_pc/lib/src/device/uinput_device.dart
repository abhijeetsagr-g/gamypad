import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:gamypad_pc/src/device/gamepad_device.dart';
import 'package:protocol/protocol.dart';

import 'gamepad_ffi.dart';

class UinputDevice implements GamepadDevice {
  UinputDevice() : _handle = gamepadNew();

  final Pointer<Void> _handle;
  bool _disposed = false;

  // The d-pad is driven through the hat axes (ABS_HAT0X / ABS_HAT0Y) rather
  // than BTN_DPAD_* keys, matching how a real Xbox 360 controller reports it
  // under the Linux xpad driver. A hat takes two axes at once, so each
  // direction is remembered here and the pair is recomputed on every change.
  //
  // This state is derived from button messages, which are themselves state:
  // a lost "release" packet leaves a direction stuck on. Coalescing and
  // periodic state re-sends on the controller side are what prevent that.
  bool _up = false;
  bool _down = false;
  bool _left = false;
  bool _right = false;

  static const _dpad = {
    GamepadButton.UP,
    GamepadButton.DOWN,
    GamepadButton.LEFT,
    GamepadButton.RIGHT,
  };

  @override
  void setButton(GamepadButton button, bool pressed) {
    if (_dpad.contains(button)) {
      switch (button) {
        case GamepadButton.UP:
          _up = pressed;
        case GamepadButton.DOWN:
          _down = pressed;
        case GamepadButton.LEFT:
          _left = pressed;
        case GamepadButton.RIGHT:
          _right = pressed;
        default:
          break; // unreachable: guarded by _dpad
      }
      // -1 = up/left, 0 = neutral, 1 = down/right. Both axes are set together,
      // so opposite directions held at once neutralise cleanly and diagonals
      // come out as a single (x, y) pair.
      gamepadSetDpad(
        _handle,
        (_right ? 1 : 0) - (_left ? 1 : 0),
        (_down ? 1 : 0) - (_up ? 1 : 0),
      );
      return;
    }

    final key = button.name.toNativeUtf8();
    try {
      pressed ? gamepadPressKey(_handle, key) : gamepadReleaseKey(_handle, key);
    } finally {
      malloc.free(key);
    }
  }

  @override
  void setStick(GamepadStick stick, int x, int y) {
    gamepadSetAxis(_handle, stick.index, x, y);
  }

  @override
  void setTrigger(GamepadTrigger trigger, int value) {
    gamepadSetTrigger(_handle, trigger.index, value);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // Release everything still held, so the virtual pad does not come back
    // with a stuck direction or button after a reconnect.
    if (_up || _down || _left || _right) {
      _up = _down = _left = _right = false;
      gamepadSetDpad(_handle, 0, 0);
    }
    gamepadDelete(_handle);
  }
}
