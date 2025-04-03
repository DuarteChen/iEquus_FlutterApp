import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/screens/appointment/create_appointment.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:equus/widgets/profile_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HorseProfile extends StatefulWidget {
  const HorseProfile({super.key, required this.horse});

  final Horse horse;

  @override
  HorseProfileState createState() => HorseProfileState();
}

class HorseProfileState extends State<HorseProfile> {
  File? _profilePictureFile;

  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    final horseProvider = Provider.of<HorseProvider>(context, listen: false);
    await horseProvider.loadHorseData(widget.horse.idHorse);
    await horseProvider.loadHorseClients(widget.horse.idHorse);
  }

  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      _profilePictureFile = imageFile;
      await _updateHorsePhoto();
    }
  }

  Future<void> _updateHorsePhoto() async {
    final horseProvider = Provider.of<HorseProvider>(context, listen: false);
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
        horseProvider.updateHorsePhoto(horse.idHorse, _profilePictureFile!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update horse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child:
                  Text('Error initializing Horse Profile: ${snapshot.error}'),
            ),
          );
        } else {
          final horseProvider = Provider.of<HorseProvider>(context);

          return Scaffold(
            body: Scrollbar(
              interactive: true,
              thumbVisibility: true,
              thickness: 6,
              radius: Radius.circular(8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileImagePreview(
                      profileImageProvider: horseProvider.profileImageProvider,
                      onImageSourceSelected: (source) => pickImage(source),
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
                          widget.horse.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                    //Horse Info ----------
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owners',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: horseProvider.horseOwners.map((client) {
                              return ListTile(
                                subtitle: Text("Owner"),
                                leading: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromARGB(
                                          255, 226, 226, 226)),
                                  padding: EdgeInsets.all(7),
                                  child: ClipOval(
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  client.name,
                                  style: TextStyle(fontSize: 17),
                                ),
                                onTap: () {
                                  // TODO - Fazer ecrã de clientes
                                },
                              );
                            }).toList(),
                          ),
                          Column(
                            children: horseProvider.horseClients.map((client) {
                              return ListTile(
                                subtitle: Text("Care taker"),
                                leading: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromARGB(
                                          255, 226, 226, 226)),
                                  padding: EdgeInsets.all(7),
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                title: Text(
                                  client.name,
                                  style: TextStyle(fontSize: 17),
                                ),
                                onTap: () {
                                  // TODO - Fazer ecrã de clientes
                                },
                              );
                            }).toList(),
                          ),
                          Divider(
                            color: Theme.of(context).primaryColor,
                            thickness: 0.5,
                            height: 32,
                          ),
                          Text(
                            'Basic info',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: [
                              ListTile(
                                subtitle: Text("Birthday"),
                                leading: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromARGB(
                                          255, 226, 226, 226)),
                                  padding: EdgeInsets.all(7),
                                  child: Icon(
                                    Icons.cake,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                title: Text(
                                  "${widget.horse.dateName_birthDateToString()}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                onTap: () {},
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: MainButtonBlue(
                              buttonText: 'New Appointment',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAppointment(
                                      horse: widget.horse,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
