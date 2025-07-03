import 'package:flutter/material.dart';
import 'package:gamypad/widgets/game_button.dart';

class Facebutton extends StatefulWidget {
  const Facebutton({super.key});

  @override
  State<Facebutton> createState() => _FacebuttonState();
}

class _FacebuttonState extends State<Facebutton> {
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
                    label: "Y+X",
                    btnColor: Color.fromRGBO(255, 255, 255, 0),
                    btnSize: targetSize,
                  ),

                  GameButtons(
                    label: "Y",
                    btnColor: Colors.yellow,
                    btnSize: targetSize,
                  ),

                  GameButtons(
                    label: "Y+B",
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
                    label: "X",
                    btnColor: Colors.blue,
                    btnSize: targetSize,
                  ),

                  SizedBox(width: targetSize.width), // To push right button
                  // RIGHT button
                  GameButtons(
                    label: "B",
                    btnColor: Colors.red,
                    btnSize: targetSize,
                  ),
                ],
              ),

              // DOWN button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameButtons(
                    label: "A+X",
                    btnColor: Color.fromRGBO(255, 255, 255, 0),
                    btnSize: targetSize,
                  ),

                  GameButtons(
                    label: "A",
                    btnColor: Colors.green,
                    btnSize: targetSize,
                  ),
                  GameButtons(
                    label: "A+B",
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
