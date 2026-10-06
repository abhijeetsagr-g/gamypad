import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

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
          backgroundColor: ColorPalette.accent,
          disabledBackgroundColor: connected
              ? ColorPalette.dim
              : ColorPalette.dim,
          foregroundColor: Colors.black,
          disabledForegroundColor: connected
              ? ColorPalette.accent
              : ColorPalette.dim,
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
