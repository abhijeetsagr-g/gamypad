import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/home/home_palette.dart';
import 'package:gamypad_pc/src/ui/widgets/home/pairing_address.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Height reserved for the QR code, so the spinner that replaces it during
/// binding does not make the layout jump.
const double _qrSize = 168;

/// The middle of the home screen, in one of three states.
///
/// Takes primitives rather than `ServerState` or `ConnectionState` so it stays
/// independent of the transport and can be dropped into a test without a
/// ProviderContainer.
class PairingPanel extends StatelessWidget {
  const PairingPanel({
    super.key,
    required this.running,
    required this.connected,
    required this.address,
  });

  /// Whether the socket is bound. `idle` and mid-start both count as running:
  /// once the user has asked for a server, "SERVER OFF" would be a lie.
  final bool running;

  /// Whether a controller is currently attached.
  final bool connected;

  /// `ip:port`, or empty until bind() has returned a port.
  final String address;

  @override
  Widget build(BuildContext context) {
    if (!running) return const _ServerOff();
    // Port is only known once bind() completes, so an empty address means start()
    // is still in flight.
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
      style: TextStyle(
        color: HomePalette.dim,
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
            color: connected ? HomePalette.accent : HomePalette.muted,
            fontSize: 12,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
