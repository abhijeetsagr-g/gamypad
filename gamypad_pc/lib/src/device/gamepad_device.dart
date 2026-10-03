import 'package:protocol/protocol.dart';

abstract interface class GamepadDevice {
  void setButton(GamepadButton button, bool pressed);
  void setTrigger(GamepadTrigger trigger, int value);
  void setStick(GamepadStick stick, int x, int y);
  void dispose();
}
