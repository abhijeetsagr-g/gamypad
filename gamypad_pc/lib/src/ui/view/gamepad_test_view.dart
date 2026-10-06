import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/ui/state/providers.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/gamepad_test_palette.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_center_buttons.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_dpad.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_face_buttons.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_joystick.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/test_top_bar.dart';
import 'package:protocol/protocol.dart';

/// A full gamepad you can drive with the mouse, for exercising the PC side
/// without a phone.
///
/// Layout and feel are copied from gamypad_controller so values tuned there
/// behave the same. The difference is the plumbing: input goes straight into
/// [GamepadSession.apply] as protocol messages, with no socket, no JSON and no
/// button-code mapper in the way.
///
/// That makes this the test for the one part of the stack nothing else covers —
/// `UinputDevice`'s hat synthesis and its `.index` mapping. The native side is
/// already verified against the kernel; this verifies the Dart side above it.
///
/// Works with the server stopped: `apply` reaches the device regardless of
/// socket state.
class GamepadTestView extends ConsumerWidget {
  const GamepadTestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read, not watch: input flows one way, session state changes must not
    // rebuild this screen.
    final session = ref.read(sessionProvider);

    void button(GamepadButton which, bool pressed) {
      session.apply(ButtonMessage(button: which, pressed: pressed));
    }

    return Scaffold(
      backgroundColor: GamepadTestPalette.background,
      appBar: AppBar(
        backgroundColor: GamepadTestPalette.background,
        elevation: 0,
        title: const Text(
          'GAMEPAD TEST',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TestTopBar(
                onButton: button,
                onTrigger: (trigger, value) =>
                    session.apply(TriggerMessage(trigger: trigger, value: value)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TestJoystick(
                        stick: GamepadStick.leftStick,
                        radius: 60,
                        onChanged: (x, y) => session.apply(
                          StickMessage(
                            stick: GamepadStick.leftStick,
                            x: x,
                            y: y,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TestDpad(onChanged: button),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TestCenterButtons(onChanged: button),
                      const SizedBox(height: 30),
                      TestJoystick(
                        stick: GamepadStick.rightStick,
                        radius: 60,
                        onChanged: (x, y) => session.apply(
                          StickMessage(
                            stick: GamepadStick.rightStick,
                            x: x,
                            y: y,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TestFaceButtons(onChanged: button),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Drives the virtual pad directly — the server can stay off.',
                style: TextStyle(
                  color: GamepadTestPalette.label,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}