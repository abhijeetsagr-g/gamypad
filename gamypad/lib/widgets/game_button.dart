import 'package:flutter/material.dart';

class GameButtons extends StatefulWidget {
  const GameButtons({
    super.key,
    required this.label,
    required this.btnColor,
    required this.btnSize,
  });

  final String label;
  final Color btnColor;
  final Size btnSize;

  @override
  State<GameButtons> createState() => _GameButtonsState();
}

class _GameButtonsState extends State<GameButtons> {
  bool _pressed = false;
  bool _giveLabel = true;

  @override
  void initState() {
    super.initState();
    _giveLabel =
        !(widget.label == "START" ||
            widget.label == "SELECT" ||
            widget.label == "GUIDE");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      }, // send press

      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      }, // send release

      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      }, // release on cancel

      child: Container(
        alignment: Alignment.center,
        width: widget.btnSize.width,
        height: widget.btnSize.height,
        decoration: BoxDecoration(
          color: _pressed ? Colors.blueGrey : widget.btnColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          _giveLabel ? widget.label : "",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
