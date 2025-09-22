import 'package:flutter/material.dart';
import 'package:gamypad_apk/widgets/default_dpad.dart';
import 'package:gamypad_apk/widgets/default_top_layer.dart';
import 'package:gamypad_apk/widgets/gamepad_button.dart';
import 'package:gamypad_apk/widgets/joystick.dart';

class GamepadPage extends StatelessWidget {
  const GamepadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            // Top row: LT, LB, Guide, RB, RT
            DefaultTopLayer(),
            SizedBox(height: 40),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side
                  Column(
                    children: [
                      Joystick(isLeftStick: true),
                      SizedBox(height: 40),
                      // D-Pad
                      DefaultDpad(),
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
                      Joystick(isLeftStick: false),
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
          ],
        ),
      ),
    );
  }
}
