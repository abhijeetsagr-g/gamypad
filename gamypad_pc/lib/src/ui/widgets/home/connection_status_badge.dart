import 'package:flutter/material.dart' hide ConnectionState;
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key, required this.connection});

  final ConnectionState connection;

  static ({String label, Color color}) present(ConnectionState connection) =>
      switch (connection) {
        ConnectionState.connected => (
          label: 'CONNECTED',
          color: ColorPalette.accent,
        ),
        ConnectionState.listening => (
          label: 'WAITING',
          color: ColorPalette.waiting,
        ),
        ConnectionState.idle => (label: 'OFF', color: ColorPalette.muted),
      };

  @override
  Widget build(BuildContext context) {
    final status = present(connection);

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            status.label,
            key: ValueKey(status.label),
            style: TextStyle(
              color: status.color,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status.color,
          ),
        ),
      ],
    );
  }
}
