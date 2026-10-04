import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/ui/widgets/home/home_palette.dart';

/// The connect control.
///
/// Renders four labels across five states: while [busy] the attempt is in
/// flight, so the label names what is happening rather than the state being
/// moved towards. That is why it takes [status] and [busy] separately instead of
/// a single flag.
class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    required this.status,
    required this.busy,
    required this.enabled,
    required this.onConnect,
  });

  final ConnectionStatus status;

  /// An attempt is in flight. Disables the button, so a double tap cannot race
  /// two binds.
  final bool busy;

  /// Whether the fields hold a usable address. The button says why it is
  /// disabled by staying quiet about it, and the fields show the parse failure.
  final bool enabled;

  final VoidCallback onConnect;

  String get _label => switch ((busy, status)) {
    (true, _) => 'CONNECTING',
    (false, ConnectionStatus.connected) => 'CONNECTED',
    (false, ConnectionStatus.lost) => 'RECONNECT',
    (false, _) => 'CONNECT',
  };

  @override
  Widget build(BuildContext context) {
    final connected = status == ConnectionStatus.connected;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: busy || !enabled ? null : onConnect,
        style: ElevatedButton.styleFrom(
          backgroundColor: HomePalette.accent,
          // A lost connection is the one state where the button must look
          // inviting: the user is being asked to act.
          disabledBackgroundColor: connected
              ? HomePalette.surface
              : HomePalette.dim,
          foregroundColor: Colors.black,
          disabledForegroundColor: connected
              ? HomePalette.accent
              : HomePalette.dim,
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