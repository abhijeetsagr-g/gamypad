import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/home/pairing_address.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

const double _qrSize = 168;

class PairingPanel extends StatelessWidget {
  const PairingPanel({
    super.key,
    required this.running,
    required this.connected,
    required this.address,
  });

  final bool running;
  final bool connected;
  final String address;

  @override
  Widget build(BuildContext context) {
    if (!running) return const _ServerOff();
    if (address.isEmpty) return const _BindingSpinner();
    return _ScanToPair(connected: connected, address: address);
  }
}

class _ServerOff extends StatelessWidget {
  const _ServerOff();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'SERVER OFF',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: ColorPalette.muted,
        fontSize: 18,
        letterSpacing: 4,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

class _BindingSpinner extends StatelessWidget {
  const _BindingSpinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _qrSize,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ScanToPair extends StatelessWidget {
  const _ScanToPair({required this.connected, required this.address});

  final bool connected;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: address,
          version: QrVersions.auto,
          size: _qrSize,
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 16),
        PairingAddress(address: address),
        const SizedBox(height: 8),
        Text(
          connected ? 'DEVICE CONNECTED' : 'WAITING FOR DEVICE',
          style: TextStyle(
            color: connected ? ColorPalette.accent : ColorPalette.muted,
            fontSize: 12,

            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
