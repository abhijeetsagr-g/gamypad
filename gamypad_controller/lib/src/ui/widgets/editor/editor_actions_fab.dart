import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class EditorActionsFab extends StatefulWidget {
  const EditorActionsFab({
    super.key,
    required this.onSaveAs,
    required this.onReset,
    required this.resetEnabled,
  });

  final VoidCallback onSaveAs;
  final VoidCallback onReset;
  final bool resetEnabled;

  @override
  State<EditorActionsFab> createState() => _EditorActionsFabState();
}

class _EditorActionsFabState extends State<EditorActionsFab> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _invoke(VoidCallback action) {
    setState(() => _open = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Action(
          open: _open,
          label: 'SAVE AS',
          icon: Icons.bookmark_add_outlined,
          onPressed: () => _invoke(widget.onSaveAs),
        ),
        const SizedBox(height: 12),
        _Action(
          open: _open,
          label: 'RESET',
          icon: Icons.restart_alt,
          onPressed: widget.resetEnabled ? () => _invoke(widget.onReset) : null,
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: null,
          onPressed: _toggle,
          backgroundColor: ColorPalette.background,
          foregroundColor: ColorPalette.label,
          elevation: 2,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.open,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final bool open;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: open ? Offset.zero : const Offset(0, 0.4),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: IgnorePointer(
          ignoring: !open,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _label(),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: onPressed,
                backgroundColor: ColorPalette.background,
                foregroundColor: ColorPalette.label,
                elevation: 2,
                child: Icon(icon, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label() => DecoratedBox(
    decoration: BoxDecoration(
      color: ColorPalette.analogTrack,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: ColorPalette.border),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: onPressed == null ? ColorPalette.dim : ColorPalette.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    ),
  );
}
