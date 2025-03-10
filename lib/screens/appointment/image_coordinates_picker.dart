import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:equus/screens/appointment/coordinates_painter.dart';
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
    //TODO remove prints
    debugPrint(
        "Ponto real marcado: (${realX.toStringAsFixed(2)}, ${realY.toStringAsFixed(2)})");
  }

  Future<void> _finishSelection() async {
    await _paintCrosshairOnImagePermanent(
      imageFile: _paintedImageFile!,
      points: widget.coordinates,
      coordinateColor: widget.color,
    );
    Navigator.pop(context, widget.coordinates); // Send coordinates back
  }

  Future<void> _paintCrosshairOnImagePermanent({
    required File imageFile,
    required List<Offset> points,
    required Color coordinateColor,
  }) async {
    final ui.Image image = await _loadImage(imageFile);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    _paintCrosshairsOnCanvas(canvas, image, points, coordinateColor);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image paintedImage =
        await picture.toImage(image.width, image.height);
    final ByteData? byteData =
        await paintedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      await imageFile.writeAsBytes(pngBytes);
      setState(() {});
    }
  }

  Future<ui.Image> _loadImage(File imageFile) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      await imageFile.readAsBytes(),
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  void _paintCrosshairsOnCanvas(Canvas canvas, ui.Image image,
      List<Offset> points, Color coordinateColor) {
    // Draw the image as the base
    paintImage(
      canvas: canvas,
      rect:
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      image: image,
      fit: BoxFit.fill,
    );

    final crossSize = 50.0;
    final crossHalfSize = crossSize / 2;
    final paint = Paint()
      ..color = coordinateColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final point in points) {
      final center = point;
      final horizontalStart = Offset(center.dx - crossHalfSize, center.dy);
      final horizontalEnd = Offset(center.dx + crossHalfSize, center.dy);
      final verticalStart = Offset(center.dx, center.dy - crossHalfSize);
      final verticalEnd = Offset(center.dx, center.dy + crossHalfSize);

      canvas.drawLine(horizontalStart, horizontalEnd, paint);
      canvas.drawLine(verticalStart, verticalEnd, paint);
    }
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
