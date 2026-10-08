import 'dart:ui';

import 'package:protocol/protocol.dart';

import 'controller_layout.dart';
import 'pad_element.dart';

abstract final class DefaultLayout {
  static const Size canvasSize = Size(800, 400);
  static final ControllerLayout layout = _build();

  static ControllerLayout _build() {
    Rect at(double x, double y, double w, double h) =>
        Rect.fromLTWH(x, y, w, h);

    const topBarY = 18.0;
    const triggerHeight = TriggerElement.fixedHeight;
    const shoulderHeight = 44.0;
    final shoulderTop = topBarY + (triggerHeight - shoulderHeight) / 2;

    const shoulder = Size(92, shoulderHeight);

    const stickSide = 116.0;
    const lowerRowTop = 254.0;

    return ControllerLayout(
      name: "Default",
      authoredSize: canvasSize,
      elements: {
        'LT': TriggerElement(
          trigger: GamepadTrigger.LT,
          rect: at(26, topBarY, TriggerElement.fixedWidth, triggerHeight),
        ),
        'LB': ButtonElement(
          button: GamepadButton.LB,
          rect: at(172, shoulderTop, shoulder.width, shoulder.height),
        ),
        'GUIDE': ButtonElement(
          button: GamepadButton.GUIDE,
          rect: at(354, shoulderTop, shoulder.width, shoulder.height),
        ),
        'RB': ButtonElement(
          button: GamepadButton.RB,
          rect: at(536, shoulderTop, shoulder.width, shoulder.height),
        ),
        'RT': TriggerElement(
          trigger: GamepadTrigger.RT,
          rect: at(642, topBarY, TriggerElement.fixedWidth, triggerHeight),
        ),

        'dpad': DpadElement(rect: at(46, lowerRowTop, stickSide, stickSide)),

        'SELECT': ButtonElement(
          button: GamepadButton.SELECT,
          rect: at(295, 106, 96, shoulderHeight),
        ),
        'START': ButtonElement(
          button: GamepadButton.START,
          rect: at(409, 106, 96, shoulderHeight),
        ),
        'LS': ButtonElement(
          button: GamepadButton.LS,
          rect: at(295, 166, 96, shoulderHeight),
        ),
        'RS': ButtonElement(
          button: GamepadButton.RS,
          rect: at(409, 166, 96, shoulderHeight),
        ),

        'leftStick': StickElement(
          stick: GamepadStick.leftStick,
          rect: at(46, 96, 116, 116),
        ),
        'rightStick': StickElement(
          stick: GamepadStick.rightStick,
          rect: at(480, lowerRowTop, stickSide, stickSide),
        ),

        'X': ButtonElement(button: GamepadButton.X, rect: at(612, 172, 56, 56)),
        'B': ButtonElement(button: GamepadButton.B, rect: at(732, 172, 56, 56)),
        'Y': ButtonElement(button: GamepadButton.Y, rect: at(672, 112, 56, 56)),
        'A': ButtonElement(button: GamepadButton.A, rect: at(672, 232, 56, 56)),
      },
    );
  }
}
