import 'package:flutter/material.dart';
import 'package:gamypad_extra/widgets/buttons.dart';

class UpperButtons extends StatelessWidget {
  const UpperButtons({super.key});

  static const triggerSize = Size(130, 65);
  static const smallBtnSize = Size(40, 40);
  static const guideBtnSize = Size(60, 60);

  Widget _buildTrigger(String label, Color color, {bool isLeft = true}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isLeft ? 10 : 0, 10, isLeft ? 0 : 20, 0),
      child: Buttons(label: label, btnColor: color, size: triggerSize),
    );
  }

  Widget _buildCenterButton(
    String label,
    Color color,
    Size size, {
    double right = 10,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: right),
      child: Buttons(label: label, btnColor: color, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LT & LB
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrigger("LT", const Color(0xFF282828), isLeft: true),
            const SizedBox(height: 5),
            _buildTrigger("LB", const Color(0xFF1E1E1E), isLeft: true),
          ],
        ),

        // SELECT, GUIDE, START
        Row(
          children: [
            _buildCenterButton("SELECT", const Color(0xFF646464), smallBtnSize),
            _buildCenterButton("GUIDE", Colors.green, guideBtnSize),
            _buildCenterButton(
              "START",
              const Color(0xFF464646),
              smallBtnSize,
              right: 0,
            ),
          ],
        ),

        // RT & RB
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildTrigger("RT", const Color(0xFF282828), isLeft: false),
            const SizedBox(height: 5),
            _buildTrigger("RB", const Color(0xFF1E1E1E), isLeft: false),
          ],
        ),
      ],
    );
  }
}
