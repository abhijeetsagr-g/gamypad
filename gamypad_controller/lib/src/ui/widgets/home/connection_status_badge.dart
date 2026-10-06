import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key, required this.status});

  final ConnectionStatus status;

  static ({String label, Color color}) present(ConnectionStatus status) =>
      switch (status) {
        ConnectionStatus.connected => (
          label: 'CONNECTED',
          color: ColorPalette.accent,
        ),
        ConnectionStatus.connecting => (
          label: 'CONNECTING',
          color: ColorPalette.waiting,
        ),
        ConnectionStatus.lost => (label: 'LOST', color: ColorPalette.danger),
        ConnectionStatus.disconnected => (
          label: 'NOT PAIRED',
          color: ColorPalette.dim,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final presentation = present(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            presentation.label,
            key: ValueKey(presentation.label),
            style: TextStyle(
              color: presentation.color,
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
            color: presentation.color,
          ),
        ),
      ],
    );
  }
}
