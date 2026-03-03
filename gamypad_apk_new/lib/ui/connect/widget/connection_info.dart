import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';

class ConnectionInfo extends ConsumerWidget {
  const ConnectionInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientProvider);
    return Center(
      child: client.isConnected
          ? Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF88),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  client.address ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PORT  ${client.port}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    letterSpacing: 4,
                  ),
                ),
              ],
            )
          : const Text(
              'NOT CONNECTED',
              style: TextStyle(
                color: Colors.white12,
                fontSize: 18,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),
    );
  }
}
