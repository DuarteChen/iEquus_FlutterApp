import 'package:flutter/material.dart';
import 'dart:math';

class BCSGauge extends StatefulWidget {
  final int bcsValue;

  const BCSGauge({
    super.key,
    required this.bcsValue,
  });

  @override
  State<BCSGauge> createState() => _BCSGaugeState();
}

class _BCSGaugeState extends State<BCSGauge> {
  @override
  Widget build(BuildContext context) {
    double bcsValue = widget.bcsValue.toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(100, 100),
          painter: GaugePainter(bcsValue),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("BCS", style: TextStyle(fontSize: 32)),
              SizedBox(
                width: 8,
              ),
              Text(bcsValue.toInt().toString(),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class GaugePainter extends CustomPainter {
  double bcsValue;

  GaugePainter(this.bcsValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height / 3.5);
    final radius = size.width / 2;

    bcsValue = bcsValue.clamp(1, 5);

    final fullSweepAngle = pi;
    const startAngle = -pi;

    final sweepAngle = (bcsValue) * (fullSweepAngle / 5);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Compare the old bcsValue with the new one
    if (oldDelegate is GaugePainter) {
      return oldDelegate.bcsValue != bcsValue;
    }
    return false; // Repaint if the oldDelegate is not of type GaugePainter
  }
}
