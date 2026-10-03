import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The pairing address, selectable and with a copy button.
///
/// Shown as text as well as in the QR code because scanning is not always an
/// option, and this is otherwise the only place the ephemeral port is visible.
class PairingAddress extends StatelessWidget {
  const PairingAddress({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: SelectableText(
            address,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: address)),
          icon: const Icon(Icons.copy, size: 16),
          color: Colors.white38,
          tooltip: 'Copy address',
        ),
      ],
    );
  }
}
