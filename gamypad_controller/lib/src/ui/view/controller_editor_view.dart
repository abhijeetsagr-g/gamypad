import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/editor_gestures.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

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

    final modified = layout != null && layout != DefaultLayout.layout;

    return Scaffold(
      floatingActionButton: modified
          ? FloatingActionButton.extended(
              onPressed: controller.reset,
              backgroundColor: ColorPalette.background,
              foregroundColor: ColorPalette.label,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text(
                'RESET',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            )
          : null,
      body: SafeArea(
        child: SizedBox.expand(
          child: layout == null
              ? const SizedBox.shrink()
              : EditorGestures(
                  layout: layout,
                  selected: _selected,
                  onSelectionChanged: (id) => setState(() => _selected = id),
                  onChanged: controller.commit,
                ),
        ),
      ),
    );
  }
}
