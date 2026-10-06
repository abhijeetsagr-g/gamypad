import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/state/log_controller.dart';
import 'package:gamypad_pc/src/ui/widgets/log/log_format.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class LogRow extends StatelessWidget {
  const LogRow({super.key, required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final parts = describe(entry.message);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            _fmt(entry.time),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: ColorPalette.muted,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              parts.name.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: ColorPalette.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              parts.value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: parts.valueColor ?? ColorPalette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime t) {
    String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    return '${p(t.hour)}:${p(t.minute)}:${p(t.second)}.${p(t.millisecond, 3)}';
  }
}
