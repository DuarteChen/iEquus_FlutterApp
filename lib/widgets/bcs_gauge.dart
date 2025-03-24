import 'package:flutter/material.dart';
import 'dart:math';

class GaugePainter extends CustomPainter {
  final double bcsValue;

  GaugePainter(this.bcsValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height / 4);
    final radius = size.width / 2;

    final fullSweepAngle = pi;
    const startAngle = -pi;

    final clampedBCS = bcsValue.clamp(1, 5);
    final sweepAngle = (clampedBCS) * (fullSweepAngle / 5);

    // Background arc (full scale)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweepAngle,
      false,
      backgroundPaint,
    );

    // Foreground arc (BCS value)
    final arcPaint = Paint()
      ..color = Color.fromARGB(255, 46, 95, 138)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw BCS value at the center
    final textSpan = TextSpan(
      text: clampedBCS.toInt().toString(),
      style: const TextStyle(
        color: Color.fromARGB(255, 46, 95, 138),
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2 - 10, // Adjust position slightly
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GaugePainter) {
      return oldDelegate.bcsValue != bcsValue;
    }
    return false;
  }
}
