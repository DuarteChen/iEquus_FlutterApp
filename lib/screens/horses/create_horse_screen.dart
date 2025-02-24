import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:equus/widgets/profile_image_preview.dart';
import 'package:equus/widgets/small_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  //Profile Picture
  File? _profilePictureFile;
  //Castanha do cavalo
  File? _pictureRightFrontFile;
  File? _pictureLeftFrontFile;
  File? _pictureRightHindFile;
  File? _pictureLeftHindFile;

  //esta função recebe uma função que atualiza que corre dentro desta função ;)
  Future<void> pickImage(Function(File) updateImage) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        updateImage(File(pickedImage.path));
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
      //Cria um objeto da classe Horse
      final horse = Horse(
        idHorse:
            0, //só para criar o objeto, porque o id vai sempre vir da base dade dados
        name: _nameController.text,
        birthDate: _selectedDate,
      );
      //Define o tipo de request para a variável
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:9090/horses'));

      request.fields['name'] = horse.name;
      if (horse.birthDate != null) {
        request.fields['birthDate'] =
            '${horse.birthDate!.year}-${horse.birthDate!.month.toString().padLeft(2, '0')}-${horse.birthDate!.day.toString().padLeft(2, '0')}';
      }
      //Profile Pic
      if (_profilePictureFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _profilePictureFile!.path,
          ),
        );
      }
      //Hinds Pics
      if (_pictureLeftFrontFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pictureLeftFront',
            _pictureLeftFrontFile!.path,
          ),
        );
      }

      if (_pictureRightFrontFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pictureRightFront',
            _pictureRightFrontFile!.path,
          ),
        );
      }

      if (_pictureLeftHindFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pictureLeftHind',
            _pictureLeftHindFile!.path,
          ),
        );
      }

      if (_pictureRightHindFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pictureRightHind',
            _pictureRightHindFile!.path,
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
    return Scaffold(
      body: Column(
        children: [
          // Profile Image
          ProfileImagePreview(
            profileImageFile: _profilePictureFile,
            onEditPressed: () => pickImage((newImage) {
              setState(() {
                _profilePictureFile = newImage;
              });
            }),
          ),
          // Title Bar
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[800],
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
                            angle: -90 *
                                3.14159 /
                                180, // Convert 90 degrees to radians
                            child: Text('Front'),
                          ),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageFile: _pictureLeftFrontFile,
                              onEditPressed: () => pickImage((newImage) {
                                setState(() {
                                  _pictureLeftFrontFile = newImage;
                                });
                              }),
                              emptyLegImage:
                                  'assets/images/front_left_leg_image.png',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageFile: _pictureRightFrontFile,
                              onEditPressed: () => pickImage((newImage) {
                                setState(() {
                                  _pictureRightFrontFile = newImage;
                                });
                              }),
                              emptyLegImage:
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
                            child: Text('Hind'),
                          ),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageFile: _pictureLeftHindFile,
                              onEditPressed: () => pickImage((newImage) {
                                setState(() {
                                  _pictureLeftHindFile = newImage;
                                });
                              }),
                              emptyLegImage:
                                  'assets/images/hind_left_leg_image.png',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SmallImagePreview(
                              profileImageFile: _pictureRightHindFile,
                              onEditPressed: () => pickImage((newImage) {
                                setState(() {
                                  _pictureRightHindFile = newImage;
                                });
                              }),
                              emptyLegImage:
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
