import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/ui/widgets/home/home_palette.dart';

/// The app bar's status readout: a label and a dot in the matching colour.
///
/// Owns the only mapping from [ConnectionStatus] to presentation, so the label
/// and the colour can never disagree. The old page derived its text from a
/// single `isConnected` bool, which could not say "connection lost" — the one
/// state where the user has to act rather than just look.
class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key, required this.status});

  final ConnectionStatus status;

  static ({String label, Color color}) present(ConnectionStatus status) =>
      switch (status) {
        ConnectionStatus.connected => (
          label: 'CONNECTED',
          color: HomePalette.accent,
        ),
        ConnectionStatus.connecting => (
          label: 'CONNECTING',
          color: HomePalette.waiting,
        ),
        ConnectionStatus.lost => (label: 'LOST', color: HomePalette.danger),
        ConnectionStatus.disconnected => (
          label: 'NOT PAIRED',
          color: HomePalette.dim,
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
            // Keyed so AnimatedSwitcher cross-fades on change instead of
            // updating the text in place.
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
