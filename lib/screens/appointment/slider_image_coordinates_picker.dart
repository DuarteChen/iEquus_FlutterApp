import 'dart:io';
import 'dart:ui';
import 'package:equus/screens/appointment/image_coordinates_picker.dart';
import 'package:flutter/material.dart';

class SliderImageCoordinatesPicker extends StatefulWidget {
  File? selectedImage;
  final List<Offset> coordinates;

  SliderImageCoordinatesPicker({
    super.key,
    required this.selectedImage,
    required this.coordinates,
  });

  @override
  _SliderImageCoordinatesPickerState createState() =>
      _SliderImageCoordinatesPickerState();
}

class _SliderImageCoordinatesPickerState
    extends State<SliderImageCoordinatesPicker> {
  List<Offset> _localCoordinates = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slider Image Coordinates Picker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoCoordinate,
            tooltip: 'Undo Last Coordinate',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          _imageCoordinatesPicker1(),
          _buildCoordinatesScreen(),
          _buildScreen3(),
          _buildScreen4(),
          _buildScreen5(),
          _buildScreen6(),
          _buildScreen7(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType
            .fixed, // To show all labels when more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '4',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '5',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '6',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '7',
          ),
        ],
      ),
    );
  }

  Widget _imageCoordinatesPicker1() {
    GlobalKey imageKey = GlobalKey();

    void _addCoordinate(TapDownDetails details) {
      final RenderBox renderBox =
          imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
          renderBox.globalToLocal(details.globalPosition);

      final double imageWidth = renderBox.size.width;
      final double imageHeight = renderBox.size.height;

      if (localPosition.dx >= 0 &&
          localPosition.dx <= imageWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= imageHeight) {
        setState(() {
          _localCoordinates.add(localPosition);
        });
      }
    }

    Future<void> _saveImageWithCoordinates() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final image =
          await decodeImageFromList(widget.selectedImage!.readAsBytesSync());

      final paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawImage(image, Offset.zero, Paint());
      for (var coordinate in _localCoordinates) {
        canvas.drawCircle(coordinate, 10, paint);
      }

      final img =
          await recorder.endRecording().toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final newImagePath =
          widget.selectedImage!.path.replaceAll('.png', '_updated.png');
      final newImageFile = File(newImagePath);
      await newImageFile.writeAsBytes(buffer);

      setState(() {
        widget.selectedImage = newImageFile;
      });
    }

    return GestureDetector(
      onTapDown: _addCoordinate,
      onDoubleTap: _saveImageWithCoordinates,
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage!,
                key: imageKey, fit: BoxFit.contain),
            ..._localCoordinates.map((coordinate) => Positioned(
                  left: coordinate.dx - 10,
                  top: coordinate.dy - 10,
                  child: const Icon(Icons.add, color: Colors.red, size: 20),
                )),
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
