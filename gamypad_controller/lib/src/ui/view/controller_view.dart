import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/ui/state/connection_controller.dart';
import 'package:gamypad_controller/src/ui/state/gyro_provider.dart';
import 'package:gamypad_controller/src/ui/state/input_provider.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/state/setting_controller.dart';
import 'package:gamypad_controller/src/ui/widgets/home/connection_status_badge.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_renderer.dart';

class ControllerView extends ConsumerStatefulWidget {
  const ControllerView({super.key});

  @override
  ConsumerState<ControllerView> createState() => _ControllerViewState();
}

class _ControllerViewState extends ConsumerState<ControllerView>
    with WidgetsBindingObserver {
  late final _input = ref.read(inputProvider);
  bool _resumePending = false;
  bool _reconnectInProgress = false;

  @override
  void initState() {
    super.initState();
    _input;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _input.releaseAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _resumePending = true;
      _input.releaseAll();
      return;
    }

    if (!_resumePending) return;
    _resumePending = false;
    unawaited(_reconnectAfterResume());
  }

  Future<void> _reconnectAfterResume() async {
    if (_reconnectInProgress || !mounted) return;
    final connection = ref.read(connectionControllerProvider);
    if (connection.target == null || connection.isConnected) return;

    _reconnectInProgress = true;
    final reconnected = await ref
        .read(connectionControllerProvider.notifier)
        .reconnect(attempts: 5);
    _reconnectInProgress = false;

    if (!reconnected && mounted) {
      // Return to the home connection screen after the fifth failed attempt.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(connectionControllerProvider);
    // Keeps the sensors running (or not) for as long as the pad is on screen.
    ref.watch(gyroControllerProvider);

    final input = ref.read(inputProvider);
    final layout = ref.watch(layoutControllerProvider).value;
    final settings = ref.watch(settingControllerProvider).value;
    final digitalTriggers = settings?.digitalTriggers ?? false;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) input.releaseAll();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: layout == null
                    ? const SizedBox.shrink()
                    : PadRenderer(
                        layout: layout,
                        enabled: connection.isConnected,
                        digitalTriggers: digitalTriggers,
                        onButton: (button, pressed) {
                          if (!pressed) {
                            input.release(button);
                            return;
                          }
                          input.press(button);
                        },
                        onStick: input.setStick,
                        onTrigger: input.setTrigger,
                      ),
              ),
              if (!connection.busy)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.6),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: connection.isConnected
                            ? const SizedBox.shrink(
                                key: ValueKey('connected'),
                              )
                            : _LinkNotice(
                                key: ValueKey(connection.status),
                                status: connection.status,
                              ),
                      ),
                    ),
                  ),
                ),
              if (connection.busy)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'RECONNECTING…',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkNotice extends StatelessWidget {
  const _LinkNotice({super.key, required this.status});
  final ConnectionStatus status;

  static String messageFor(ConnectionStatus status) => switch (status) {
    ConnectionStatus.connecting =>
      'Reconnecting. Presses will work again when the link is restored.',
    ConnectionStatus.lost =>
      'Connection lost. Attempting to reconnect...',
    ConnectionStatus.disconnected =>
      'Not paired. Connect from the home screen to send anything; the pad is '
          'here either way.',
    ConnectionStatus.connected => '',
  };

  @override
  Widget build(BuildContext context) {
    final presentation = ConnectionStatusBadge.present(status);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: presentation.color.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: presentation.color,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  messageFor(status),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: presentation.color,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
