import 'dart:io';
import 'package:flutter/material.dart';

class ImageCoordinatesPicker extends StatefulWidget {
  final File image;

  const ImageCoordinatesPicker({super.key, required this.image});

  @override
  State<ImageCoordinatesPicker> createState() => _ImageCoordinatesPickerState();
}

class _ImageCoordinatesPickerState extends State<ImageCoordinatesPicker> {
  final List<Offset> _coordinates = [];

  void _addCoordinate(TapDownDetails details) {
    if (_coordinates.length < 14) {
      setState(() {
        _coordinates.add(details.localPosition);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select 14 Coordinates"),
        actions: [
          if (_coordinates.length == 14)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _coordinates);
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTapDown: _addCoordinate,
        child: Stack(
          children: [
            Image.file(widget.image, fit: BoxFit.cover, width: double.infinity),
            ..._coordinates.map(
              (point) => Positioned(
                left: point.dx - 8,
                top: point.dy - 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
