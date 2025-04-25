import 'dart:io';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:equus/widgets/profile_image_preview.dart';
import 'package:equus/widgets/small_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateHorseScreen extends StatefulWidget {
  const CreateHorseScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CreateHorseScreenState();
  }
}

class _CreateHorseScreenState extends State<CreateHorseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;

  // ImageProviders for previews
  ImageProvider<Object>? _profileImageProvider;
  ImageProvider<Object>? _pictureRightFrontProvider;
  ImageProvider<Object>? _pictureLeftFrontProvider;
  ImageProvider<Object>? _pictureRightHindProvider;
  ImageProvider<Object>? _pictureLeftHindProvider;

  File? _profilePictureFile;
  File? _pictureRightFrontFile;
  File? _pictureLeftFrontFile;
  File? _pictureRightHindFile;
  File? _pictureLeftHindFile;

  Future<void> pickImage(
      Function(File, ImageProvider<Object>) updateImageProvider,
      ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      ImageProvider<Object> imageProvider = FileImage(imageFile);
      setState(() {
        updateImageProvider(imageFile, imageProvider);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveHorse() async {
    if (_formKey.currentState!.validate()) {
      final horseProvider = Provider.of<HorseProvider>(context, listen: false);

      try {
        await horseProvider.addHorse(
          _nameController.text,
          _selectedDate,
          _profilePictureFile,
          _pictureLeftFrontFile,
          _pictureRightFrontFile,
          _pictureLeftHindFile,
          _pictureRightHindFile,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horse created successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create horse!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Profile Image
          ProfileImagePreview(
            profileImageProvider: _profileImageProvider,
            onImageSourceSelected: (source) =>
                pickImage((updatedFile, updatedProvider) {
              setState(() {
                _profilePictureFile = updatedFile;
                _profileImageProvider = updatedProvider;
              });
            }, source),
          ),

          // Title Bar
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
            child: const Center(
              child: Text(
                'Create a new Horse',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          // Main content takes the remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Horse Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the horse's name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: const Text(
                        'Horse leg identification',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Image rows
                    Expanded(
                      child: Row(
                        children: [
                          Transform.rotate(
                            angle: -90 * 3.14159 / 180,
                            child: const Text('Front'),
                          ),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageProvider:
                                  _pictureLeftFrontProvider, // Use ImageProvider
                              onImageSourceSelected: (source) =>
                                  pickImage((updatedFile, updatedProvider) {
                                // Update pickImage to receive ImageProvider
                                setState(() {
                                  _pictureLeftFrontFile = updatedFile;
                                  _pictureLeftFrontProvider = updatedProvider;
                                });
                              }, source),
                              emptyImage:
                                  'assets/images/front_left_leg_image.png',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageProvider:
                                  _pictureRightFrontProvider, // Use ImageProvider
                              onImageSourceSelected: (source) =>
                                  pickImage((updatedFile, updatedProvider) {
                                // Update pickImage to receive ImageProvider
                                setState(() {
                                  _pictureRightFrontFile = updatedFile;
                                  _pictureRightFrontProvider = updatedProvider;
                                });
                              }, source),
                              emptyImage:
                                  'assets/images/front_right_leg_image.png',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Transform.rotate(
                            angle: -90 * 3.14159 / 180,
                            child: const Text('Hind'),
                          ),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageProvider:
                                  _pictureLeftHindProvider, // Use ImageProvider
                              onImageSourceSelected: (source) =>
                                  pickImage((updatedFile, updatedProvider) {
                                // Update pickImage to receive ImageProvider
                                setState(() {
                                  _pictureLeftHindFile = updatedFile;
                                  _pictureLeftHindProvider = updatedProvider;
                                });
                              }, source),
                              emptyImage:
                                  'assets/images/hind_left_leg_image.png',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageProvider:
                                  _pictureRightHindProvider, // Use ImageProvider
                              onImageSourceSelected: (source) =>
                                  pickImage((updatedFile, updatedProvider) {
                                // Update pickImage to receive ImageProvider
                                setState(() {
                                  _pictureRightHindFile = updatedFile;
                                  _pictureRightHindProvider = updatedProvider;
                                });
                              }, source),
                              emptyImage:
                                  'assets/images/hind_right_leg_image.png',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: MainButtonBlue(
            buttonText: 'Save',
            onTap: _saveHorse,
          ),
        ),
      ),
    );
  }
}
