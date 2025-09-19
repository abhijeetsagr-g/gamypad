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

  void setAxis(int code, int value) {
    gamepadSetAxis(_handle, code, value);
  }

  void dispose() {
    gamepadDelete(_handle);
  }
}
