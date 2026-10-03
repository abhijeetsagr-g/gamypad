import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/home/home_palette.dart';

/// Start/stop control.
///
/// Renders three labels for four states: while [busy] the server is mid
/// transition, so the label names the action in flight rather than the state
/// it is heading to. That is why it takes `busy` and `isRunning` separately
/// instead of a single enum.
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
        // Busy guards against a double tap racing two binds.
        onPressed: busy ? null : (isRunning ? onStop : onStart),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning
              ? HomePalette.stopSurface
              : HomePalette.accent,
          disabledBackgroundColor: HomePalette.dim,
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
