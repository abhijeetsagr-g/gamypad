import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/ui/state/connection_controller.dart';
import 'package:gamypad_controller/src/ui/view/controller_editor_view.dart';
import 'package:gamypad_controller/src/ui/view/controller_view.dart';
import 'package:gamypad_controller/src/ui/view/qr_scan_view.dart';
import 'package:gamypad_controller/src/ui/view/setting_view.dart';
import 'package:gamypad_controller/src/ui/widgets/home/connect_button.dart';
import 'package:gamypad_controller/src/ui/widgets/home/connection_status_badge.dart';
import 'package:gamypad_controller/src/ui/widgets/home/error_banner.dart';
import 'package:gamypad_controller/src/ui/widgets/home/target_fields.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _host = TextEditingController();
  final _port = TextEditingController();

  UdpTarget? _target;
  String? _validationError;

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  /// Opens the scanner and adopts whatever it reads.
  Future<void> _scan() async {
    final scanned = await Navigator.of(
      context,
    ).push<UdpTarget>(MaterialPageRoute(builder: (_) => const QrScanView()));
    if (scanned == null || !mounted) return;

    setState(() {
      _host.text = scanned.host;
      _port.text = scanned.port.toString();
      _target = scanned;
      _validationError = null;
    });
  }

  Future<void> _connect() async {
    final target = _target;
    if (target == null) {
      setState(() => _validationError = _invalidPairMessage());
      return;
    }

    await ref.read(connectionControllerProvider.notifier).connect(target);

    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  /// Why the pair was refused, in terms of what the fields hold.
  String _invalidPairMessage() {
    if (_host.text.trim().isEmpty && _port.text.trim().isEmpty) {
      return 'Enter an address and port, or scan the QR code on your PC.';
    }
    if (_port.text.trim().isEmpty) return 'Enter a port between 1 and 65535.';
    return 'That is not an address Gamypad can connect to. '
        'Check the address and port, or scan the QR code again.';
  }

  Future<void> _disconnect() =>
      ref.read(connectionControllerProvider.notifier).disconnect();

  Future<void> _play() => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => const ControllerView()));

  Future<void> _editLayout() => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => const ControllerEditorView()));

  Future<void> _settings() => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => const SettingView()));

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(connectionControllerProvider);
    final connected = connection.isConnected;
    final error = _validationError ?? connection.error;

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
          IconButton(
            onPressed: _settings,
            icon: const Icon(Icons.settings, size: 22),
            color: ColorPalette.muted,
            tooltip: 'Settings',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: ConnectionStatusBadge(status: connection.status),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'WIRELESS CONTROLLER',
                    style: TextStyle(
                      color: ColorPalette.muted,
                      fontSize: 11,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  TargetFields(
                    host: _host,
                    port: _port,
                    onChanged: (target) => setState(() {
                      _target = target;
                      _validationError = null;
                    }),
                  ),

                  if (error case final message?) ...[
                    const SizedBox(height: 16),
                    ErrorBanner(message: message),
                  ],

                  const SizedBox(height: 32),

                  _ScanButton(enabled: !connected, onPressed: _scan),

                  const SizedBox(height: 12),

                  ConnectButton(
                    status: connection.status,
                    busy: connection.busy,
                    enabled: _target != null,
                    onConnect: connected ? _disconnect : _connect,
                  ),

                  if (connected) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _disconnect,
                      style: TextButton.styleFrom(
                        foregroundColor: ColorPalette.muted,
                      ),
                      child: const Text('DISCONNECT'),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _play,
                      icon: const Icon(Icons.sports_esports, size: 20),
                      label: const Text('GAMEPAD'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorPalette.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  TextButton.icon(
                    onPressed: _editLayout,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('EDIT LAYOUT'),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorPalette.muted,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the QR scanner.
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.qr_code_scanner, size: 20),
        label: const Text('SCAN QR'),
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.accent,
          disabledForegroundColor: ColorPalette.dim,
          side: const BorderSide(color: ColorPalette.accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
