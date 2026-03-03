import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/dpad.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/gamepad_button.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/joystick.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  GamepadButton(
                    btnName: "LT",
                    width: 140,
                    height: 40,
                    btnCode: "LT",
                  ),
                  SizedBox(width: 10),
                  GamepadButton(
                    btnName: "LB",
                    width: 140,
                    height: 40,
                    btnCode: "LB",
                  ),
                  SizedBox(width: 20),
                  GamepadButton(
                    btnName: "Guide",
                    width: 120,
                    height: 40,
                    btnCode: "GUIDE",
                  ),
                  SizedBox(width: 20),
                  GamepadButton(
                    btnName: "RB",
                    width: 140,
                    height: 40,
                    btnCode: "RB",
                  ),
                  SizedBox(width: 10),
                  GamepadButton(
                    btnName: "RT",
                    width: 140,
                    height: 40,
                    btnCode: "RT",
                  ),
                ],
              ),

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
                        Row(
                          children: [
                            GamepadButton(
                              btnName: "Back",
                              width: 100,
                              height: 40,
                              btnCode: "SELECT",
                            ),
                            SizedBox(width: 10),
                            GamepadButton(
                              btnName: "Start",
                              width: 100,
                              height: 40,
                              btnCode: "START",
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            GamepadButton(
                              btnName: "LS",
                              width: 100,
                              height: 40,
                              btnCode: "LS",
                            ),
                            SizedBox(width: 10),
                            GamepadButton(
                              btnName: "RS",
                              width: 100,
                              height: 40,
                              btnCode: "RS",
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Joystick(isLeftStick: false, radius: 60),
                        // Joystick(isLeftStick: false),
                      ],
                    ),

                    // Right Side: Face Buttons
                    Column(
                      children: [
                        SizedBox(height: 60),
                        Column(
                          children: [
                            // Y on top
                            GamepadButton(
                              btnName: "Y",
                              width: 100,
                              height: 60,
                              btnCode: "Y",
                            ),
                            SizedBox(height: 10),
                            // X left + B right
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GamepadButton(
                                  btnName: "X",
                                  width: 100,
                                  height: 60,
                                  btnCode: "X",
                                ),
                                SizedBox(width: 60),
                                GamepadButton(
                                  btnName: "B",
                                  width: 100,
                                  height: 60,
                                  btnCode: "B",
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // A bottom
                            GamepadButton(
                              btnName: "A",
                              width: 100,
                              height: 60,
                              btnCode: "A",
                            ),
                          ],
                        ),
                      ],
                    ),
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
