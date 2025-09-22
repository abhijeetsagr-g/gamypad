import 'dart:convert';
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

  void setDpad(int xValue, int yValue) {
    gamepadSetDpad(_handle, xValue, yValue);
  }

  void dispose() {
    gamepadDelete(_handle);
  }

  // Map D-pad button names to (x, y) values
  final Map<String, List<int>> dpadMap = {
    "UP": [0, -1],
    "DOWN": [0, 1],
    "LEFT": [-1, 0],
    "RIGHT": [1, 0],
  };

  void handleClient(String data) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(data);
      final btn = decoded['btn'];
      switch (decoded['action']) {
        case 'press':
          if (dpadMap.containsKey(decoded['btn'])) {
            int xValue = dpadMap[decoded['btn']]!.first;
            int yValue = dpadMap[decoded['btn']]!.last;
            setDpad(xValue, yValue);
          } else {
            pressKey(decoded['btn']);
          }
          break;
        case 'release':
          if (dpadMap.containsKey(decoded['btn'])) {
            setDpad(0, 0);
          } else {
            releaseKey(btn);
          }
          break;
        case 'leftStick':
          int valueX = int.parse(decoded['btn']['x']);
          int valueY = int.parse(decoded['btn']['y']);
          setAxis(1, valueX, valueY);
          break;
        case 'rightStick':
          int valueX = int.parse(decoded['btn']['x']);
          int valueY = int.parse(decoded['btn']['y']);
          setAxis(0, valueX, valueY);
          break;
        case 'RT':
          int value = int.parse(decoded['btn']);
          setTrigger(0, value);
          break;
        case 'LT':
          int value = int.parse(decoded['btn']);
          setTrigger(1, value);
          break;
      }
    } catch (e) {
      print(e);
    }
  }
}
