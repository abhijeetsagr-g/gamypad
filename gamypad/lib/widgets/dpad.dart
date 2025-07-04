import 'package:flutter/material.dart';
import 'package:gamypad/widgets/game_button.dart';

// ignore: camel_case_types
enum dir { up, down, left, right, none }

class Dpad extends StatefulWidget {
  const Dpad({super.key});

  @override
  State<Dpad> createState() => _DpadState();
}

class _DpadState extends State<Dpad> {
  @override
  Widget build(BuildContext context) {
    Size targetSize = const Size(
      60,
      50,
    ); // Still used for individual button sizing

    return Container(
      margin: const EdgeInsets.all(8),
      width: 200,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // UP button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameButtons(
                    label: "UP+LEFT",
                    btnColor: Color.fromRGBO(255, 255, 255, 0),
                    btnSize: targetSize,
                  ),

                  GameButtons(
                    label: "UP",
                    btnColor: Colors.grey,
                    btnSize: targetSize,
                  ),

                  GameButtons(
                    label: "UP+RIGHT",
                    btnColor: Color.fromRGBO(255, 255, 255, 0),
                    btnSize: targetSize,
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT button
                  GameButtons(
                    label: "LEFT",
                    btnColor: Colors.grey,
                    btnSize: targetSize,
                  ),

                  SizedBox(width: targetSize.width), // To push right button
                  // RIGHT button
                  GameButtons(
                    label: "RIGHT",
                    btnColor: Colors.grey,
                    btnSize: targetSize,
                  ),
                ],
              ),

              // DOWN button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameButtons(
                    label: "DOWN+LEFT",
                    btnColor: Color.fromRGBO(255, 255, 255, 0),
                    btnSize: targetSize,
                  ),

                  GameButtons(
                    label: "DOWN",
                    btnColor: Colors.grey,
                    btnSize: targetSize,
                  ),
                  GameButtons(
                    label: "DOWN+RIGHT",
                    btnColor: Color.fromRGBO(255, 255, 255, 0),
                    btnSize: targetSize,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
