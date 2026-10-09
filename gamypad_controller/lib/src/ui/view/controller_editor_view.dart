import 'package:flutter/foundation.dart' show mapEquals, setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/editor_actions_fab.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/editor_gestures.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/layout_name_dialog.dart';

class ControllerEditorView extends ConsumerStatefulWidget {
  const ControllerEditorView({super.key, this.isNew = false});

  final bool isNew;

  @override
  ConsumerState<ControllerEditorView> createState() =>
      _ControllerEditorViewState();
}

class _ControllerEditorViewState extends ConsumerState<ControllerEditorView> {
  String? _selected;

  ControllerLayout? _entry;

  bool _draftPending = true;

  Future<void> _saveAs() async {
    final layout = ref.read(layoutControllerProvider).value;
    if (layout == null) return;

    final name = await promptLayoutName(
      context,
      initial: widget.isNew ? layout.name : null,
    );
    if (name == null || !mounted) return;

    final controller = ref.read(layoutControllerProvider.notifier);
    if (widget.isNew && _draftPending) {
      _draftPending = false;
      await controller.rename(name);
    } else {
      await controller.saveAs(name);
    }
  }

  void _toggleHidden() {
    final id = _selected;
    final layout = ref.read(layoutControllerProvider).value;
    if (id == null || layout == null) return;

    ref
        .read(layoutControllerProvider.notifier)
        .setHidden(id, !layout.isHidden(id));
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(layoutControllerProvider).value;
    final controller = ref.read(layoutControllerProvider.notifier);

    if (layout != null) _entry ??= layout;
    final entry = _entry;
    final modified =
        layout != null && entry != null && !_sameShape(layout, entry);

    return Scaffold(
      floatingActionButton: layout == null || entry == null
          ? null
          : EditorActionsFab(
              onSaveAs: _saveAs,
              onReset: () => controller.commit(entry.withName(layout.name)),
              resetEnabled: modified,
            ),
      body: SafeArea(
        child: SizedBox.expand(
          child: layout == null
              ? const SizedBox.shrink()
              : EditorGestures(
                  layout: layout,
                  selected: _selected,
                  onSelectionChanged: (id) => setState(() => _selected = id),
                  onChanged: controller.commit,
                  onToggleHidden: _toggleHidden,
                ),
        ),
      ),
    );
  }
}

bool _sameShape(ControllerLayout a, ControllerLayout b) =>
    a.authoredSize == b.authoredSize &&
    mapEquals(a.elements, b.elements) &&
    setEquals(a.hidden, b.hidden);
