import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class TargetFields extends StatelessWidget {
  const TargetFields({
    super.key,
    required this.host,
    required this.port,
    required this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController host;
  final TextEditingController port;

  final ValueChanged<UdpTarget?> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(
          label: 'ADDRESS',
          keyboardType: TextInputType.text,
          controller: host,
          autofocus: autofocus,
          hint: '192.168.1.10',
          onChanged: (_) => _report(),
        ),
        const SizedBox(height: 16),
        _Field(
          label: 'PORT',
          keyboardType: TextInputType.number,
          controller: port,
          hint: '41234',
          onChanged: (_) => _report(),
        ),
      ],
    );
  }

  void _report() {
    final host = this.host.text.trim();
    final port = this.port.text.trim();
    if (host.isEmpty || port.isEmpty) {
      onChanged(null);
      return;
    }
    onChanged(UdpTarget.tryParse('$host:$port'));
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.keyboardType,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.autofocus = false,
  });

  final String label;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ColorPalette.muted,
            fontSize: 10,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorPalette.dim,
            hintText: hint,
            hintStyle: const TextStyle(color: ColorPalette.dim),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: ColorPalette.accent),
            ),
          ),
        ),
      ],
    );
  }
}
