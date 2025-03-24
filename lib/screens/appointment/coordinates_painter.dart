import 'package:flutter/material.dart';

class CoordinatesPainter extends CustomPainter {
  final List<Offset> coordinates;
  final int imageWidth;
  final int imageHeight;
  final Color color;

  CoordinatesPainter(
    this.color, {
    required this.coordinates,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Escalar as coordenadas reais para o tamanho da imagem exibida
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final crossSize = 40.0;
    final crossHalfSize = crossSize / 2;

    for (final coord in coordinates) {
      final displayedX = coord.dx * scaleX;
      final displayedY = coord.dy * scaleY;

      final center = Offset(displayedX, displayedY);
      final horizontalStart = Offset(center.dx - crossHalfSize, center.dy);
      final horizontalEnd = Offset(center.dx + crossHalfSize, center.dy);
      final verticalStart = Offset(center.dx, center.dy - crossHalfSize);
      final verticalEnd = Offset(center.dx, center.dy + crossHalfSize);

      canvas.drawLine(horizontalStart, horizontalEnd, paint);
      canvas.drawLine(verticalStart, verticalEnd, paint);
    }

    if (coordinates.length == 2) {
      canvas.drawLine(
          coordinates[0] * scaleX, coordinates[1] * scaleY, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
