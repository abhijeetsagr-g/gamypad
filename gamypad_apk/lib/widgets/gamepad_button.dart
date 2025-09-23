import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_apk/widgets/my_widgets.dart';

import 'package:provider/provider.dart';

import 'package:gamypad_apk/models/client.dart';
import 'package:gamypad_apk/models/settings.dart';

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

  // on Error
  void onError(dynamic msg) {
    showFloatingSnackbar(context, msg);
  }

  // get info from Settings Provider
  late bool canVibrate;
  @override
  void initState() {
    super.initState();
    canVibrate = Provider.of<Settings>(context, listen: false).isVibrateOn;
  }

  // Trigger Actions
  void onTriggerPress() {
    clientProvider.sendJson({"action": widget.btnCode, "btn": "1"});
  }

  void onTriggerRelease() {
    clientProvider.sendJson({"action": widget.btnCode, "btn": "0"});
  }

  void sendInput(String action) {
    clientProvider.sendJson({"action": action, "btn": widget.btnCode});
  }

  void onPress() {
    // check if needed to vibrate
    if (canVibrate) {
      HapticFeedback.vibrate();
    }
    setState(() {
      isPressed = true;
    });

    // send Action based on btncode
    if (widget.btnCode == 'RT' || widget.btnCode == 'LT') {
      onTriggerPress();
      return;
    }
    sendInput("press");
  }

  void onRelease() {
    setState(() {
      isPressed = false;
    });

    // send Action based on btncode
    if (widget.btnCode == 'RT' || widget.btnCode == 'LT') {
      onTriggerRelease();
      return;
    }
    sendInput("release");
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
          onPointerDown: (_) => onPress(), // When finger touches the screen
          onPointerUp: (_) => onRelease(), // When finger is lifted up
          behavior: HitTestBehavior.translucent,
          child: Center(child: Text(widget.btnName)),
        ),
      ),
    );
  }
}
