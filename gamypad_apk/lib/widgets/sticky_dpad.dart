import 'package:flutter/material.dart';

class StickyDpad extends StatefulWidget {
  const StickyDpad({super.key});

  @override
  State<StickyDpad> createState() => _StickyDpadState();
}

class _StickyDpadState extends State<StickyDpad> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StickDpadButtons(btnCode: 'UP'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StickDpadButtons(btnCode: "LEFT"),
            SizedBox(width: 40),
            StickDpadButtons(btnCode: "RIGHT"),
          ],
        ),
        StickDpadButtons(btnCode: "DOWN"),
      ],
    );
  }
}

class StickDpadButtons extends StatefulWidget {
  const StickDpadButtons({super.key, required this.btnCode});
  final String btnCode;
  @override
  State<StickDpadButtons> createState() => _StickDpadButtonsState();
}

class _StickDpadButtonsState extends State<StickDpadButtons> {
  bool isPressed = false;

  void onPress() {
    setState(() {
      isPressed = true;
    });
  }

  void onRelease() {
    setState(() {
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 40,
      child: Card(
        elevation: 4,
        color: isPressed ? Colors.grey : Colors.grey[900],
        child: GestureDetector(
          onPanStart: (_) => onPress(),
          onPanEnd: (_) => onRelease(),
          onPanCancel: () => onRelease(),
          onPanUpdate: (details) {
            // Check if finger has moved outside the widget
            final box = context.findRenderObject() as RenderBox;
            final localPos = box.globalToLocal(details.globalPosition);
            if (localPos.dx < 0 ||
                localPos.dy < 0 ||
                localPos.dx > box.size.width ||
                localPos.dy > box.size.height) {
              onRelease();
            } else {
              onPress();
            }
          },
          child: Center(child: Text(widget.btnCode)),
        ),
      ),
    );
  }
}
