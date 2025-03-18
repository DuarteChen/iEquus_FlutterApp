import 'dart:convert';
import 'dart:typed_data';
import 'package:equus/models/horse.dart';
import 'package:equus/models/measure.dart';
import 'package:equus/screens/appointment/slider_image_coordinates_picker.dart';
import 'package:equus/widgets/bcs_gauge.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final List<Offset> _coordinates = [];
  int? imageWidth;
  int? imageHeight;
  Measure? measure;

  ImageSource? imageSource;

  int? userBW;
  int? algorithmBW;
  int? userBCS;
  int? algorithmBCS;
  bool? favorite;
  int? veterinarianId;
  int? appointmentId;

  @override
  void initState() {
    super.initState();
    //Future.delayed(Duration.zero, _pickImage);
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
        _selectedImage = result['selectedImage'];
      });
    }
  }

  Future<void> _createMeasure(
      File picturePath, List<Offset> coordinates) async {
    measure = Measure(
      id: 0,
      date: DateTime.now(),
      coordinates: coordinates,
      horseId: widget.horse.idHorse,
    );

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:9090/measures'),
    );
    request.fields['date'] = measure!.date.toString();
    request.fields['coordinates'] =
        measure!.convertOffsetsToJson(measure!.coordinates);
    request.fields['horseId'] = measure!.horseId.toString();
    request.files.add(
      await http.MultipartFile.fromPath(
        'picturePath',
        picturePath.path,
      ),
    );
    var response = await request.send();
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Created successfully!')),
      );
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      setState(() {
        measure!.id = (jsonResponse['measureID'] as int?) ?? 0;
        measure!.algorithmBCS = (jsonResponse['algorithmBCS'] as int?) ?? 0;
        measure!.algorithmBW = (jsonResponse['algorithmBW'] as int?) ?? 0;

        algorithmBCS = measure!.algorithmBCS;
        algorithmBW = measure!.algorithmBW;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create!')),
      );
    }
  }

  Future<void> _saveMeasure() async {}

  void popUpBWOrBCS(BuildContext context, String bwOrBcs) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String title = 'Edit $bwOrBcs value';

            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: _controller,
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
                    int? number = int.tryParse(_controller.text);

                    if (number != null && bwOrBcs == 'Body Weight') {
                      setState(() {
                        userBW = number;
                      });
                    } else if (bwOrBcs == 'Body Condition Score') {
                      if (number == null || number < 1 || number > 5) {
                        setState(() {
                          title = 'Value must be between 1 and 5!';
                        });
                        return; // Stop execution to prevent closing the dialog
                      }

                      setState(() {
                        userBCS = number;
                      });
                    }

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

  @override
  Widget build(BuildContext context) {
    Widget bwTile(int weight) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${weight.toString()} Kg",
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Text("Weight", style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => popUpBWOrBCS(context, "Body Weight"),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
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
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(widget.horse.name),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _saveMeasure();
            },
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: userBW != null
                        ? bwTile(userBW!)
                        : measure == null || algorithmBW == null
                            ? bwTile(0)
                            : bwTile(algorithmBW!),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: measure == null || algorithmBCS == null
                                  ? BCSGauge(bcsValue: 0)
                                  : BCSGauge(bcsValue: algorithmBCS!),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
}
