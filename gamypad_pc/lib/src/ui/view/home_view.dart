import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/ui/state/notifier.dart';
import 'package:gamypad_pc/src/ui/view/log_view.dart';
import 'package:gamypad_pc/src/ui/widgets/home/connection_status_badge.dart';
import 'package:gamypad_pc/src/ui/widgets/home/error_banner.dart';
import 'package:gamypad_pc/src/ui/widgets/home/pairing_panel.dart';
import 'package:gamypad_pc/src/ui/widgets/home/server_toggle_button.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverControllerProvider);
    final controller = ref.read(serverControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'GAMYPAD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ConnectionStatusBadge(connection: server.connection),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Log',
              icon: const Icon(Icons.games),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogView()),
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PairingPanel(
                  running: server.isRunning,
                  connected: server.isConnected,
                  address: server.ip.isEmpty
                      ? ''
                      : '${server.ip}:${server.port}',
                ),

                if (server.error case final message?) ...[
                  const SizedBox(height: 24),
                  ErrorBanner(message: message),
                ],

                const SizedBox(height: 40),

                ServerToggleButton(
                  busy: server.busy,
                  isRunning: server.isRunning,
                  onStart: () {
                    controller.start();
                  },
                  onStop: () {
                    controller.stop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
