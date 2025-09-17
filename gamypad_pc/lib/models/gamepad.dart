import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

class Gamepad {
  late Pointer<Void> _ptr;
  late DynamicLibrary _dylib;

  // Private FFI functions
  late void Function(Pointer<Void>) _gamepadDelete;
  late void Function(Pointer<Void>, Pointer<Utf8>) _gamepadPress;
  late void Function(Pointer<Void>, Pointer<Utf8>) _gamepadRelease;

  Gamepad._(); // Private constructor

  // Async factory to initialize the library from assets
  static Future<Gamepad> create() async {
    final gamepad = Gamepad._();

    // Load library from assets
    final bytes = await rootBundle.load('assets/libgamepad.so');
    final tempDir = Directory.systemTemp.createTempSync();
    final libFile = File(p.join(tempDir.path, 'libgamepad.so'));
    await libFile.writeAsBytes(bytes.buffer.asUint8List());
    gamepad._dylib = DynamicLibrary.open(libFile.path);

    // Lookup FFI functions
    final gamepadNew = gamepad._dylib
        .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
          'Gamepad_new',
        );

    gamepad._gamepadDelete = gamepad._dylib
        .lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)
        >('Gamepad_delete');

    gamepad._gamepadPress = gamepad._dylib
        .lookupFunction<
          Void Function(Pointer<Void>, Pointer<Utf8>),
          void Function(Pointer<Void>, Pointer<Utf8>)
        >('Gamepad_pressButton');

    gamepad._gamepadRelease = gamepad._dylib
        .lookupFunction<
          Void Function(Pointer<Void>, Pointer<Utf8>),
          void Function(Pointer<Void>, Pointer<Utf8>)
        >('Gamepad_releaseButton');

    // Initialize pointer
    gamepad._ptr = gamepadNew();

    return gamepad;
  }

  // Dispose method
  void dispose() {
    _gamepadDelete(_ptr);
  }

  // Press a button
  void press(String button) {
    final btnPtr = button.toNativeUtf8();
    _gamepadPress(_ptr, btnPtr);
    calloc.free(btnPtr);
  }

  // Release a button
  void release(String button) {
    final btnPtr = button.toNativeUtf8();
    _gamepadRelease(_ptr, btnPtr);
    calloc.free(btnPtr);
  }
}
