import 'dart:typed_data';
import 'package:equus/models/horse.dart';
import 'package:equus/screens/appointment/slider_image_coordinates_picker.dart';
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SliderImageCoordinatesPicker(
          coordinates: _coordinates,
          selectedImage: _selectedImage,
        ),
      ),
    );

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    // final image = await decodeImageFromList(_selectedImage!.readAsBytesSync());
    //
    // setState(() {
    //   imageWidth = image.width;
    //   imageHeight = image.height;
    // });
    //
    // // Rosa escuro (coordenadas 0 e 1)
    // final colorCoordinatesRosaEscuro = Colors.purple[800]!;
    //
    // final coordinatesRosaEscuro = await Navigator.push<List<Offset>>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ImageCoordinatesPicker(
    //       image: _selectedImage!,
    //       imageWidth: imageWidth!,
    //       imageHeight: imageHeight!,
    //       coordinates: List.of(_coordinates), // Passa uma cópia atual
    //       color: colorCoordinatesRosaEscuro,
    //     ),
    //   ),
    // );
    //
    // if (coordinatesRosaEscuro != null) {
    //   setState(() {
    //     _coordinates.addAll(coordinatesRosaEscuro);
    //   });
    // }
    //
    // // Rosa claro (coordenadas 2 e 3)
    // final colorCoordinatesRosaClaro = Colors.purple[300]!;
    //
    // final coordinatesRosaClaro = await Navigator.push<List<Offset>>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ImageCoordinatesPicker(
    //       image: _selectedImage!,
    //       imageWidth: imageWidth!,
    //       imageHeight: imageHeight!,
    //       coordinates: List.of(_coordinates), // Inclui as coordenadas já adicionadas
    //       color: colorCoordinatesRosaClaro,
    //     ),
    //   ),
    // );
    //
    // if (coordinatesRosaClaro != null) {
    //   setState(() {
    //     _coordinates.addAll(coordinatesRosaClaro);
    //   });
    // }
    //
    // // Atualiza a imagem final com todas as coordenadas
    // setState(() {
    //   _selectedImage = File(_selectedImage!.path); // Recarregar imagem final
    // });
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
