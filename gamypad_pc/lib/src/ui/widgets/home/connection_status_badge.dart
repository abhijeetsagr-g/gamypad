// Flutter ships its own ConnectionState in widgets/async.dart, so it is hidden
// here and the transport's enum reads unqualified.
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:gamypad_pc/src/ui/widgets/home/home_palette.dart';

/// The app bar's status readout: a label and a dot in the matching colour.
///
/// Owns the only mapping from [ConnectionState] to presentation, so the label
/// and the colour can never disagree — the old page derived three strings from
/// two booleans and had to keep them in sync by hand.
class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key, required this.connection});

  final ConnectionState connection;

  static ({String label, Color color}) present(ConnectionState connection) =>
      switch (connection) {
        ConnectionState.connected => (
          label: 'CONNECTED',
          color: HomePalette.accent,
        ),
        ConnectionState.listening => (
          label: 'WAITING',
          color: HomePalette.waiting,
        ),
        ConnectionState.idle => (label: 'OFF', color: HomePalette.dim),
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
            // Keyed so AnimatedSwitcher cross-fades on change instead of
            // updating the text in place.
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
