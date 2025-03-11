import 'dart:io';
import 'dart:ui';
import 'package:equus/screens/appointment/image_coordinates_picker.dart';
import 'package:flutter/material.dart';

import 'coordinates_painter.dart';

class SliderImageCoordinatesPicker extends StatefulWidget {
  File? selectedImage;
  final List<Offset> coordinates;
  int? imageWidth;
  int? imageHeight;

  SliderImageCoordinatesPicker({
    super.key,
    required this.selectedImage,
    required this.coordinates,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  _SliderImageCoordinatesPickerState createState() =>
      _SliderImageCoordinatesPickerState();
}

class _SliderImageCoordinatesPickerState extends State<SliderImageCoordinatesPicker> {
  List<Offset> _localCoordinates = [];
  List<Offset>? screen1Coordinates= [];
  List<Offset>? screen2Coordinates= [];
  List<Offset>? screen3Coordinates= [];
  List<Offset>? screen4Coordinates= [];
  List<Offset>? screen5Coordinates= [];
  List<Offset>? screen6Coordinates= [];
  List<Offset>? screen7Coordinates= [];


  int _currentPageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _localCoordinates = List.from(widget.coordinates);
  }

  @override
  void didUpdateWidget(covariant SliderImageCoordinatesPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coordinates != oldWidget.coordinates) {
      _localCoordinates = List.from(widget.coordinates);
    }
  }

  void _undoCoordinate() {
    setState(() {
      if (_localCoordinates.isNotEmpty) {
        _localCoordinates.removeLast();
      }
    });
  }

  void _goToPreviousPage() {
    setState(() {
      if (_currentPageIndex > 0) {
        _currentPageIndex--;

      }
    });
  }

  void _goToNextPage() {
    setState(() {
      if (_currentPageIndex < _buildScreens().length - 1) {
        _currentPageIndex++;
      }
    });
  }

