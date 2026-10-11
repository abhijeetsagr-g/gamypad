import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/settings/server_settings.dart';
import 'package:gamypad_pc/src/ui/state/notifier.dart';
import 'package:gamypad_pc/src/ui/state/server_settings_controller.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _port = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _port.dispose();
    super.dispose();
  }

  String? _validate(String? text) {
    final port = int.tryParse((text ?? '').trim());
    if (port == null) return 'Enter a number';
    if (!isValidPort(port)) return '0 for random, or $minPort-$maxPort';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final port = int.parse(_port.text.trim());
    await ref.read(serverSettingsControllerProvider.notifier).setPort(port);
    if (!mounted) return;
    final running = ref.read(serverControllerProvider).isRunning;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          running ? 'Saved. Restart the server to apply.' : 'Saved.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(serverSettingsControllerProvider);
    final running = ref.watch(serverControllerProvider).isRunning;

    if (!_loaded && settings.hasValue) {
      _loaded = true;
      _port.text = '${settings.requireValue.port}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _port,
                    enabled: settings.hasValue,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validate,
                    onFieldSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      labelText: 'Server port',
                      helperText:
                          '0 picks a random free port each time the server '
                          'starts.',
                      helperMaxLines: 2,
                    ),
                  ),
                  if (running) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'The server is running — changes apply on next start.',
                      style: TextStyle(color: ColorPalette.muted, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: settings.hasValue ? _save : null,
                    child: const Text('SAVE'),
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
