import 'package:flutter/material.dart';
import 'package:gamypad_extra/widgets/dpad.dart';
import 'package:gamypad_extra/widgets/facebutton.dart';
import 'package:gamypad_extra/widgets/upper_buttons.dart';

class Gamepad extends StatefulWidget {
  const Gamepad({super.key});

  @override
  State<Gamepad> createState() => _GamepadState();
}

class _GamepadState extends State<Gamepad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 20, 20, 20),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UpperButtons(),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 20, 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Dpad(), Facebutton()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
