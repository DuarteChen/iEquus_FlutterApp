import 'package:flutter/material.dart';

class CoordinatePainter extends CustomPainter {
  final List<Offset> coordinates;
  final int imageWidth;
  final int imageHeight;

  CoordinatePainter({
    required this.coordinates,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Escalar as coordenadas reais para o tamanho da imagem exibida
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    for (final coord in coordinates) {
      final displayedX = coord.dx * scaleX;
      final displayedY = coord.dy * scaleY;

      canvas.drawCircle(Offset(displayedX, displayedY), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Sempre redesenha
  }
}
