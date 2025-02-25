import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:equus/models/horse.dart'; // Assuming this is your Horse model
import 'package:equus/widgets/profile_image_preview.dart'; // Assuming this is where ProfileImagePreview is
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HorseProfile extends StatefulWidget {
  const HorseProfile({super.key, required this.horse});

  final Horse horse;

  @override
  HorseProfileState createState() => HorseProfileState();
}

class HorseProfileState extends State<HorseProfile> {
  File? _profilePictureFile;
  ImageProvider<Object>? _profileImageProvider;

  @override
  void initState() {
    super.initState();
    _loadImageProvider();
  }

  void _loadImageProvider() {
    if (widget.horse.profilePicturePath != null &&
        widget.horse.profilePicturePath!.isNotEmpty) {
      _profileImageProvider = NetworkImage(widget.horse.profilePicturePath!);
    }
  }

  // This function receives a function that updates the image, and runs inside this function ;)
  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      _profilePictureFile = imageFile;

      await _updateHorsePhoto();
    }
  }

  Future<void> _updateHorsePhoto() async {
    Horse horse = widget.horse;

    var request = http.MultipartRequest(
        'PUT', Uri.parse('http://10.0.2.2:9090/horses/${horse.idHorse}'));

    if (_profilePictureFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _profilePictureFile!.path,
        ),
      );
    }
    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horse updated successfully!')),
      );

      setState(() {
        _profileImageProvider = FileImage(_profilePictureFile!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update horse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String horseName = widget.horse.name;

    return Scaffold(
      body: Column(
        children: [
          ProfileImagePreview(
            profileImageProvider: _profileImageProvider,
            onEditPressed: () => pickImage(),
          ),
          // Title Bar ------------------------------------------
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                horseName,
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Horse ID: ${widget.horse.idHorse}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
