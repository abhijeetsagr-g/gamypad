import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/core/utils/btn_code_mapper.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';

class GamepadButton extends ConsumerStatefulWidget {
  const GamepadButton({
    super.key,
    required this.btnName,
    required this.btnCode,
    required this.width,
    required this.height,
  });

  final String btnName;
  final String btnCode;
  final double width;
  final double height;

  @override
  ConsumerState<GamepadButton> createState() => _GamepadButtonState();
}

class _GamepadButtonState extends ConsumerState<GamepadButton> {
  bool _pressed = false;

  void _onPress() {
    HapticFeedback.lightImpact();
    setState(() => _pressed = true);
    final code = BtnCodeMapper.codeOf(widget.btnCode);
    if (BtnCodeMapper.isTrigger(widget.btnCode)) {
      ref.read(clientProvider.notifier).sendJson({"action": code, "btn": "1"});
    } else {
      ref.read(clientProvider.notifier).sendJson({
        "action": "press",
        "btn": code,
      });
    }
  }

  void _onRelease() {
    setState(() => _pressed = false);
    final code = BtnCodeMapper.codeOf(widget.btnCode);
    if (BtnCodeMapper.isTrigger(widget.btnCode)) {
      ref.read(clientProvider.notifier).sendJson({"action": code, "btn": "0"});
    } else {
      ref.read(clientProvider.notifier).sendJson({
        "action": "release",
        "btn": code,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,

      child: Listener(
        onPointerDown: (_) => _onPress(),
        onPointerUp: (_) => _onRelease(),
        onPointerCancel: (_) => _onRelease(),
        behavior: HitTestBehavior.opaque,
        child: Card(
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _pressed
                  ? const Color(0xFF3A3A3C)
                  : const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _pressed ? Colors.white24 : Colors.white10,
              ),
            ),
            child: Center(
              child: Text(
                widget.btnName,
                style: TextStyle(
                  color: _pressed ? Colors.white : Colors.white60,
                  // fontSize: widget.height * 0.35,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
