import 'dart:ui';

import 'package:protocol/protocol.dart';

import 'controller_layout.dart';
import 'pad_element.dart';

/// Today's pad, as constants, and the target of reset.
///
/// This is the layout that was previously hardcoded across the widget tree —
/// `120 × 40` d-pad arms, `100 × 60` face buttons, `LT 160` `LB 140` — with the
/// numbers pulled out into data. Nothing about it looks different; the
/// difference is that it is now editable and it is not scattered across five
/// widgets.
///
/// Built once: the editor hands back copies, so a shared instance is safe to
/// treat as the pristine original.
abstract final class DefaultLayout {
  /// 2:1, the shape of a controller, and close enough to a phone in landscape
  /// that the uniform scale leaves very little letterbox.
  static const Size canvasSize = Size(800, 400);

  /// The sixteen elements, all present, none overlapping.
  static final ControllerLayout layout = _build();

  static ControllerLayout _build() {
    Rect at(double x, double y, double w, double h) =>
        Rect.fromLTWH(x, y, w, h);

    // Top bar. The triggers and the shoulders are centred on the same line even
    // though the triggers are taller, because travel is read off the height and
    // a trigger that lined up with the buttons would look smaller than it is.
    const topBarY = 18.0;
    const triggerHeight = TriggerElement.fixedHeight;
    const shoulderHeight = 44.0;
    final shoulderTop = topBarY + (triggerHeight - shoulderHeight) / 2;

    const shoulder = Size(92, shoulderHeight);

    // The lower row: d-pad and right stick are the same size and share a bottom
    // edge, lifted clear of the canvas edge. Under a cover scale the visible
    // slice of an 800×400 canvas on a wide landscape phone is only the middle
    // ~343 authored px, so anything below y≈371 is cropped off-screen.
    const stickSide = 116.0;
    const lowerRowTop = 254.0;

    return ControllerLayout(
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
        // Centred on the canvas, which is also where a real controller puts it.
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

        // D-pad under the left stick, as on the hardware.
        'dpad': DpadElement(rect: at(46, lowerRowTop, stickSide, stickSide)),

        // Centre block, centred horizontally: 96 + 18 + 96 = 210, so 295..505
        // leaves 295 either side.
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

        // Face diamond. Offset 60 from centre with a 56 button leaves a 4px
        // diagonal gap and a 64px span across, which is close to the real thing:
        // on hardware the button centres sit further apart than the buttons are
        // wide.
        'X': ButtonElement(button: GamepadButton.X, rect: at(612, 172, 56, 56)),
        'B': ButtonElement(button: GamepadButton.B, rect: at(732, 172, 56, 56)),
        'Y': ButtonElement(button: GamepadButton.Y, rect: at(672, 112, 56, 56)),
        'A': ButtonElement(button: GamepadButton.A, rect: at(672, 232, 56, 56)),
      },
    );
  }
}
