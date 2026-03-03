import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/core/utils/show_snackbar.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';
import 'package:gamypad_apk_new/ui/connect/widget/connect_button.dart';
import 'package:gamypad_apk_new/ui/connect/widget/connection_info.dart';
import 'package:gamypad_apk_new/ui/connect/widget/input_field.dart';
import 'package:gamypad_apk_new/ui/gamepad/view/gamepad_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ConnectView extends ConsumerStatefulWidget {
  const ConnectView({super.key});

  @override
  ConsumerState<ConnectView> createState() => _ConnectViewState();
}

class _ConnectViewState extends ConsumerState<ConnectView> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();

  Future<void> _scanQR() async {
    bool hasScanned = false;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Scan QR')),
          body: MobileScanner(
            onDetect: (capture) {
              if (hasScanned) return;

              final code = capture.barcodes.first.rawValue;
              if (code != null && code.contains(':')) {
                hasScanned = true;
                final parts = code.split(':');
                _hostController.text = parts[0];
                _portController.text = parts[1];
                Navigator.of(context).pop(); // use Navigator.of(context)
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showGamepad() async {
    final connected = ref.read(clientProvider).isConnected;

    showSnackbar(
      context,
      connected ? "Connected" : "Not Connected",
      error: !connected,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamepadView()),
    );
  }

  Future<void> _connect() async {
    final notifier = ref.read(clientProvider.notifier);

    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());

    if (host.isEmpty || port == null) {
      showSnackbar(context, "Enter a valid host and port", error: true);
      return;
    }

    try {
      await notifier.connect(host, port);
    } catch (e) {
      if (mounted) {
        showSnackbar(
          context,
          "failed to connect: ${e.toString()}",
          error: true,
        );
      }
    } finally {
      _showGamepad();
    }
  }

  Future<void> _disconnect() async {
    final notifier = ref.read(clientProvider.notifier);
    notifier.disconnect();
  }

  // Portrait screen (ConnectScreen)
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // reset when leaving
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(clientProvider).isConnected;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GAMYPAD',
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      connected ? _disconnect() : _showGamepad();
                    },
                    child: Text(connected ? "Disconnect" : "Show Gamepad"),
                  ),
                ],
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

              ConnectionInfo(),

              const Spacer(),
              // replace the MobileScanner widget in the Row with a button:
              IconButton(
                onPressed: _scanQR,
                icon: const Icon(Icons.qr_code_scanner),
              ),
              InputField(
                label: "Host / IP Address",
                controller: _hostController,
                type: TextInputType.numberWithOptions(),
              ),
              SizedBox(height: 10),
              InputField(
                label: "PORT",
                controller: _portController,
                type: TextInputType.number,
              ),

              SizedBox(height: 10),

              ConnectButton(
                onPress: () async {
                  connected ? await _showGamepad() : _connect();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
