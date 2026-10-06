import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class ServerToggleButton extends StatelessWidget {
  const ServerToggleButton({
    super.key,
    required this.busy,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
  });

  final bool busy;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;

  String get _label => switch ((busy, isRunning)) {
    (true, true) => 'STOPPING',
    (true, false) => 'STARTING',
    (false, true) => 'STOP SERVER',
    (false, false) => 'START SERVER',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton(
        onPressed: busy ? null : (isRunning ? onStop : onStart),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning
              ? ColorPalette.danger
              : ColorPalette.accent,
          disabledBackgroundColor: ColorPalette.muted,
          foregroundColor: isRunning ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: Text(
          _label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
