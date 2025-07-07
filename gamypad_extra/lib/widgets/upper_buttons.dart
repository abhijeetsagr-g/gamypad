import 'package:flutter/material.dart';
import 'package:gamypad_extra/widgets/buttons.dart';

class UpperButtons extends StatelessWidget {
  const UpperButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LT && LB
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Buttons(
                label: "LT",
                btnColor: Color.fromARGB(255, 40, 40, 40),
                size: Size(130, 65),
              ),
            ),

            SizedBox(height: 5),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Buttons(
                label: "LB",
                btnColor: Color.fromARGB(255, 30, 30, 30),
                size: Size(130, 65),
              ),
            ),
          ],
        ),

        // Start && Select && Guide
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Buttons(
                label: "SELECT",
                btnColor: Color.fromARGB(255, 100, 100, 100),
                size: Size(40, 40),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Buttons(
                label: "GUIDE",
                btnColor: Colors.green,
                size: Size(60, 60),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Buttons(
                label: "START",
                btnColor: Color.fromARGB(255, 70, 70, 70),
                size: Size(40, 40),
              ),
            ),
          ],
        ),

        // RT && RB
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
              child: Buttons(
                label: "RT",
                btnColor: Color.fromARGB(255, 40, 40, 40),
                size: Size(130, 65),
              ),
            ),

            SizedBox(height: 5),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
              child: Buttons(
                label: "RB",
                btnColor: Color.fromARGB(255, 30, 30, 30),
                size: Size(130, 65),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