  List<Widget> _buildScreens() {
    return [
      _imageCoordinatesPicker1(Colors.purple[900]!),
      _imageCoordinatesPicker2(Colors.purple[200]!),
      _imageCoordinatesPicker3(Colors.white),
      _imageCoordinatesPicker4(Colors.blue),
      _imageCoordinatesPicker5(Colors.orange),
      _imageCoordinatesPicker6(Colors.red),
      _imageCoordinatesPicker7(Colors.green),
      _buildCoordinatesScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens(); // Get the list of screens

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, widget.selectedImage);
          },
        ),
        title: const Text('Image Coordinates Picker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoCoordinate,
            tooltip: 'Undo Last Coordinate',
          ),
        ],
      ),
      body: Column( // Changed body to Column
        children: [
          Expanded( // Wrap the screen content with Expanded
            child: IndexedStack( // Use IndexedStack to show current page
              index: _currentPageIndex,
              children: screens,
            ),
          ),
          Padding( // Add padding for buttons
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null, // Disable if on first page
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _currentPageIndex < screens.length - 1 ? _goToNextPage : null, // Disable if on last page
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
      // Removed BottomNavigationBar
    );
  }

  Widget _imageCoordinatesPicker1(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      canvas.drawCircle(imageCoordinates, 10, paint);


      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen1Coordinates!.add(imageCoordinates);


      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: addCoordinate,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen1Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker2(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      for (var coordinate in _localCoordinates) {
        canvas.drawCircle(coordinate, 10, paint);
      }

      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> _addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen2Coordinates!.add(imageCoordinates);
      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: _addCoordinate,
      //onDoubleTap: _saveImageWithCoordinates, // Save on double tap
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen2Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker3(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      canvas.drawCircle(imageCoordinates, 10, paint);


      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen3Coordinates!.add(imageCoordinates);


      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: addCoordinate,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen3Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker4(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      canvas.drawCircle(imageCoordinates, 10, paint);


      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen4Coordinates!.add(imageCoordinates);


      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: addCoordinate,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen4Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker5(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      canvas.drawCircle(imageCoordinates, 10, paint);


      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen5Coordinates!.add(imageCoordinates);


      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: addCoordinate,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen5Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker6(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      canvas.drawCircle(imageCoordinates, 10, paint);


      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen6Coordinates!.add(imageCoordinates);


      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: addCoordinate,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen6Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker7(Color paintColor) {
    GlobalKey imageKey = GlobalKey();



    Future<void> _saveImageWithCoordinates(Offset imageCoordinates) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
      await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      canvas.drawCircle(imageCoordinates, 10, paint);


      final img = await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath = widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        _localCoordinates.add(imageCoordinates);
        widget.selectedImage = newImageFile;
      });
    }


    Future<void> addCoordinate(TapDownDetails details) async {
      final RenderBox renderBox =
      imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
      renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = widget.imageWidth! / displayWidth;
      final double scaleY = widget.imageHeight! / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screen7Coordinates!.add(imageCoordinates);


      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        await _saveImageWithCoordinates(imageCoordinates);
      }
    }

    return GestureDetector(
      onTapDown: addCoordinate,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen7Coordinates!,
                  imageWidth: widget.imageWidth!,
                  imageHeight: widget.imageHeight!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Widget _imageCoordinatesPicker1() {
  //   GlobalKey imageKey = GlobalKey();

  //   void _addCoordinate(TapDownDetails details) {
  //     final RenderBox? renderBox =
  //         imageKey.currentContext?.findRenderObject() as RenderBox?;
  //     if (renderBox == null) return; // Ensure renderBox is not null

  //     final Offset localPosition =
  //         renderBox.globalToLocal(details.globalPosition);

  //     final double displayWidth = renderBox.size.width;
  //     final double displayHeight = renderBox.size.height;

  //     final decodedImage =
  //         decodeImageFromList(widget.selectedImage!.readAsBytesSync());
  //     decodedImage.then((image) {
  //       final double imageWidth = image.width.toDouble();
  //       final double imageHeight = image.height.toDouble();

  //       // Calculate scale factors
  //       final double scaleX = imageWidth / displayWidth;
  //       final double scaleY = imageHeight / displayHeight;

  //       // Convert screen coordinates to image coordinates
  //       final double imageX = localPosition.dx * scaleX;
  //       final double imageY = localPosition.dy * scaleY;

  //       setState(() {
  //         _localCoordinates.add(Offset(imageX, imageY));
  //       });
  //     });
  //   }

  //   Future<void> _saveImageWithCoordinates() async {
  //     final recorder = PictureRecorder();
  //     final canvas = Canvas(recorder);
  //     final image =
  //         await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

  //     final paint = Paint()
  //       ..color = Colors.red
  //       ..style = PaintingStyle.fill;

  //     // Draw image
  //     canvas.drawImage(image, Offset.zero, Paint());

  //     // Draw coordinates as circles
  //     for (var coordinate in _localCoordinates) {
  //       canvas.drawCircle(coordinate, 10, paint);
  //     }

  //     final img =
  //         await recorder.endRecording().toImage(image.width, image.height);
  //     final byteData = await img.toByteData(format: ImageByteFormat.png);
  //     final buffer = byteData!.buffer.asUint8List();

  //     final newImagePath =
  //         widget.selectedImage!.path.replaceAll('.png', '_updated.png');
  //     final newImageFile = File(newImagePath);
  //     await newImageFile.writeAsBytes(buffer);

  //     setState(() {
  //       widget.selectedImage = newImageFile;
  //     });
  //   }

  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       return GestureDetector(
  //         onTapDown: _addCoordinate,
  //         onDoubleTap: _saveImageWithCoordinates,
  //         child: Center(
  //           child: Stack(
  //             children: [
  //               Image.file(widget.selectedImage!,
  //                   key: imageKey, fit: BoxFit.contain),
  //               ..._localCoordinates.map((coordinate) {
  //                 return Positioned(
  //                   left: coordinate.dx /
  //                       (imageKey.currentContext?.size?.width ?? 1) *
  //                       constraints.maxWidth,
  //                   top: coordinate.dy /
  //                       (imageKey.currentContext?.size?.height ?? 1) *
  //                       constraints.maxHeight,
  //                   child: const Icon(Icons.add, color: Colors.red, size: 20),
  //                 );
  //               }).toList(),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildCoordinatesScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Coordinates:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _localCoordinates.isNotEmpty
                ? ListView.builder(
                    itemCount: _localCoordinates.length,
                    itemBuilder: (context, index) {
                      final coordinate = _localCoordinates[index];
                      return ListTile(
                        title: Text(
                            'Coordinate ${index + 1}: (${coordinate.dx.toStringAsFixed(2)}, ${coordinate.dy.toStringAsFixed(2)})'),
                      );
                    },
                  )
                : const Center(child: Text('No coordinates selected yet.')),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen3() {
    return _buildHelpScreen(screenNumber: 3);
  }

  Widget _buildScreen4() {
    return _buildHelpScreen(screenNumber: 4);
  }

  Widget _buildScreen5() {
    return _buildHelpScreen(screenNumber: 5);
  }

  Widget _buildScreen6() {
    return _buildHelpScreen(screenNumber: 6);
  }

  Widget _buildScreen7() {
    return _buildHelpScreen(screenNumber: 7);
  }

  Widget _buildHelpScreen({int screenNumber = 0}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen $screenNumber Help & Instructions:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'This is the help and instructions screen number $screenNumber. You can add specific content for screen $screenNumber here.\n\n'
            'For example, you might want to describe the functionality or purpose of screen $screenNumber in detail here.',
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
