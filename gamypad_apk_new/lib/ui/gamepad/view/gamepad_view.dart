import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/center_buttons.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/dpad.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/face_button.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/joystick.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/top_bar.dart';

class GamepadView extends StatefulWidget {
  const GamepadView({super.key});

  @override
  State<GamepadView> createState() => _GamepadViewState();
}

class _GamepadViewState extends State<GamepadView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Bar
              TopBar(),
              SizedBox(height: 40),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Joystick(isLeftStick: true, radius: 60),
                        const SizedBox(height: 30),
                        Dpad(),
                      ],
                    ),

                    // Center controls
                    Column(
                      children: [
                        CenterButtons(),
                        SizedBox(height: 30),
                        Joystick(isLeftStick: false, radius: 60),
                        // Joystick(isLeftStick: false),
                      ],
                    ),

                    // Right Side: Face Buttons
                    FaceButton(),
                  ],
                ),
              ),

              // Left Side
            ],
          ),
        ),
      ),
    );
  }
}
