import 'dart:io';
import 'dart:ui';

import 'package:equus/screens/appointment/coordinates_painter.dart';
import 'package:flutter/material.dart';

class SliderImageCoordinatesPicker extends StatefulWidget {
  final File selectedImage;

  const SliderImageCoordinatesPicker({super.key, required this.selectedImage});

  @override
  State<SliderImageCoordinatesPicker> createState() {
    return _SliderImageCoordinatesPickerState();
  }
}

class _SliderImageCoordinatesPickerState
    extends State<SliderImageCoordinatesPicker> {
  bool isLoading = false;
  File? newImageLocal;

  List<Offset?> localCoordinates = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ];
  List<Offset> screen0Coordinates = [];
  List<Offset> screen1Coordinates = [];
  List<Offset> screen2Coordinates = [];
  List<Offset> screen3Coordinates = [];
  List<Offset> screen4Coordinates = [];
  List<Offset> screen5Coordinates = [];
  List<Offset> screen6Coordinates = [];

  int imageWidth = 0;
  int imageHeight = 0;

  int _currentPageIndex = 0;

  List<Color> screenColors = [
    const Color.fromRGBO(74, 20, 140, 1),
    const Color.fromRGBO(206, 147, 216, 1),
    const Color.fromRGBO(255, 255, 255, 1),
    const Color.fromRGBO(33, 150, 243, 1),
    const Color.fromRGBO(255, 152, 0, 1),
    const Color.fromRGBO(244, 67, 54, 1),
    const Color.fromRGBO(76, 175, 80, 1),
  ];

  List<String> helpImages = [
    'assets/images/measures_lines/line_1.png',
    'assets/images/measures_lines/line_2.png',
    'assets/images/measures_lines/line_3.png',
    'assets/images/measures_lines/line_4.png',
    'assets/images/measures_lines/line_5.png',
    'assets/images/measures_lines/line_6.png',
    'assets/images/measures_lines/line_7.png',
    'assets/images/measures_lines/lines.png',
  ];

  List<String> measures = [
    "Height at the withers",
    "Center of the abdomen",
    "Girth area to withers",
    "Girth area to the back of the belly",
    "Neck width",
    "Neck length",
    "Body length"
  ];

  Map<String, dynamic> result = {};

  @override
  void initState() {
    super.initState();
    //newImageLocal = widget.selectedImage; não preciso que seja logo dada a variável
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    setState(() => isLoading = true);
    final image =
        await decodeImageFromList(widget.selectedImage.readAsBytesSync());
    setState(() {
      imageWidth = image.width;
      imageHeight = image.height;
    });
    setState(() => isLoading = false);
  }

  void _goToPreviousPage() {
    setState(() {
      if (_currentPageIndex == 0) {
        if (screen0Coordinates.length == 1) {
          localCoordinates[0] = screen0Coordinates[0];
        }
        if (screen0Coordinates.length == 2) {
          localCoordinates[1] = screen0Coordinates[1];
        }
      } else if (_currentPageIndex == 1) {
        if (screen1Coordinates.length == 1) {
          localCoordinates[2] = screen1Coordinates[0];
        }
        if (screen1Coordinates.length == 2) {
          localCoordinates[3] = screen1Coordinates[1];
        }
      } else if (_currentPageIndex == 2) {
        if (screen2Coordinates.length == 1) {
          localCoordinates[4] = screen2Coordinates[0];
        }
        if (screen2Coordinates.length == 2) {
          localCoordinates[5] = screen2Coordinates[1];
        }
      } else if (_currentPageIndex == 3) {
        if (screen3Coordinates.length == 1) {
          localCoordinates[6] = screen3Coordinates[0];
        }
        if (screen3Coordinates.length == 2) {
          localCoordinates[7] = screen3Coordinates[1];
        }
      } else if (_currentPageIndex == 4) {
        if (screen4Coordinates.length == 1) {
          localCoordinates[8] = screen4Coordinates[0];
        }
        if (screen4Coordinates.length == 2) {
          localCoordinates[9] = screen4Coordinates[1];
        }
      } else if (_currentPageIndex == 5) {
        if (screen5Coordinates.length == 1) {
          localCoordinates[10] = screen5Coordinates[0];
        }
        if (screen5Coordinates.length == 2) {
          localCoordinates[11] = screen5Coordinates[1];
        }
      } else if (_currentPageIndex == 6) {
        if (screen6Coordinates.length == 1) {
          localCoordinates[12] = screen6Coordinates[0];
        }
        if (screen6Coordinates.length == 2) {
          localCoordinates[13] = screen6Coordinates[1];
        }
      }
      //Change page
      if (_currentPageIndex > 0) {
        _currentPageIndex--;
      }
    });
  }

  void _goToNextPage() async {
    setState(() {
      if (_currentPageIndex == 0) {
        localCoordinates[0] = screen0Coordinates[0];
        localCoordinates[1] = screen0Coordinates[1];
        _currentPageIndex++;
      } else if (_currentPageIndex == 1) {
        localCoordinates[2] = screen1Coordinates[0];
        localCoordinates[3] = screen1Coordinates[1];
        _currentPageIndex++;
      } else if (_currentPageIndex == 2) {
        localCoordinates[4] = screen2Coordinates[0];
        localCoordinates[5] = screen2Coordinates[1];
        _currentPageIndex++;
      } else if (_currentPageIndex == 3) {
        localCoordinates[6] = screen3Coordinates[0];
        localCoordinates[7] = screen3Coordinates[1];
        _currentPageIndex++;
      } else if (_currentPageIndex == 4) {
        localCoordinates[8] = screen4Coordinates[0];
        localCoordinates[9] = screen4Coordinates[1];
        _currentPageIndex++;
      } else if (_currentPageIndex == 5) {
        localCoordinates[10] = screen5Coordinates[0];
        localCoordinates[11] = screen5Coordinates[1];
        _currentPageIndex++;
      } else if (_currentPageIndex == 6) {
        localCoordinates[12] = screen6Coordinates[0];
        localCoordinates[13] = screen6Coordinates[1];
        _currentPageIndex++;
      }
    });
    if (_currentPageIndex == 7) {
      await saveImageWithAllCoordinates();
      setState(() {
        _currentPageIndex = 7; // Ensure the correct screen is shown
      }); // Rebuild the UI after saving the image
    }
  }

  bool pageCoordinatesSizeCheck() {
    if (_currentPageIndex == 0) {
      return screen0Coordinates.length == 2;
    } else if (_currentPageIndex == 1) {
      return screen1Coordinates.length == 2;
    } else if (_currentPageIndex == 2) {
      return screen2Coordinates.length == 2;
    } else if (_currentPageIndex == 3) {
      return screen3Coordinates.length == 2;
    } else if (_currentPageIndex == 4) {
      return screen4Coordinates.length == 2;
    } else if (_currentPageIndex == 5) {
      return screen5Coordinates.length == 2;
    } else if (_currentPageIndex == 6) {
      return screen6Coordinates.length == 2;
    } else {
      return false;
    }
  }

  bool pageBackCoordinatesSizeCheck() {
    if (_currentPageIndex == 0) {
      return screen0Coordinates.isEmpty;
    } else if (_currentPageIndex == 1) {
      return screen1Coordinates.isEmpty;
    } else if (_currentPageIndex == 2) {
      return screen2Coordinates.isEmpty;
    } else if (_currentPageIndex == 3) {
      return screen3Coordinates.isEmpty;
    } else if (_currentPageIndex == 4) {
      return screen4Coordinates.isEmpty;
    } else if (_currentPageIndex == 5) {
      return screen5Coordinates.isEmpty;
    } else if (_currentPageIndex == 6) {
      return screen6Coordinates.isEmpty;
    } else {
      return false;
    }
  }

  bool allCoordinatesFilled() {
    bool result = true;
    for (var element in localCoordinates) {
      if (element == null) {
        result = false;
        break;
      }
    }
    return result;
  }

  void _undoCoordinate() {
    setState(() {
      if (_currentPageIndex == 0) {
        if (screen0Coordinates.isNotEmpty) {
          Offset removed = screen0Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      } else if (_currentPageIndex == 1) {
        if (screen1Coordinates.isNotEmpty) {
          Offset removed = screen1Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      } else if (_currentPageIndex == 2) {
        if (screen2Coordinates.isNotEmpty) {
          Offset removed = screen2Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      } else if (_currentPageIndex == 3) {
        if (screen3Coordinates.isNotEmpty) {
          Offset removed = screen3Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      } else if (_currentPageIndex == 4) {
        if (screen4Coordinates.isNotEmpty) {
          Offset removed = screen4Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      } else if (_currentPageIndex == 5) {
        if (screen5Coordinates.isNotEmpty) {
          Offset removed = screen5Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      } else if (_currentPageIndex == 6) {
        if (screen6Coordinates.isNotEmpty) {
          Offset removed = screen6Coordinates.removeLast();
          localCoordinates.removeWhere((coord) => coord == removed);
        }
      }
    });
  }

  Future<void> addCoordinate(TapDownDetails details, GlobalKey imageKey) async {
    setState(() => isLoading = false);
    List<Offset> screenCoordinates = [];

    if (_currentPageIndex == 0) {
      screenCoordinates = screen0Coordinates;
    } else if (_currentPageIndex == 1) {
      screenCoordinates = screen1Coordinates;
    } else if (_currentPageIndex == 2) {
      screenCoordinates = screen2Coordinates;
    } else if (_currentPageIndex == 3) {
      screenCoordinates = screen3Coordinates;
    } else if (_currentPageIndex == 4) {
      screenCoordinates = screen4Coordinates;
    } else if (_currentPageIndex == 5) {
      screenCoordinates = screen5Coordinates;
    } else if (_currentPageIndex == 6) {
      screenCoordinates = screen6Coordinates;
    }

    if (screenCoordinates.length < 2) {
      final RenderBox renderBox =
          imageKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localPosition =
          renderBox.globalToLocal(details.globalPosition);

      final double displayHeight = renderBox.size.height;
      final double displayWidth = renderBox.size.width;

      // Calculate scale factors
      final double scaleX = imageWidth / displayWidth;
      final double scaleY = imageHeight / displayHeight;

      // Convert screen coordinates to image coordinates
      final double imageX = localPosition.dx * scaleX;
      final double imageY = localPosition.dy * scaleY;

      final Offset imageCoordinates = Offset(imageX, imageY);
      screenCoordinates.add(imageCoordinates);

      if (localPosition.dx >= 0 &&
          localPosition.dx <= displayWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy <= displayHeight) {
        setState(() {
          if (_currentPageIndex == 0) {
            screen0Coordinates = screenCoordinates;
          } else if (_currentPageIndex == 1) {
            screen1Coordinates = screenCoordinates;
          } else if (_currentPageIndex == 2) {
            screen2Coordinates = screenCoordinates;
          } else if (_currentPageIndex == 3) {
            screen3Coordinates = screenCoordinates;
          } else if (_currentPageIndex == 4) {
            screen4Coordinates = screenCoordinates;
          } else if (_currentPageIndex == 5) {
            screen5Coordinates = screenCoordinates;
          } else if (_currentPageIndex == 6) {
            screen6Coordinates = screenCoordinates;
          }
        });
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> saveImageWithAllCoordinates() async {
    setState(() => isLoading = true);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final image =
        await decodeImageFromList(widget.selectedImage.readAsBytesSync());

    // Ensure localCoordinates has an even number of elements (pairs)
    if (localCoordinates.length % 2 != 0) {
      setState(() => isLoading = false);
      return; // Skip if pairs are incomplete
    }

    // Draw the image first
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw circles for each pair of coordinates
    for (int i = 0; i < localCoordinates.length; i += 2) {
      final paint = Paint()
        ..color = screenColors[i ~/ 2 % screenColors.length]
        ..style = PaintingStyle.fill
        ..strokeWidth = 5;

      canvas.drawCircle(localCoordinates[i]!, 10, paint);
      canvas.drawCircle(localCoordinates[i + 1]!, 10, paint);

      canvas.drawLine(localCoordinates[i]!, localCoordinates[i + 1]!, paint);
    }

    // Convert canvas to an image
    final img =
        await recorder.endRecording().toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Save the updated image
    final newImagePath =
        widget.selectedImage.path.replaceAll('.png', '_updated.png');
    File newImageFile = File(newImagePath);
    await newImageFile.writeAsBytes(buffer);
    setState(() {
      newImageLocal = newImageFile;
    });

    setState(() {
      isLoading = false;
    });
  }

  void _showHelpPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        if (_currentPageIndex < measures.length) {
          title = measures[_currentPageIndex];
        } else {
          title = 'Help';
        }
        return AlertDialog(
          title: Text(title),
          contentPadding: EdgeInsets.zero,
          content: _currentPageIndex < helpImages.length
              ? Image.asset(helpImages[_currentPageIndex])
              : const Text('No help image available for this page.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//----------------------------------------------------------------------------//
//                                                                            //
//                                  build()                                   //
//                                                                            //
//----------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    Widget screenCoordinatesPicker0 = _imageCoordinatesPicker0(screenColors[0]);
    Widget screenCoordinatesPicker1 = _imageCoordinatesPicker1(screenColors[1]);
    Widget screenCoordinatesPicker2 = _imageCoordinatesPicker2(screenColors[2]);
    Widget screenCoordinatesPicker3 = _imageCoordinatesPicker3(screenColors[3]);
    Widget screenCoordinatesPicker4 = _imageCoordinatesPicker4(screenColors[4]);
    Widget screenCoordinatesPicker5 = _imageCoordinatesPicker5(screenColors[5]);
    Widget screenCoordinatesPicker6 = _imageCoordinatesPicker6(screenColors[6]);
    Widget coordinatesScreen = _buildCoordinatesScreen();

    List<Widget> screens = [
      screenCoordinatesPicker0,
      screenCoordinatesPicker1,
      screenCoordinatesPicker2,
      screenCoordinatesPicker3,
      screenCoordinatesPicker4,
      screenCoordinatesPicker5,
      screenCoordinatesPicker6,
      coordinatesScreen,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, result);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: _currentPageIndex <= 6
            ? Text("Line ${_currentPageIndex + 1}/7")
            : Text("Result"),
        actions: [
          !allCoordinatesFilled() && _currentPageIndex < 7
              ? IconButton(
                  icon: const Icon(Icons.backspace),
                  onPressed: !isLoading ? _undoCoordinate : null,
                )
              : IconButton(
                  onPressed: !isLoading
                      ? () async {
                          setState(() => isLoading = true);
                          Map<String, dynamic> result = {
                            'selectedImage': newImageLocal,
                            'coordinates': localCoordinates,
                          };
                          Navigator.pop(context, result);
                        }
                      : null,
                  icon: const Icon(Icons.done_rounded),
                ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentPageIndex < 7)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            measures[_currentPageIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showHelpPopup(context);
                          },
                          icon: Icon(Icons.help),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _currentPageIndex,
                    children: screens,
                  ),
                ),
                if (_currentPageIndex < 7)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: !isLoading &&
                                  _currentPageIndex > 0 &&
                                  (pageCoordinatesSizeCheck() ||
                                      pageBackCoordinatesSizeCheck())
                              ? _goToPreviousPage
                              : null,
                          child: const Text('Previous'),
                        ),
                        ElevatedButton(
                          onPressed: !isLoading &&
                                  _currentPageIndex < screens.length - 1 &&
                                  pageCoordinatesSizeCheck()
                              ? _goToNextPage
                              : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

//----------------------------------------------------------------------------//
//                                                                            //
//                          imageCoordinatesPickers                           //
//                                                                            //
//----------------------------------------------------------------------------//

  Widget _imageCoordinatesPicker0(Color paintColor) {
    GlobalKey imageKey = GlobalKey();
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen0Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCoordinatesPicker1(Color paintColor) {
    GlobalKey imageKey = GlobalKey();
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen1Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
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
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen2Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
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
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen3Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
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
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen4Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
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
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen5Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
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
    return GestureDetector(
      onTapDown: (details) => addCoordinate(details, imageKey),
      child: Center(
        child: Stack(
          children: [
            Image.file(widget.selectedImage,
                key: imageKey, fit: BoxFit.contain),
            Positioned.fill(
              child: CustomPaint(
                painter: CoordinatesPainter(
                  paintColor,
                  coordinates: screen6Coordinates,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (newImageLocal != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior:
                  Clip.hardEdge, // Ensures the image respects border radius
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(newImageLocal!),
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            'Selected Coordinates:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: allCoordinatesFilled()
                ? ListView.builder(
                    itemCount: localCoordinates.length,
                    itemBuilder: (context, index) {
                      Offset coordinate = localCoordinates[index]!;
                      return ListTile(
                        title: Text(
                            'Coordinate ${index + 1}: (${coordinate.dx.toStringAsFixed(2)}, ${coordinate.dy.toStringAsFixed(2)})'),
                      );
                    },
                  )
                : const Center(child: Text('Not enough coordinates selected.')),
          ),
        ],
      ),
    );
  }
}
