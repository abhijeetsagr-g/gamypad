import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _hostController = TextEditingController(text: '192.168.1.');
  final _portController = TextEditingController(text: '8080');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // listen for server-side disconnection
    ref.listenManual(clientProvider, (prev, next) {
      if (prev?.isConnected == true && next.isConnected == false) {
        _snack('Server disconnected', error: true);
      }
    });
  }

  Future<void> _toggle() async {
    final notifier = ref.read(clientProvider.notifier);
    final connected = ref.read(clientProvider).isConnected;

    if (connected) {
      notifier.disconnect();
      return;
    }

    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());

    if (host.isEmpty || port == null) {
      _snack('Enter a valid host and port', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await notifier.connect(host, port);
      _snack('Connected to $host:$port');
    } catch (e) {
      _snack('Failed to connect: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red[800] : Colors.green[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientProvider);
    final connected = client.isConnected;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'GAMYPAD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'WIRELESS CONTROLLER',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),

              const Spacer(),

              // Connection info
              Center(
                child: connected
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
              ),

              const Spacer(),

              // Fields
              if (!connected) ...[
                _field(
                  'HOST / IP ADDRESS',
                  _hostController,
                  TextInputType.number,
                ),
                const SizedBox(height: 12),
                _field('PORT', _portController, TextInputType.number),
                const SizedBox(height: 24),
              ],

              // Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _toggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: connected
                        ? Colors.red[900]
                        : const Color(0xFF00FF88),
                    foregroundColor: connected ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          connected ? 'DISCONNECT' : 'CONNECT',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            fontSize: 14,
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

  Widget _field(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
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
