import 'dart:io';
import 'package:equus/screens/appointment/coordinates_painter.dart';
import 'package:flutter/material.dart';

class ImageCoordinatesPicker extends StatefulWidget {
  final File image;
  final int imageWidth;
  final int imageHeight;

  const ImageCoordinatesPicker({
    super.key,
    required this.image,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  State<ImageCoordinatesPicker> createState() => _ImageCoordinatesPickerState();
}

class _ImageCoordinatesPickerState extends State<ImageCoordinatesPicker> {
  final List<Offset> _coordinates = [];
  final GlobalKey _imageKey = GlobalKey();

  void _addCoordinate(TapUpDetails details) {
    final RenderBox renderBox =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Size displayedSize = renderBox.size;

    final Offset tapPosition = details.localPosition;

    // Escalar para coordenadas reais da imagem
    final double scaleX = widget.imageWidth / displayedSize.width;
    final double scaleY = widget.imageHeight / displayedSize.height;

    final double realX = tapPosition.dx * scaleX;
    final double realY = tapPosition.dy * scaleY;

    setState(() {
      _coordinates.add(Offset(realX, realY));
    });

    debugPrint(
        "Marcado ponto real: (${realX.toStringAsFixed(2)}, ${realY.toStringAsFixed(2)})");
  }

  void _finishSelection() {
    Navigator.pop(context, _coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Coordenadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _finishSelection,
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTapUp: _addCoordinate,
          child: Stack(
            children: [
              Image.file(
                widget.image,
                key: _imageKey,
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: CoordinatePainter(
                    coordinates: _coordinates,
                    imageWidth: widget.imageWidth,
                    imageHeight: widget.imageHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
