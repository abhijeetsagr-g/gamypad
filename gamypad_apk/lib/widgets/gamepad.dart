import 'package:flutter/material.dart';
import 'package:gamypad_apk/widgets/gamepad_button.dart';
import 'package:gamypad_apk/widgets/joystick.dart';

class Gamepad extends StatefulWidget {
  const Gamepad({super.key});

  @override
  State<Gamepad> createState() => _GamepadState();
}

class _GamepadState extends State<Gamepad> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row: LT, LB, Guide, RB, RT
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

          const SizedBox(height: 40),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side
                Column(
                  children: [
                    const Joystick(isLeftStick: true),
                    const SizedBox(height: 40),
                    // D-Pad
                    Column(
                      children: const [
                        GamepadButton(
                          btnName: "",
                          width: 120,
                          height: 40,
                          btnCode: "UP",
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GamepadButton(
                              btnName: "",
                              width: 120,
                              height: 40,
                              btnCode: "LEFT",
                            ),
                            SizedBox(width: 40),
                            GamepadButton(
                              btnName: "",
                              width: 120,
                              height: 40,
                              btnCode: "RIGHT",
                            ),
                          ],
                        ),
                        GamepadButton(
                          btnName: "",
                          width: 120,
                          height: 40,
                          btnCode: "DOWN",
                        ),
                      ],
                    ),
                  ],
                ),

                // Center controls
                Column(
                  children: [
                    Row(
                      children: const [
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
                    const SizedBox(height: 10),
                    Row(
                      children: const [
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
                    const Spacer(),
                    const Joystick(isLeftStick: false),
                  ],
                ),

                // Right Side: Face Buttons
                Column(
                  children: [
                    SizedBox(height: 60),
                    Column(
                      children: [
                        // Y on top
                        const GamepadButton(
                          btnName: "Y",
                          width: 100,
                          height: 60,
                          btnCode: "Y",
                        ),
                        const SizedBox(height: 10),
                        // X left + B right
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
                        const SizedBox(height: 10),
                        // A bottom
                        const GamepadButton(
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
    );
  }
}
