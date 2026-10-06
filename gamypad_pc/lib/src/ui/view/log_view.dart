import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/ui/state/log_controller.dart';
import 'package:gamypad_pc/src/ui/widgets/log/log_row.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class LogView extends ConsumerWidget {
  const LogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(logControllerProvider);
    final controller = ref.read(logControllerProvider.notifier);
    final entries = log.filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LOG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: log.paused ? 'Resume' : 'Pause',
            icon: Icon(
              log.paused ? Icons.play_arrow : Icons.pause,
              color: log.paused ? ColorPalette.waiting : null,
            ),
            onPressed: () => controller.setPaused(!log.paused),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final f in LogFilter.values)
                  ChoiceChip(
                    label: Text(f.name),
                    selected: log.filter == f,
                    onSelected: (_) => controller.setFilter(f),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Log list (newest first, matching insert(0, ...))
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      'No messages',
                      style: TextStyle(color: ColorPalette.muted),
                    ),
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemExtent: 28,
                    itemBuilder: (context, i) => LogRow(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
