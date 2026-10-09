import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/ui/state/connection_controller.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/view/controller_editor_view.dart';
import 'package:gamypad_controller/src/ui/view/controller_view.dart';
import 'package:gamypad_controller/src/ui/view/qr_scan_view.dart';
import 'package:gamypad_controller/src/ui/view/setting_view.dart';
import 'package:gamypad_controller/src/ui/widgets/home/connect_button.dart';
import 'package:gamypad_controller/src/ui/widgets/home/connection_status_badge.dart';
import 'package:gamypad_controller/src/ui/widgets/home/error_banner.dart';
import 'package:gamypad_controller/src/ui/widgets/home/target_fields.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/scan_button.dart';
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

  Future<void> _reconnect() =>
      ref.read(connectionControllerProvider.notifier).reconnect();

  Future<void> _play() => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => const ControllerView()));

  Future<void> _editLayout() async {
    final controller = ref.read(layoutControllerProvider.notifier);
    final active = ref.read(layoutControllerProvider).value;
    // The built-in default is never edited in place: editing it starts a fresh
    // "New Layout" draft instead.
    final isNew =
        active == null || active.name == DefaultLayout.layout.name;
    if (isNew) await controller.startNew();
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ControllerEditorView(isNew: isNew)),
    );
  }

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

                  ScanButton(enabled: !connected, onPressed: _scan),

                  const SizedBox(height: 12),

                  if (connected)
                    GamepadButton(onPress: _play)
                  else
                    ConnectButton(
                      status: connection.status,
                      busy: connection.busy,
                      enabled: _target != null,
                      onConnect: connection.isLost ? _reconnect : _connect,
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
                  TextButton.icon(
                    onPressed: _editLayout,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('EDIT CURRENT LAYOUT'),
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
