// Send Message Using This Enums
//
// The constant names below ARE the wire tokens, not Dart style. Renaming one is
// a breaking protocol change and must be mirrored in the `keyMap` of
// `gamypad_pc/native/Gamepad.cpp`.
// ignore_for_file: constant_identifier_names

enum GamepadButton {
  A,
  B,
  X,
  Y,
  UP,
  DOWN,
  LEFT,
  RIGHT,
  LB,
  RB,
  START,
  SELECT,
  LS,
  RS,
  GUIDE,
}

enum GamepadTrigger { LT, RT }

enum GamepadStick { leftStick, rightStick }
