import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/ui/widgets/home/home_palette.dart';
import 'package:gamypad_controller/src/ui/widgets/qr/qr_viewfinder.dart';
import 'package:gamypad_controller/src/ui/widgets/qr/scan_hint.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({super.key});

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _torchOn = false;
  String? _rejectedCode;

  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_done) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      final target = UdpTarget.tryParse(raw);
      if (target == null) {
        if (mounted && _rejectedCode != raw) {
          setState(() => _rejectedCode = raw);
        }
        return;
      }

      _done = true;
      await _controller.stop();
      if (!mounted) return;
      Navigator.of(context).pop(target);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'SCAN QR',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Square, centred, and never larger than the preview in
                  // either axis: a window wider than the preview would leave
                  // the brackets clipped at the sides.
                  final side = constraints.biggest.shortestSide * 0.7;
                  final window = Rect.fromCenter(
                    center: constraints.biggest.center(Offset.zero),
                    width: side,
                    height: side,
                  );

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                        scanWindow: window,
                        errorBuilder: (context, error) => _CameraError(
                          error: error,

                          onRetry: () async {
                            await _controller.stop();
                            await _controller.start();
                          },
                        ),
                      ),
                      QrViewfinder(window: window),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: ScanHint(
                torchOn: _torchOn,
                rejectedCode: _rejectedCode,
                onToggleTorch: () async {
                  await _controller.toggleTorch();
                  if (!mounted) return;
                  setState(() => _torchOn = !_torchOn);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onRetry});

  final MobileScannerException error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                size: 40,
                color: HomePalette.muted,
              ),
              const SizedBox(height: 16),
              Text(
                switch (error.errorCode) {
                  MobileScannerErrorCode.permissionDenied =>
                    'Gamypad needs camera access to read the QR code. '
                        'Enable it in Settings.',
                  MobileScannerErrorCode.unsupported =>
                    'This device has no camera the scanner can use.',
                  _ => 'The camera could not be started.',
                },
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: HomePalette.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: HomePalette.accent,
                  side: const BorderSide(color: HomePalette.accent),
                ),
                child: const Text('TRY AGAIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
