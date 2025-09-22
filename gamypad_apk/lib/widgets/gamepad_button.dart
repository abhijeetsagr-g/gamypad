import 'package:flutter/material.dart';
import 'package:gamypad_apk/models/client.dart';
import 'package:gamypad_apk/models/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class GamepadButton extends StatefulWidget {
  const GamepadButton({
    super.key,
    required this.btnName,
    required this.width,
    required this.height,
    required this.btnCode,
  });
  final String btnCode;
  final String btnName;
  final double width;
  final double height;

  @override
  State<GamepadButton> createState() => _GamepadButtonState();
}

class _GamepadButtonState extends State<GamepadButton> {
  bool isPressed = false;
  late final clientProvider = Provider.of<Client>(context, listen: false);

  void onPress() {
    final settings = Provider.of<Settings>(context, listen: false);

    if (settings.isVibrateOn) {
      HapticFeedback.vibrate();
    }

    setState(() {
      isPressed = true;
    });
    if (widget.btnCode == 'RT' || widget.btnCode == 'LT') {
      clientProvider.sendJson({"action": widget.btnCode, "btn": "1"});
      return;
    }
    clientProvider.sendJson({"action": "press", "btn": widget.btnCode});
  }

  void onRelease() {
    setState(() {
      isPressed = false;
    });
    if (widget.btnCode == 'RT' || widget.btnCode == 'LT') {
      clientProvider.sendJson({"action": widget.btnCode, "btn": "0"});
      return;
    }
    clientProvider.sendJson({"action": "release", "btn": widget.btnCode});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
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
