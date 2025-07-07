import 'package:flutter/material.dart';
import 'package:gamypad_extra/widgets/buttons.dart';

class Facebutton extends StatefulWidget {
  const Facebutton({super.key});

  @override
  State<Facebutton> createState() => _FacebuttonState();
}

class _FacebuttonState extends State<Facebutton> {
  @override
  Widget build(BuildContext context) {
    Size targetSize = const Size(60, 50);

    return Container(
      margin: const EdgeInsets.all(8),
      width: 200,
      height: 170,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(
                    label: "Y+X",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "Y",
                    btnColor: Color.fromARGB(255, 255, 204, 0),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "Y+B",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(
                    label: "X",
                    btnColor: Color.fromARGB(255, 0, 120, 215),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "B",
                    btnColor: Color.fromARGB(255, 220, 20, 60),
                    size: targetSize,
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(
                    label: "A+X",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "A",
                    btnColor: Color.fromARGB(255, 0, 153, 0),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "A+B",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
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
