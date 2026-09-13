import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/center_buttons.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/dpad.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/face_button.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/joystick.dart';
import 'package:gamypad_apk_new/ui/gamepad/widget/top_bar.dart';

class GamepadView extends ConsumerStatefulWidget {
  const GamepadView({super.key});

  @override
  ConsumerState<GamepadView> createState() => _GamepadViewState();
}

class _GamepadViewState extends ConsumerState<GamepadView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tilt = ref.watch(tiltProvider);
    final connected = ref.watch(clientProvider).isConnected;
    final tiltNot = ref.read(tiltProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top bar + tiny motion toggle inline — zero extra height when OFF,
              // compact single-line controls only when ON.
              Row(
                children: [
                  const Expanded(child: TopBar()),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => tiltNot.toggle(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: tilt.enabled ? const Color(0xFF16261E) : const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: tilt.enabled ? const Color(0xFF00FF88).withValues(alpha: 0.40) : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tilt.enabled ? const Color(0xFF00FF88) : Colors.transparent,
                            border: Border.all(
                              color: tilt.enabled ? const Color(0xFF00FF88) : Colors.white30,
                              width: 1.5,
                            ),
                            boxShadow: tilt.enabled
                                ? [BoxShadow(color: const Color(0xFF00FF88).withValues(alpha: 0.45), blurRadius: 6)]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Compact one-line motion controls — only when enabled
              if (tilt.enabled) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => tiltNot.calibrate(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                          ),
                          child: const Text('CALIBRATE',
                              style: TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('SENS', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 0.8)),
                      SizedBox(
                        width: 74,
                        height: 22,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: const Color(0xFF00FF88),
                            inactiveTrackColor: Colors.white12,
                            thumbColor: const Color(0xFF00FF88),
                          ),
                          child: Slider(
                            min: 0.6,
                            max: 3.0,
                            divisions: 12,
                            value: tilt.sensitivity,
                            onChanged: (v) => tiltNot.setSensitivity(v),
                          ),
                        ),
                      ),
                      Text(tilt.sensitivity.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white54, fontSize: 9)),
                      const SizedBox(width: 10),
                      const Text('DZ', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 0.8)),
                      SizedBox(
                        width: 66,
                        height: 22,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            activeTrackColor: Colors.white38,
                            inactiveTrackColor: Colors.white10,
                            thumbColor: Colors.white60,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: 0.4,
                            divisions: 8,
                            value: tilt.deadzone,
                            onChanged: (v) => tiltNot.setDeadzone(v),
                          ),
                        ),
                      ),
                      Text('${(tilt.deadzone * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white38, fontSize: 9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('L ${tilt.stickX.toString().padLeft(5)} , ${tilt.stickY.toString().padLeft(5)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 0.6)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !connected ? Colors.white24 : const Color(0xFF00FF88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Joystick(isLeftStick: true, radius: 60),
                        const SizedBox(height: 30),
                        Dpad(),
                      ],
                    ),
                    Column(
                      children: [
                        CenterButtons(),
                        const SizedBox(height: 30),
                        Joystick(isLeftStick: false, radius: 60),
                      ],
                    ),
                    FaceButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
