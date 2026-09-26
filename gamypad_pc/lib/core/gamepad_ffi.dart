import 'dart:ffi';

import 'package:ffi/ffi.dart';

// Bind to libgamepad.so
final DynamicLibrary _lib = DynamicLibrary.open('libgamepad.so');

// C Function typedefs
typedef _GamepadNewC = Pointer<Void> Function();
typedef _GamepadDeleteC = Void Function(Pointer<Void>);
typedef _GamepadPressKeyC = Void Function(Pointer<Void>, Pointer<Utf8>);
typedef _GamepadReleaseKeyC = Void Function(Pointer<Void>, Pointer<Utf8>);
typedef _GamepadSetAxisC = Void Function(Pointer<Void>, Int32, Int32, Int32);
typedef _GamepadSetTriggerC = Void Function(Pointer<Void>, Int32, Int32);
typedef _GamepadSetDpadC = Void Function(Pointer<Void>, Int32, Int32);

// Dart typedefs
typedef GamepadNew = Pointer<Void> Function();
typedef GamepadDelete = void Function(Pointer<Void>);
typedef GamepadPressKey = void Function(Pointer<Void>, Pointer<Utf8>);
typedef GamepadReleaseKey = void Function(Pointer<Void>, Pointer<Utf8>);
typedef GamepadSetAxis = void Function(Pointer<Void>, int, int, int);
typedef GamepadSetTrigger = void Function(Pointer<Void>, int, int);
typedef GamepadSetDpad = void Function(Pointer<Void>, int, int);

// Use this function to run those C++ functions
final GamepadNew gamepadNew = _lib.lookupFunction<_GamepadNewC, GamepadNew>(
  'Gamepad_new',
);
final GamepadDelete gamepadDelete = _lib
    .lookupFunction<_GamepadDeleteC, GamepadDelete>('Gamepad_delete');
final GamepadPressKey gamepadPressKey = _lib
    .lookupFunction<_GamepadPressKeyC, GamepadPressKey>('Gamepad_pressKey');
final GamepadReleaseKey gamepadReleaseKey = _lib
    .lookupFunction<_GamepadReleaseKeyC, GamepadReleaseKey>(
      'Gamepad_releaseKey',
    );
final GamepadSetAxis gamepadSetAxis = _lib
    .lookupFunction<_GamepadSetAxisC, GamepadSetAxis>('Gamepad_setAxis');
final GamepadSetTrigger gamepadSetTrigger = _lib
    .lookupFunction<_GamepadSetTriggerC, GamepadSetTrigger>(
      'Gamepad_setTrigger',
    );
final GamepadSetDpad gamepadSetDpad = _lib
    .lookupFunction<_GamepadSetDpadC, GamepadSetDpad>('Gamepad_setDpad');
