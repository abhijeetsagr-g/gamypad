import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.type,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType type;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          keyboardType: widget.type,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
