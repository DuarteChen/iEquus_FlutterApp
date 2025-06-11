import 'dart:io';
import 'package:equus/screens/measure/coordinates_painter.dart';
import 'package:flutter/material.dart';

class ImageCoordinatesPicker extends StatefulWidget {
  final File image;
  final List<Offset> coordinates;
  final Color color;

  const ImageCoordinatesPicker({
    super.key,
    required this.image,
    required this.coordinates,
    required this.color,
  });

  @override
  State<ImageCoordinatesPicker> createState() => _ImageCoordinatesPickerState();
}

class _ImageCoordinatesPickerState extends State<ImageCoordinatesPicker> {
  final GlobalKey _imageKey = GlobalKey();
  File? _paintedImageFile;
  int imageWidth = 0;
  int imageHeight = 0;

  @override
  void initState() {
    super.initState();
    _paintedImageFile = File(widget.image.path);
  }

  Future<void> _addCoordinate(TapUpDetails details) async {
    final image = await decodeImageFromList(widget.image.readAsBytesSync());

    imageWidth = image.width;
    imageHeight = image.height;

    final RenderBox renderBox =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Size displayedSize = renderBox.size;

    final Offset tapPosition = details.localPosition;

    // Escalar para coordenadas reais da imagem
    final double scaleX = imageWidth / displayedSize.width;
    final double scaleY = imageHeight / displayedSize.height;

    final double realX = tapPosition.dx * scaleX;
    final double realY = tapPosition.dy * scaleY;

    setState(() {
      widget.coordinates.add(Offset(realX, realY));
    });
    debugPrint(
        "Ponto real marcado: (${realX.toStringAsFixed(2)}, ${realY.toStringAsFixed(2)})");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _addCoordinate,
      child: Stack(
        children: [
          Image.file(
            _paintedImageFile!,
            key: _imageKey,
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: CoordinatesPainter(
                widget.color,
                coordinates: widget.coordinates,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
