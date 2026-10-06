import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/ui/widgets/home/home_palette.dart';

/// Shows why the last connect attempt failed.
///
/// Takes the message as a plain string rather than reading the connection state
/// itself, so the same banner can report a failed socket *and* a rejected
/// address — the two failures live in different layers and would otherwise need
/// two components.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HomePalette.dangerSurface,
        border: Border.all(color: HomePalette.dangerBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: HomePalette.danger),
          const SizedBox(width: 8),
          Expanded(
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
