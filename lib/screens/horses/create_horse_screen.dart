import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:equus/models/horse.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Ensure this is imported for JSON decoding

class CreateHorseScreen extends StatefulWidget {
  const CreateHorseScreen({super.key});

  @override
  State<CreateHorseScreen> createState() {
    return _CreateHorseScreenState();
  }
}

class _CreateHorseScreenState extends State<CreateHorseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _rightFrontPictureController = TextEditingController();
  final _leftFrontPictureController = TextEditingController();
  final _rightHindPictureController = TextEditingController();
  final _leftHindPictureController = TextEditingController();

  File? _profilePictureFile;

  void pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _profilePictureFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveHorse() async {
    if (_formKey.currentState!.validate()) {
      final horse = Horse(
        idHorse: 0,
        name: _nameController.text,
        birthDate: _birthDateController.text,
        profilePicturePath: null,
        pictureRightFrontPath: _rightFrontPictureController.text.isNotEmpty
            ? _rightFrontPictureController.text
            : null,
        pictureLeftFrontPath: _leftFrontPictureController.text.isNotEmpty
            ? _leftFrontPictureController.text
            : null,
        pictureRightHindPath: _rightHindPictureController.text.isNotEmpty
            ? _rightHindPictureController.text
            : null,
        pictureLeftHindPath: _leftHindPictureController.text.isNotEmpty
            ? _leftHindPictureController.text
            : null,
      );

      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:9090/horses'));

      request.fields['name'] = horse.name;
      request.fields['birthDate'] = horse.birthDate!;
      request.fields['pictureRightFrontPath'] =
          horse.pictureRightFrontPath ?? '';
      request.fields['pictureLeftFrontPath'] = horse.pictureLeftFrontPath ?? '';
      request.fields['pictureRightHindPath'] = horse.pictureRightHindPath ?? '';
      request.fields['pictureLeftHindPath'] = horse.pictureLeftHindPath ?? '';

      if (_profilePictureFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo', // This key should match your API expectation
            _profilePictureFile!.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horse created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create horse')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageButtonOrPlaceholder = Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera),
          label: const Text("Take Picture"),
        ),
        ElevatedButton.icon(
          onPressed: () => pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text("Choose from Gallery"),
        ),
      ],
    );

    if (_profilePictureFile != null) {
      imageButtonOrPlaceholder =
          Image.file(_profilePictureFile!, fit: BoxFit.cover);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Horse"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Horse Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the horse's name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: "Birth Date",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the birth date";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                child: imageButtonOrPlaceholder,
              ),
              TextFormField(
                controller: _profilePictureController,
                decoration: InputDecoration(
                  labelText: "Profile Picture URL (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _rightFrontPictureController,
                decoration: InputDecoration(
                  labelText: "Right Front Picture URL (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _leftFrontPictureController,
                decoration: InputDecoration(
                  labelText: "Left Front Picture URL (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _rightHindPictureController,
                decoration: InputDecoration(
                  labelText: "Right Hind Picture URL (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _leftHindPictureController,
                decoration: InputDecoration(
                  labelText: "Left Hind Picture URL (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveHorse,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Save Horse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
