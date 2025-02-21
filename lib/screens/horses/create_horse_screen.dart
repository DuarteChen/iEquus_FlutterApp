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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileImagePreview(
              profileImageFile: _profilePictureFile,
              onEditPressed: () => pickImage((newImage) {
                _profilePictureFile = newImage;
              }),
            ),
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
            // Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
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
                    // Date Picker
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
                    // Castanhas Images

                    Row(
                      children: [
                        SmallImagePreview(
                          profileImageFile: _pictureLeftFrontFile,
                          onEditPressed: () => pickImage((newImage) {
                            _pictureLeftFrontFile = newImage;
                          }),
                        ),
                        const SizedBox(width: 16),
                        SmallImagePreview(
                          profileImageFile: _pictureRightFrontFile,
                          onEditPressed: () => pickImage((newImage) {
                            _pictureRightFrontFile = newImage;
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SmallImagePreview(
                          profileImageFile: _pictureLeftHindFile,
                          onEditPressed: () => pickImage((newImage) {
                            _pictureLeftHindFile = newImage;
                          }),
                        ),
                        const SizedBox(width: 16),
                        SmallImagePreview(
                          profileImageFile: _pictureRightHindFile,
                          onEditPressed: () => pickImage((newImage) {
                            _pictureRightHindFile = newImage;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Optional space before the button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
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

/*import 'dart:io';
import 'package:equus/widgets/camera_or_gallery_buttons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:equus/models/horse.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _profilePictureFile;
  File? _pictureRightFrontFile;
  File? _pictureLeftFrontFile;
  File? _pictureRightHindFile;
  File? _pictureLeftHindFile;

  void pickImage(ImageSource source, String picType) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      if (picType == 'profile') {
        setState(() {
          _profilePictureFile = File(pickedImage.path);
        });
      } else if (picType == 'pictureRightFront') {
        setState(() {
          _pictureRightFrontFile = File(pickedImage.path);
        });
      }
    }
  }

  Future<void> _saveHorse() async {
    if (_formKey.currentState!.validate()) {
      //Cria um objeto da classe Horse
      final horse = Horse(
        idHorse:
            0, //só para criar o objeto, porque o id vai sempre vir da base dade dados
        name: _nameController.text,
        birthDate: _birthDateController.text,
      );
      //Define o tipo de request para a variável
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:9090/horses'));

      request.fields['name'] = horse.name;
      request.fields['birthDate'] = horse.birthDate!;

      if (_profilePictureFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo', // This key should match your API expectation
            _profilePictureFile!.path,
          ),
        );
      }

      if (_pictureRightFrontFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pictureRightFrontPath',
            _pictureRightFrontFile!.path,
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
    ImageSource pictureSource = ImageSource.camera;
    String pictureType = "profile";

    Widget profilepictureButtonorplaceholder = CameraOrGalleryButtons(
      picType: pictureType,
      setImageToVariable: pickImage,
      source: pictureSource,
    );

    if (_profilePictureFile != null) {
      profilepictureButtonorplaceholder =
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

              //Profile Picture
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text("Profile Picture"),
                    profilepictureButtonorplaceholder,
                  ],
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
*/
