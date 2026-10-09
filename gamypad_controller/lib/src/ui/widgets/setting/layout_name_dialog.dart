import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

Future<String?> promptLayoutName(
  BuildContext context, {
  String? initial,
  String title = 'SAVE LAYOUT',
  String action = 'SAVE',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _LayoutNameDialog(initial: initial, title: title, action: action),
  );
}

class _LayoutNameDialog extends StatefulWidget {
  const _LayoutNameDialog({
    required this.initial,
    required this.title,
    required this.action,
  });

  final String? initial;
  final String title;
  final String action;

  @override
  State<_LayoutNameDialog> createState() => _LayoutNameDialogState();
}

class _LayoutNameDialogState extends State<_LayoutNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: ColorPalette.analogTrack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: ColorPalette.border),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: ColorPalette.text,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 32,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        style: const TextStyle(color: ColorPalette.text, fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'Preset name',
          hintStyle: TextStyle(color: ColorPalette.muted),
          counterText: '',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.border),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accent),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: ColorPalette.muted),
          child: const Text('CANCEL'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => TextButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            style: TextButton.styleFrom(foregroundColor: ColorPalette.accent),
            child: Text(widget.action),
          ),
        ),
      ],
    );
  }
}
