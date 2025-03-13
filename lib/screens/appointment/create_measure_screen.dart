import 'dart:typed_data';
import 'package:equus/models/horse.dart';
import 'package:equus/screens/appointment/slider_image_coordinates_picker_deprecated.dart';
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

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
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
        builder: (context) => SliderImageCoordinatesPickerDeprecated(
          coordinates: _coordinates,
          selectedImage: _selectedImage,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
      ),
    );

    setState(() {
      _selectedImage = result['selectedImage'];
      _coordinates.addAll(result['coordinates']);

      print(_coordinates);
      print(_selectedImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget imageContent = ElevatedButton.icon(
      onPressed: _pickImage,
      icon: Icon(Icons.stream),
      label: Text("Take Picture"),
    );

    if (_selectedImage != null) {
      imageContent = FutureBuilder<Uint8List>(
        future: _selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          } else {
            return CircularProgressIndicator();
          }
        },
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
        title: Text("New Measure"),
        centerTitle: true,
      ),
      body: Column(children: [
        imageContent,
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.stream),
          label: Text("Slider Screen"),
        ),
      ]),
    );
  }
}
