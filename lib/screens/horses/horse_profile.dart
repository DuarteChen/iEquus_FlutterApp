import 'dart:io';
import 'package:equus/models/client.dart';
import 'package:equus/models/horse.dart';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/screens/appointment/create_appointment.dart';
import 'package:equus/screens/measure/create_measure_screen.dart';
import 'package:equus/screens/xray/xray_creation_screen.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:equus/widgets/profile_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HorseProfile extends StatefulWidget {
  const HorseProfile({super.key, required this.horse});

  final Horse horse;

  @override
  HorseProfileState createState() => HorseProfileState();
}

class HorseProfileState extends State<HorseProfile> {
  File? _profilePictureFile;
  late Future<void> _initializationFuture;
  bool _isUpdatingPhoto = false;

  @override
  void initState() {
    super.initState();

    _initializationFuture = _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      final horseProvider = Provider.of<HorseProvider>(context, listen: false);

      await Future.wait([
        horseProvider.loadHorseData(widget.horse.idHorse),
        horseProvider.loadHorseClients(widget.horse.idHorse),
      ]);
    } catch (e) {
      debugPrint("Error initializing Horse Profile: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading!')),
        );
        Navigator.pop(context);
      }
      rethrow;
    }
  }

  // Handles picking an image from the specified source
  Future<void> pickImage(ImageSource source) async {
    // Prevent picking a new image while an update is in progress
    if (_isUpdatingPhoto) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      _profilePictureFile = File(pickedImage.path);

      await _updateHorsePhoto();
    }
  }

  Future<void> _updateHorsePhoto() async {
    if (_profilePictureFile == null) return;

    setState(() {
      _isUpdatingPhoto = true;
    });

    final horseProvider = Provider.of<HorseProvider>(context, listen: false);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await horseProvider.updateHorsePhoto(
        widget.horse.idHorse,
        _profilePictureFile!,
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Horse photo updated successfully!'),
        ),
      );
    } catch (e) {
      debugPrint("Error in _updateHorsePhoto UI: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update horse photo'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // --- Loading State ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // --- Error State ---
        else if (snapshot.hasError) {
          return Scaffold(
            // Provide Scaffold on error
            body: Center(
              child: Padding(
                // Add padding for error message
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error initializing Horse Profile: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          );
        }
        // --- Success State ---
        else {
          final horseProvider = Provider.of<HorseProvider>(context);

          final currentHorse = horseProvider.currentHorse ?? widget.horse;

          return Scaffold(
            body: Scrollbar(
              interactive: true,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Stretch children horizontally
                  children: [
                    // Profile Image Section
                    ProfileImagePreview(
                      horse: widget.horse,
                      profileImageProvider: horseProvider.profileImageProvider,
                      onImageSourceSelected: pickImage,
                      //isLoading: _isUpdatingPhoto, // Pass loading state
                    ),
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
                    const SizedBox(height: 16),

                    // Horse Info Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0), // Horizontal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Owners Section ---
                          Text(
                            'Owners',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildClientList(
                            context,
                            horseProvider.horseOwners,
                            "Owner",
                            Icons.verified_user_outlined,
                          ),
                          const SizedBox(height: 16),

                          // --- Care Takers Section ---
                          Text(
                            'Care Takers',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildClientList(
                            context,
                            horseProvider.horseClients,
                            "Care Taker",
                            Icons.people_alt_outlined,
                          ),
                          const Divider(height: 32),

                          // --- Basic Info Section ---
                          Text(
                            'Basic Info',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                                child: Icon(
                                  Icons.cake_outlined,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              title: Text(
                                currentHorse.dateNameBirthDateToString() ??
                                    'Not specified',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: const Text("Birthday"),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- Action Button ---

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: MainButtonBlue(
                                  icon: Icon(Icons.stream),
                                  buttonText: "Measure",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateMeasureScreen(
                                                horse: widget.horse),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: MainButtonBlue(
                                  icon: Icon(Icons.medication_outlined),
                                  buttonText: "X-Ray",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            XRayCreation(horse: widget.horse),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: MainButtonBlue(
                                  iconImage:
                                      'assets/icons/appointment_new_black.png',
                                  buttonText: "Appointment",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateAppointment(
                                            horse: widget.horse),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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

  Widget _buildClientList(
      BuildContext context, List<Client> clients, String role, IconData icon) {
    if (clients.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.grey.shade600),
          ),
          title: Text('No ${role}s assigned'),
          dense: true,
        ),
      );
    }
    return Column(
      children: clients.map((client) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Icon(
                icon,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            title: Text(
              client.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(role),
            onTap: () {
              // TODO: Implement navigation to client profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Navigate to ${client.name}\'s profile (TODO)')),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
