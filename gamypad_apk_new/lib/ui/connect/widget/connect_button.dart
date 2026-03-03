import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';

class ConnectButton extends ConsumerWidget {
  const ConnectButton({super.key, required this.onPress});
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientProvider);
    final loading = client.isLoading ?? false;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                client.isConnected ? 'Show Gamepad' : 'CONNECT',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
