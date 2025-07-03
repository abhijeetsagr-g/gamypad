import 'package:flutter/material.dart';
import 'package:gamypad/client.dart';

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
    if (["START", "GUIDE", "SELECT"].contains(widget.label) ||
        widget.label.contains("+")) {
      _giveLabel = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
        if (widget.label.contains("+")) {
          List<String> part = widget.label.split("+");
          sendJson(part[0], "press");
          sendJson(part[1], "press");
        } else {
          sendJson(widget.label, "press");
        }
      }, // send press

      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        if (widget.label.contains("+")) {
          List<String> part = widget.label.split("+");
          sendJson(part[0], "release");
          sendJson(part[1], "release");
        } else {
          sendJson(widget.label, "release");
        }
      }, // send release

      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
        if (widget.label.contains("+")) {
          List<String> part = widget.label.split("+");
          sendJson(part[0], "release");
          sendJson(part[1], "release");
        } else {
          sendJson(widget.label, "release");
        }
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
