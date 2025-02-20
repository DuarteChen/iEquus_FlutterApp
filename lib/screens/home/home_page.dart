import 'dart:io';
import 'package:equus/screens/horses/create_horse_screen.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../appointment/image_coordinates_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  List<Offset> _coordinates = [];
  var imageWidth;
  var imageHeight;

  void _takePicture() async {
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

    final coordinates = await Navigator.push<List<Offset>>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCoordinatesPicker(
          image: _selectedImage!,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
      ),
    );

    // Update coordinates if not null
    if (coordinates != null) {
      setState(() {
        _coordinates = coordinates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                    child: Text(
                      "Medical Services",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  MainButtonBlue(
                      iconImage: 'assets/icons/horse_new_black.png',
                      buttonText: "New Horse",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateHorseScreen()),
                        );
                      }),
                  SizedBox(height: 8),
                  MainButtonBlue(
                      iconImage: 'assets/icons/appointment_new_black.png',
                      buttonText: "New Appointment",
                      onTap: () {}),
                  SizedBox(height: 8),
                  MainButtonBlue(
                      iconImage: 'assets/icons/client_new_black.png',
                      buttonText: "New Client",
                      onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

/* Take picture button
   Widget content = TextButton.icon(
      onPressed: _takePicture,
      icon: const Icon(Icons.camera),
      label: const Text("Take Picture"),
    );

    if (_selectedImage != null) {
      content = Image.file(_selectedImage!, fit: BoxFit.cover);
    }

    return Center(
      child: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            alignment: Alignment.center,
            child: content,
          ),
          Text("Width: $imageWidth; Height: $imageHeight "),
          const SizedBox(height: 16),
          const Text(
            "Selected Coordinates:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _coordinates.length,
              itemBuilder: (context, index) {
                final coord = _coordinates[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                      "Point ${index + 1}: (x: ${coord.dx.toStringAsFixed(1)}, y: ${coord.dy.toStringAsFixed(1)})"),
                );
              },
            ),
          ),
        ],
      ),
    ); */
}
