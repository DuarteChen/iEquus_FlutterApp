import 'dart:typed_data';
import 'package:equus/models/horse.dart';
import 'package:equus/models/measure.dart';
import 'package:equus/screens/appointment/slider_image_coordinates_picker.dart';
import 'package:equus/widgets/bcs_gauge.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateMeasureScreen extends StatefulWidget {
  const CreateMeasureScreen(
      {super.key,
      required this.horse,
      this.appointmentID,
      this.veterinarianID});

  final Horse horse;
  final int? appointmentID;
  final int? veterinarianID;

  @override
  CreateMeasureScreenState createState() => CreateMeasureScreenState();
}

class CreateMeasureScreenState extends State<CreateMeasureScreen> {
  File? _selectedImage;
  final List<Offset> _coordinates = [];
  int? imageWidth;
  int? imageHeight;
  Measure? measure;

  ImageSource? imageSource;

  int? _userBW;
  int? algorithmBW;
  int? _userBCS;
  int? algorithmBCS;
  bool? favorite;
  int? veterinarianId;
  int? appointmentId;

  @override
  void initState() {
    super.initState();

    measure = Measure(
      id: 0,
      date: DateTime.now(),
      coordinates: [],
      horseId: widget.horse.idHorse,
      picturePath: '',
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: source,
    );
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    final image = await decodeImageFromList(_selectedImage!.readAsBytesSync());

    setState(() {
      imageWidth = image.width;
      imageHeight = image.height;
    });

    final Map<String, dynamic> result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SliderImageCoordinatesPicker(
          selectedImage: _selectedImage!,
        ),
      ),
    );

    if (result['selectedImage'] != null) {
      setState(() {
        _selectedImage = result['selectedImage'];
        _coordinates.addAll(result['coordinates'].whereType<Offset>());
      });
      await _createMeasure(_selectedImage!, _coordinates);
    } else {
      setState(() {
        _selectedImage =
            null; //result['selectedImage']; Para obrigar a que a imagem seja null
      });
    }
  }

  Future<void> _createMeasure(
      File picturePath, List<Offset> coordinates) async {
    measure!.picturePath = picturePath.path;
    measure!.coordinates = coordinates;

    if (await measure!.firstUploadToServer()) {
      setState(() {
        algorithmBCS = measure!.algorithmBCS;
        algorithmBW = measure!.algorithmBW;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Created successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create!')),
      );
    }
  }

  Future<void> _finalSave() async {
    if (await measure!.editBWandBCS(_userBW, _userBCS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save!')),
      );
    }

    Navigator.of(context).pop();
  }

  void popUpBWOrBCS(BuildContext context, String bwOrBcs) {
    final TextEditingController controller = TextEditingController();
    if (bwOrBcs == 'Body Weight') {
      controller.text = _userBW?.toString() ?? '';
    } else if (bwOrBcs == 'Body Condition Score') {
      controller.text = _userBCS?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        String title = 'Edit $bwOrBcs';
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: bwOrBcs,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? number = int.tryParse(controller.text);

                if (number != null) {
                  if (bwOrBcs == 'Body Weight') {
                    setState(() {
                      _userBW = number;
                    });
                  } else if (bwOrBcs == 'Body Condition Score') {
                    if (number < 1 || number > 5) {
                      setState(() {
                        title = 'Invalid input! Must be between 1 and 5.';
                      });
                      return; // Stop execution to prevent closing the dialog
                    }
                    setState(() {
                      _userBCS = number;
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid input!')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void popUpBCS(
      BuildContext context, Function(int) onBCSSelected, int initialBCS) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedBCS =
            initialBCS == 0 ? 1 : initialBCS; // Use the initial value properly

        return StatefulBuilder(
          // Allows state changes inside the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Body Condition Score'),
              content: Wrap(
                spacing: 8.0, // Horizontal spacing
                runSpacing: 8.0, // Vertical spacing when wrapping
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  int value = index + 1;
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedBCS = value; // Update selected value
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove internal padding
                        minimumSize: const Size(40, 40), // Ensure size is set
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(4), // Square shape
                        ),
                        side: BorderSide(
                          color: selectedBCS == value
                              ? Theme.of(context).primaryColor
                              : Colors.grey, // Border color
                        ),
                        backgroundColor: selectedBCS == value
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors
                                .transparent, // Light background for selection
                      ),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 16, // Adjust text size
                          color: selectedBCS == value
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onBCSSelected(selectedBCS);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  imageSource = ImageSource.gallery;
                  _pickImage(imageSource!);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  imageSource = ImageSource.camera;
                  _pickImage(imageSource!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bcsTile(int bcsValue) {
      return Expanded(
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BCS",
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: () => popUpBCS(
                        context,
                        (newBCS) {
                          setState(() {
                            _userBCS = newBCS;
                            bcsValue = newBCS;
                          });
                        },
                        bcsValue,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: CustomPaint(
                    size: Size(110, 80),
                    painter: GaugePainter(bcsValue.toDouble()),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    Widget bwTile(int weight) {
      return Expanded(
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "kg",
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: () => popUpBWOrBCS(context, "Body Weight"),
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    weight.toString(),
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    Widget? cameraButton = ElevatedButton.icon(
      onPressed: () {
        _showImageSourceDialog(context);
      },
      icon: Icon(Icons.stream),
      label: Text("Take Picture"),
    );

    Widget? imageContent;
    if (_selectedImage != null) {
      imageContent = SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<Uint8List>(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      imageContent = Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/horseAppointmentPlaceHolder.png',
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: cameraButton,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            measure!.deleteMeasure();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(widget.horse.name),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _userBCS != null ||
                    _userBW != null ||
                    (measure!.algorithmBCS != null &&
                        measure!.algorithmBW != null)
                ? () {
                    _finalSave();
                    Navigator.of(context).pop();
                  }
                : null,
            icon: Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageContent,
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _userBW != null
                      ? bwTile(_userBW!)
                      : measure == null || algorithmBW == null
                          ? bwTile(0)
                          : bwTile(algorithmBW!),
                  SizedBox(
                    width: 16,
                  ),
                  _userBCS != null
                      ? bcsTile(_userBCS!)
                      : measure == null || algorithmBCS == null
                          ? bcsTile(0)
                          : bcsTile(algorithmBCS!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
