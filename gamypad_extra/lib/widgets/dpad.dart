import 'package:flutter/material.dart';
import 'package:gamypad_extra/widgets/buttons.dart';

class Dpad extends StatefulWidget {
  const Dpad({super.key});

  @override
  State<Dpad> createState() => _DpadState();
}

class _DpadState extends State<Dpad> {
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
              // UP button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(
                    label: "UP+LEFT",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "UP",
                    btnColor: Color.fromARGB(255, 90, 90, 90),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "UP+RIGHT",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
                  ),
                ],
              ),

              // UP button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(
                    label: "LEFT",
                    btnColor: Color.fromARGB(255, 90, 90, 90),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "RIGHT",
                    btnColor: Color.fromARGB(255, 90, 90, 90),
                    size: targetSize,
                  ),
                ],
              ),

              // Down button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(
                    label: "DOWN+LEFT",
                    btnColor: Color.fromARGB(255, 20, 20, 20),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "DOWN",
                    btnColor: Color.fromARGB(255, 90, 90, 90),
                    size: targetSize,
                  ),

                  SizedBox(width: 10),

                  Buttons(
                    label: "DOWN+RIGHT",
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
