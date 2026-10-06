import 'package:flutter/material.dart';

class ScanHint extends StatelessWidget {
  const ScanHint({
    super.key,
    required this.torchOn,
    required this.onToggleTorch,
    this.rejectedCode,
  });

  final bool torchOn;
  final VoidCallback onToggleTorch;
  final String? rejectedCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rejectedCode case final code?) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x3DB71C1C),
              border: Border.all(color: const Color(0xFFB71C1C)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Not a Gamypad address: $code',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Point at the QR code on your PC',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onToggleTorch,
              tooltip: torchOn ? 'Torch off' : 'Torch on',
              icon: Icon(
                torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                color: torchOn ? const Color(0xFF00FF88) : Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
