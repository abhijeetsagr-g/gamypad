import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key, required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.qr_code_scanner, size: 20),
        label: const Text('SCAN QR'),
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.accent,
          disabledForegroundColor: ColorPalette.dim,
          side: const BorderSide(color: ColorPalette.accent),
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
