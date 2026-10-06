import 'package:flutter/material.dart';

/// The cutout and corner brackets drawn over the camera preview.
///
/// A rectangle alone does not tell the user where to aim; brackets do, because
/// they read as a target even with no other instruction on screen.
class QrViewfinder extends StatelessWidget {
  const QrViewfinder({super.key, required this.window, this.bracket = 28});

  final Rect window;

  /// Length of each corner arm.
  final double bracket;

  static const strokeWidth = 3.0;
  static const accent = Color(0xFF00FF88);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ViewfinderPainter(window: window, bracket: bracket),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter({required this.window, required this.bracket});

  final Rect window;
  final double bracket;

  @override
  void paint(Canvas canvas, Size size) {
    // Scrim everything outside the window. `difference` rather than four
    // rectangles, so a window that overflows the preview cannot leave an
    // undimmed strip behind.
    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(
          RRect.fromRectAndRadius(window, const Radius.circular(12)),
        ),
      ),
      scrim,
    );

    // A faint full outline, then the brackets on top of it. The outline alone
    // reads as a frame to aim at; the brackets alone read as marks.
    canvas.drawRRect(
      RRect.fromRectAndRadius(window, const Radius.circular(12)),
      Paint()
        ..color = QrViewfinder.accent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = QrViewfinder.strokeWidth,
    );

    final arm = Paint()
      ..color = QrViewfinder.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = QrViewfinder.strokeWidth
      ..strokeCap = StrokeCap.square;

    // Inset by half the stroke so the brackets sit on the edge instead of
    // straddling it.
    canvas.drawPath(
      _corners(window.deflate(QrViewfinder.strokeWidth / 2)),
      arm,
    );
  }

  Path _corners(Rect r) {
    return Path()
      ..moveTo(r.left, r.top + bracket)
      ..lineTo(r.left, r.top)
      ..lineTo(r.left + bracket, r.top)
      ..moveTo(r.right - bracket, r.top)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right, r.top + bracket)
      ..moveTo(r.right, r.bottom - bracket)
      ..lineTo(r.right, r.bottom)
      ..lineTo(r.right - bracket, r.bottom)
      ..moveTo(r.left + bracket, r.bottom)
      ..lineTo(r.left, r.bottom)
      ..lineTo(r.left, r.bottom - bracket);
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) =>
      old.window != window || old.bracket != bracket;
}
