import 'dart:io';
import 'package:equus/screens/appointment/image_coordinates_picker.dart';
import 'package:flutter/material.dart';

class SliderImageCoordinatesPicker extends StatefulWidget {
  final File? selectedImage;
  final List<Offset> coordinates;

  const SliderImageCoordinatesPicker({
    super.key,
    required this.selectedImage,
    required this.coordinates,
  });

  @override
  _SliderImageCoordinatesPickerState createState() => _SliderImageCoordinatesPickerState();
}

class _SliderImageCoordinatesPickerState extends State<SliderImageCoordinatesPicker> {
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
        type: BottomNavigationBarType.fixed, // To show all labels when more than 3 items
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
    List<Offset> tempCoordinates = [];


    final colorCoordinatesRosaEscuro = Colors.purple[800]!;

    return ImageCoordinatesPicker(image: widget.selectedImage!, coordinates: tempCoordinates, color: colorCoordinatesRosaEscuro);
  }

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
                  title: Text('Coordinate ${index + 1}: (${coordinate.dx.toStringAsFixed(2)}, ${coordinate.dy.toStringAsFixed(2)})'),
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