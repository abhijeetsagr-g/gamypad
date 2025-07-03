import 'package:flutter/material.dart';
import 'package:gamypad/widgets/game_button.dart';
import 'package:gamypad/widgets/dpad.dart';

class Gamepad extends StatefulWidget {
  const Gamepad({super.key});

  @override
  State<Gamepad> createState() => _GamepadState();
}

class _GamepadState extends State<Gamepad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side: LT & LB
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 2, 0, 0),
                      child: GameButtons(
                        label: "LT",
                        btnColor: Colors.white60,
                        btnSize: Size(130, 60),
                      ),
                    ),

                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 2),
                      child: GameButtons(
                        label: "LB",
                        btnColor: Colors.white60,
                        btnSize: Size(130, 60),
                      ),
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GameButtons(
                      label: "SELECT",
                      btnColor: Colors.white,
                      btnSize: Size(20, 20),
                    ),

                    SizedBox(width: 20),

                    GameButtons(
                      label: "GUIDE",
                      btnColor: Colors.green,
                      btnSize: Size(40, 30),
                    ),

                    SizedBox(width: 20),

                    GameButtons(
                      label: "START",
                      btnColor: Colors.greenAccent,
                      btnSize: Size(20, 20),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 2, 10, 0),
                      child: GameButtons(
                        label: "LT",
                        btnColor: Colors.white60,
                        btnSize: Size(130, 60),
                      ),
                    ),

                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 2),
                      child: GameButtons(
                        label: "LB",
                        btnColor: Colors.white60,
                        btnSize: Size(130, 60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(children: [Dpad()]),
          ],
        ),
      ),
    );
  }
}
