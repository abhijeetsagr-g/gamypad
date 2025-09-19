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

  void dispose() {
    gamepadDelete(_handle);
  }
}
