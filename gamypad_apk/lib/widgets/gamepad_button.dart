import 'package:flutter/material.dart';

class GamepadButton extends StatefulWidget {
  const GamepadButton({super.key, required this.btnName});
  final String btnName;

  @override
  State<GamepadButton> createState() => _GamepadButtonState();
}

class _GamepadButtonState extends State<GamepadButton> {
  bool isPressed = false;
  void onPress() {
    print("Pressed");
    setState(() {
      isPressed = true;
    });
  }

  void onRelease() {
    print("released");
    setState(() {
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 70,
      child: Card(
        elevation: 4,
        color: isPressed ? Colors.grey : Colors.grey[900],
        child: Listener(
          onPointerDown: (_) => onPress(),
          onPointerUp: (_) => onRelease(),
          onPointerCancel: (_) => onRelease(),
          behavior: HitTestBehavior.translucent,
          child: Center(child: Text(widget.btnName)),
        ),
      ),
    );
  }
}
