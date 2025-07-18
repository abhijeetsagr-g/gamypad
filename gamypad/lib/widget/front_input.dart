import 'package:flutter/material.dart';
import 'package:gamypad/widget/buttons.dart';

class FrontInput extends StatelessWidget {
  const FrontInput({
    super.key,
    required this.btnColor,
    required this.bodyColor,
    required this.labels,
    required this.btnSize,
    required this.alignRight,
  });

  final Size btnSize;
  final List<String> labels;
  final Color btnColor;
  final Color bodyColor;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 200,
      height: 170,
      child: Stack(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Buttons(
                    size: btnSize,
                    btnColor: bodyColor,
                    label: "${labels[0]}+${labels[2]}",
                    showlabel: false,
                  ),
                  SizedBox(width: 10),
                  Buttons(size: btnSize, btnColor: btnColor, label: labels[0]),
                  SizedBox(width: 10),
                  Buttons(
                    size: btnSize,
                    btnColor: bodyColor,
                    label: "${labels[0]}+${labels[3]}",
                    showlabel: false,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons(size: btnSize, btnColor: btnColor, label: labels[2]),
                  Buttons(size: btnSize, btnColor: btnColor, label: labels[3]),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Buttons(
                    size: btnSize,
                    btnColor: bodyColor,
                    label: "${labels[1]}+${labels[2]}",
                    showlabel: false,
                  ),
                  SizedBox(width: 10),
                  Buttons(size: btnSize, btnColor: btnColor, label: labels[1]),
                  SizedBox(width: 10),
                  Buttons(
                    size: btnSize,
                    btnColor: bodyColor,
                    label: "${labels[1]}+${labels[3]}",
                    showlabel: false,
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
