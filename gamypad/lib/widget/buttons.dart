import 'package:flutter/material.dart';
import 'package:gamypad/client.dart';

class Buttons extends StatefulWidget {
  const Buttons({
    super.key,
    required this.size,
    required this.btnColor,
    this.isCirclular = false,
    required this.label,
    this.showlabel = true,
  });

  final Size size;
  final String label;
  final Color btnColor;
  final bool isCirclular;
  final bool showlabel;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  bool _pressed = false;

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

      child: Opacity(
        opacity: _pressed ? 0.8 : 1,
        child: Container(
          alignment: Alignment.center,
          height: widget.size.height,
          width: widget.size.width,
          decoration: widget.isCirclular
              ? BoxDecoration(shape: BoxShape.circle, color: widget.btnColor)
              : BoxDecoration(
                  color: widget.btnColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: widget.showlabel
                      ? [BoxShadow(blurRadius: 4)]
                      : [BoxShadow(blurRadius: 0.2)],
                ),
          child: Text(
            widget.showlabel ? widget.label : "",
            style: TextStyle(fontFamily: "Hanalei", fontSize: 25),
          ),
        ),
      ),
    );
  }
}
