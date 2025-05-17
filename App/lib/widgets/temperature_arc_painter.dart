import 'package:flutter/material.dart';

class TemperatureArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color progressColor;

  TemperatureArcPainter({required this.progress, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Define the arc angles (in radians)
    // We want the arc to go from bottom left to bottom right
    // -135° to 135° in radians
    const startAngle = -2.35; // -135°
    const sweepAngle = 4.7; // 270°

    // Draw the progress arc
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
