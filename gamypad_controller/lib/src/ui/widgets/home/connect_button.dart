import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

/// The primary connect control. Shows a spinner while a connection attempt is
/// in flight, "RECONNECT" after a dropped link, and stays disabled while
/// [enabled] is false (e.g. no address entered yet).
class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    required this.status,
    required this.busy,
    required this.enabled,
    required this.onConnect,
  });

  final ConnectionStatus status;
  final bool busy;
  final bool enabled;
  final VoidCallback onConnect;

  String get _label => switch ((busy, status)) {
    (true, _) => 'CONNECTING',
    (false, ConnectionStatus.lost) => 'RECONNECT',
    (false, _) => 'CONNECT',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: busy || !enabled ? null : onConnect,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.accent,
          foregroundColor: Colors.black,
          disabledBackgroundColor: ColorPalette.dim,
          disabledForegroundColor: ColorPalette.muted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                _label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

/// Opens the on-screen pad. Shown in place of [ConnectButton] while connected.
class GamepadButton extends StatelessWidget {
  const GamepadButton({super.key, required this.onPress});

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onPress,
        icon: const Icon(Icons.sports_esports, size: 20),
        label: const Text('GAMEPAD'),
        style: FilledButton.styleFrom(
          backgroundColor: ColorPalette.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
