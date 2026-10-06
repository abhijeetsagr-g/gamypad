import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
