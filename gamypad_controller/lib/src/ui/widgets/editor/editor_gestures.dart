import 'dart:math' as math;

import 'package:flutter/material.dart' hide SelectionOverlay;
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/selection_overlay.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_renderer.dart';

class EditorGestures extends StatefulWidget {
  const EditorGestures({
    super.key,
    required this.layout,
    required this.selected,
    required this.onChanged,
    required this.onSelectionChanged,
  });

  final ControllerLayout layout;
  final String? selected;
  final ValueChanged<ControllerLayout> onChanged;
  final ValueChanged<String?> onSelectionChanged;

  @override
  State<EditorGestures> createState() => _EditorGesturesState();
}

enum _DragMode { move, resize, none }

class _EditorGesturesState extends State<EditorGestures> {
  ControllerLayout? _preview;

  String? _selected;
  double _scale = 1;

  String? _dragId;
  _DragMode _mode = _DragMode.none;
  Rect _dragStart = Rect.zero;
  Offset _dragOrigin = Offset.zero;

  ControllerLayout get _shown => _preview ?? widget.layout;

  /// The drag in progress is currently somewhere it may not be left.
  bool get _invalid => _preview != null && !_preview!.isValid;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(EditorGestures oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _selected = widget.selected;
  }

  void _select(String? id) {
    if (_selected == id) return;
    setState(() => _selected = id);
    widget.onSelectionChanged(id);
  }

  void _begin(Offset position) {
    final selected = _selected;
    final current = selected == null ? null : _shown[selected];

    if (current != null &&
        current.resizable &&
        SelectionOverlay.handleRectFor(
          current,
          _scale,
        ).inflate(8).contains(position)) {
      setState(() {
        _mode = _DragMode.resize;
        _dragId = current.id;
        _dragStart = current.rect;
        _dragOrigin = position;
        _preview = widget.layout;
      });
      return;
    }

    final hit = _shown.elementAt(_toAuthored(position));

    if (hit == null || !hit.movable) {
      setState(() {
        _mode = _DragMode.none;
        _dragId = null;
      });
      _select(null);
      return;
    }

    _select(hit.id);
    setState(() {
      _mode = _DragMode.move;
      _dragId = hit.id;
      _dragStart = hit.rect;
      _dragOrigin = position;
      _preview = widget.layout;
    });
  }

  /// Follows the finger freely, including into an invalid position.
  void _move(Offset position) {
    final id = _dragId;
    final preview = _preview;
    if (id == null || preview == null) return;

    final delta = (position - _dragOrigin) / _scale;
    final proposed = switch (_mode) {
      _DragMode.resize => Rect.fromLTRB(
        _dragStart.left,
        _dragStart.top,
        _dragStart.right + delta.dx,
        _dragStart.bottom + delta.dy,
      ),
      _DragMode.move => _dragStart.shift(delta),
      _DragMode.none => _dragStart,
    };

    setState(() => _preview = preview.place(id, proposed));
  }

  void _end() {
    final preview = _preview;
    final id = _dragId;
    final mode = _mode;

    setState(() {
      _preview = null;
      _mode = _DragMode.none;
      _dragId = null;
    });

    if (id == null || preview == null || mode == _DragMode.none) return;
    if (!preview.isValid) return;

    final committed = widget.layout.place(id, preview[id]!.rect);
    if (identical(committed, widget.layout)) return;
    widget.onChanged(committed);
  }

  Offset _toAuthored(Offset rendered) => rendered / _scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final authored = widget.layout.authoredSize;
        final available = constraints.biggest;

        _scale = (available.width.isFinite && available.height.isFinite)
            ? math.max(
                available.width / authored.width,
                available.height / authored.height,
              )
            : 1.0;

        final selected = _selected;

        return SizedBox.expand(
          child: Center(
            child: SizedBox.fromSize(
              size: Size(authored.width * _scale, authored.height * _scale),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PadRenderer(layout: _shown, showCanvas: true),
                  IgnorePointer(
                    child: SelectionOverlay(
                      element: selected == null ? null : _shown[selected],
                      scale: _scale,
                      invalid: _invalid,
                      showHandle:
                          selected != null && _shown[selected]!.resizable,
                    ),
                  ),
                  _gestures(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _gestures() => Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: (event) => _begin(event.localPosition),
    onPointerMove: (event) => _move(event.localPosition),
    onPointerUp: (_) => _end(),
    onPointerCancel: (_) => _end(),
  );
}
