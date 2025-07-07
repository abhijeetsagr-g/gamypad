import 'package:flutter/material.dart';
import 'package:gamypad_extra/client.dart';

class Buttons extends StatefulWidget {
  const Buttons({
    super.key,
    required this.size,
    required this.btnColor,
    required this.label,
  });

  final Size size;
  final Color btnColor;
  final String label;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  bool _pressed = false;
  bool _showLabel = true;

  @override
  void initState() {
    super.initState();
    if (["START", "GUIDE", "SELECT"].contains(widget.label) ||
        widget.label.contains("+")) {
      _showLabel = false;
    }
  }

  void onPress() {
    setState(() {
      _pressed = true;
    });
    if (widget.label.contains("+")) {
      final labels = widget.label.split("+");
      sendJson(labels[0], "press");
      sendJson(labels[1], "press");
    } else {
      sendJson(widget.label, "press");
    }
  }

  void onRelease() {
    setState(() {
      _pressed = false;
    });
    if (widget.label.contains("+")) {
      final labels = widget.label.split("+");
      sendJson(labels[0], "release");
      sendJson(labels[1], "release");
    } else {
      sendJson(widget.label, "release");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ON Button pressed
      onLongPressDown: (details) {
        onPress();
      },
      onTapDown: (details) {
        onPress();
      },

      // ON Button released
      onLongPressUp: () {
        onRelease();
      },
      onTapUp: (details) {
        onRelease();
      },
      onPanEnd: (details) {
        onRelease();
      },

      child: Container(
        alignment: Alignment.center,
        height: widget.size.height,
        width: widget.size.width,

        decoration: BoxDecoration(
          color: _pressed
              ? widget.btnColor.withValues(alpha: 0.2)
              : widget.btnColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(blurRadius: 4)],
        ),
        child: Text(
          _showLabel ? widget.label : "",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
