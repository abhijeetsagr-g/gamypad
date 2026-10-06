import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.dangerSurface,
        border: Border.all(color: ColorPalette.dangerSurface),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 16, color: ColorPalette.danger),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: ColorPalette.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
