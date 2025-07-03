import 'package:flutter/material.dart';
import 'package:gamypad/client.dart';
import 'package:gamypad/widgets/dpad.dart';
import 'package:gamypad/widgets/game_button.dart';
import 'package:gamypad/widgets/facebutton.dart';

class Gamepad extends StatefulWidget {
  const Gamepad({super.key});

  @override
  State<Gamepad> createState() => _GamepadState();
}

class _GamepadState extends State<Gamepad> {
  @override
  void dispose() {
    super.dispose();
    if (socket != null) {
      disconnectServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                        btnColor: Colors.grey.shade600,
                        btnSize: Size(130, 60),
                      ),
                    ),

                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 2),
                      child: GameButtons(
                        label: "LB",
                        btnColor: Colors.grey.shade600,
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
                      btnColor: Colors.grey.shade400,
                      btnSize: Size(20, 20),
                    ),

                    SizedBox(width: 20),

                    GameButtons(
                      label: "GUIDE",
                      btnColor: Color(0xFF107C10),
                      btnSize: Size(40, 40),
                    ),

                    SizedBox(width: 20),

                    GameButtons(
                      label: "START",
                      btnColor: Colors.grey.shade400,
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
                        label: "RT",
                        btnColor: Colors.grey.shade600,
                        btnSize: Size(130, 60),
                      ),
                    ),

                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 2),
                      child: GameButtons(
                        label: "RB",
                        btnColor: Colors.grey.shade600,
                        btnSize: Size(130, 60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [Dpad(), Facebutton()],
            ),
          ],
        ),
      ),
    );
  }
}
