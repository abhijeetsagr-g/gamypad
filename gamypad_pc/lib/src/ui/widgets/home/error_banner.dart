import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/home/home_palette.dart';

/// Shows why the last start attempt failed.
///
/// Previously the message was red text on the background, which read as
/// decoration rather than an error.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HomePalette.dangerSurface,
        border: Border.all(color: HomePalette.dangerBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 16, color: HomePalette.danger),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: HomePalette.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
