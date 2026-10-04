import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/ui/widgets/home/home_palette.dart';

/// Address and port, as two fields that together mean one thing.
///
/// Reports a parsed [UdpTarget] rather than two strings, so the caller never
/// has to decide what a valid pair is. Validation goes through
/// [UdpTarget.tryParse] — the same gate a scanned QR code passes through — so
/// typing an address by hand cannot succeed where a scan would fail, or the
/// reverse.
///
/// The controllers are owned by the caller because they outlive this widget: a
/// scan writes into them, and the prefilled target from the last connection is
/// remembered across rebuilds.
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

  /// Called with the parsed target, or null while the pair is not usable.
  final ValueChanged<UdpTarget?> onChanged;

  /// Set by the host to raise the keyboard when the user has no better route in,
  /// which is never after a scan.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(
          label: 'ADDRESS',
          // Not number-only: a hostname is a legal target and `UdpTarget.parse`
          // accepts one, so the keyboard must be able to produce letters.
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

  /// Re-validates the pair and reports it.
  ///
  /// `host:port` is reassembled rather than validated field by field, because
  /// that string is exactly what [UdpTarget.parse] accepts — one parser, no
  /// second opinion about what a valid port is.
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
            color: HomePalette.muted,
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
          // The field echoes what the user typed, so digits are not worth
          // announcing and paste of a full address should stay possible.
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: HomePalette.surface,
            hintText: hint,
            hintStyle: const TextStyle(color: HomePalette.dim),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: HomePalette.accent),
            ),
          ),
        ),
      ],
    );
  }
}