import 'dart:convert';
import 'dart:io';
import 'package:equus/models/client.dart';
import 'package:equus/widgets/main_button_blue.dart';
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
  List<Client> _horseClients = [];
  List<Client> _horseOwners = [];

  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _loadImageProvider();
    await _fetchHorseClients();
  }

  void _loadImageProvider() {
    if (widget.horse.profilePicturePath != null &&
        widget.horse.profilePicturePath!.isNotEmpty) {
      _profileImageProvider = NetworkImage(widget.horse.profilePicturePath!);
    }
  }

  // Fetch clients from the server - Modified to return Future<void>
  Future<void> _fetchHorseClients() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:9090/horse/${widget.horse.idHorse}/clients'));

    if (response.statusCode == 200) {
      final List<dynamic> clientsJson = json.decode(response.body);
      setState(() {
        _horseClients = clientsJson
            .map((json) => Client.fromJson(json))
            .toList()
            .cast<Client>();

        for (var client in List.from(_horseClients)) {
          if (client.isOwner) {
            _horseOwners.add(client);
            _horseClients.remove(client);
          }
        }
      });
    } else {
      setState(() {
        _horseClients = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load clients for this horse.')),
      );
    }
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
    return FutureBuilder<void>(
      future: _initializationFuture, // Use the combined initialization Future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator for the entire screen
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Show error screen for the entire screen if initialization fails
          return Scaffold(
            body: Center(
              child:
                  Text('Error initializing Horse Profile: ${snapshot.error}'),
            ),
          );
        } else {
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
                      profileImageProvider: _profileImageProvider,
                      onImageSourceSelected: (source) =>
                          pickImage(source), // Pass pickImage
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
                            // Use Column instead of Wrap for ListTiles
                            children: _horseOwners.map((client) {
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
                                  // Add onTap functionality if needed for owners
                                },
                              );
                            }).toList(),
                          ),
                          Column(
                            children: _horseClients.map((client) {
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
                                onTap: () {},
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
                              SizedBox(
                                width: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.black)),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.black)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                      ),
                                    ),
                                  )
                                ],
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
                              onTap: () {},
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
