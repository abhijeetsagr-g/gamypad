import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/editor_gestures.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';

class ControllerEditorView extends ConsumerStatefulWidget {
  const ControllerEditorView({super.key});

  @override
  ConsumerState<ControllerEditorView> createState() =>
      _ControllerEditorViewState();
}

class _ControllerEditorViewState extends ConsumerState<ControllerEditorView> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(layoutControllerProvider).value;
    final controller = ref.read(layoutControllerProvider.notifier);

    // Offered only when there is something to undo. A layout still identical to
    // the default has nothing to reset, and a permanently visible button would
    // read as a fixture rather than a way back — so this doubles as the "you have
    // changes" indicator. Needs value equality on ControllerLayout to be
    // truthful: identity comparison would report every layout as modified.
    final modified = layout != null && layout != DefaultLayout.layout;

    return Scaffold(
      backgroundColor: PadPalette.background,
      floatingActionButton: modified
          ? FloatingActionButton.extended(
              onPressed: controller.reset,
              backgroundColor: PadPalette.surface,
              foregroundColor: PadPalette.label,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text(
                'RESET',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            )
          : null,
      body: SizedBox.expand(
        child: layout == null
            ? const SizedBox.shrink()
            : EditorGestures(
                layout: layout,
                selected: _selected,
                onSelectionChanged: (id) => setState(() => _selected = id),
                onChanged: controller.commit,
              ),
      ),
    );
  }
}
