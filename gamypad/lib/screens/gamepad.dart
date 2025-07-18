import 'package:flutter/material.dart';
import 'package:gamypad/widget/buttons.dart';
import 'package:gamypad/widget/front_input.dart';
import 'package:gamypad/widget/joystick.dart';

class Gamepad extends StatefulWidget {
  Gamepad({super.key});

  final Color bodyColor = Color.fromARGB(255, 238, 238, 238);
  final Color btnColor = Color.fromARGB(255, 247, 155, 114);
  final Color triggerColor = Color.fromARGB(255, 233, 211, 185);
  final Color extraColor = Color.fromARGB(255, 221, 221, 221);

  @override
  State<Gamepad> createState() => _GamepadState();
}

class _GamepadState extends State<Gamepad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bodyColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Buttons(
                      size: Size(130, 65),
                      btnColor: widget.triggerColor,
                      label: "LT",
                    ),
                    SizedBox(height: 10),
                    Buttons(
                      size: Size(130, 65),
                      btnColor: widget.triggerColor,
                      label: "LB",
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Buttons(
                      size: Size(70, 45),
                      btnColor: widget.extraColor,
                      label: "SELECT",
                    ),
                    SizedBox(width: 10),
                    Buttons(
                      size: Size(70, 45),
                      btnColor: widget.extraColor,
                      label: "START",
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Buttons(
                        size: Size(130, 65),
                        btnColor: widget.triggerColor,
                        label: "RT",
                      ),
                      SizedBox(height: 10),
                      Buttons(
                        size: Size(130, 65),
                        btnColor: widget.triggerColor,
                        label: "RB",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FrontInput(
                  alignRight: true,
                  btnSize: Size(60, 50),
                  btnColor: Colors.grey,
                  bodyColor: widget.bodyColor,
                  labels: ["UP", "DOWN", "LEFT", "RIGHT"],
                ),

                //                Joystick(joystickRadius: 75, label: "L THUMBSTICK"),

                //              Joystick(joystickRadius: 60, label: "R THUMBSTICK"),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FrontInput(
                    alignRight: false,
                    btnSize: Size(60, 50),
                    btnColor: widget.btnColor,
                    bodyColor: widget.bodyColor,
                    labels: ["Y", "A", "X", "B"],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
