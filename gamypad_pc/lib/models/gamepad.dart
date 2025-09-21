import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'gamepad_ffi.dart';

class Gamepad {
  final Pointer<Void> _handle;
  Gamepad() : _handle = gamepadNew();

  void pressKey(String key) {
    final keyC = key.toNativeUtf8();
    gamepadPressKey(_handle, keyC);
    calloc.free(keyC); // Free up memory from Dart's managed memory
  }

  void releaseKey(String key) {
    final keyC = key.toNativeUtf8();
    gamepadReleaseKey(_handle, keyC);
    calloc.free(keyC);
  }

  void setAxis(int type, int valueX, int valueY) {
    gamepadSetAxis(_handle, type, valueX, valueY);
  }

  // 1 is press, 0 is release
  void setTrigger(int code, int value) {
    int sendValue = value == 1 ? 255 : 0;
    print(sendValue);
    gamepadSetTrigger(_handle, code, sendValue);
  }

  void dispose() {
    gamepadDelete(_handle);
  }
}
