import 'dart:io';
import 'package:equus/models/client.dart';
import 'package:equus/models/horse.dart';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/screens/appointment/horse_selector.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:equus/widgets/profile_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// Removed 'package:http/http.dart' as http; - No longer needed here

class HorseProfile extends StatefulWidget {
  const HorseProfile({super.key, required this.horse});

  final Horse horse;

  @override
  HorseProfileState createState() => HorseProfileState();
}

class HorseProfileState extends State<HorseProfile> {
  File? _profilePictureFile;
  late Future<void> _initializationFuture;
  bool _isUpdatingPhoto = false; // Add state for loading indicator

  @override
  void initState() {
    super.initState();
    // Fetch initial data when the screen loads
    _initializationFuture = _initializeScreen();
  }

  // Fetches initial data needed for the profile screen
  Future<void> _initializeScreen() async {
    // Use try-catch for better error handling during initialization
    try {
      final horseProvider = Provider.of<HorseProvider>(context, listen: false);
      // Fetch horse data and clients concurrently for potentially faster loading
      await Future.wait([
        horseProvider.loadHorseData(widget.horse.idHorse),
        horseProvider.loadHorseClients(widget.horse.idHorse),
      ]);
    } catch (e) {
      // Log the error and rethrow to show in FutureBuilder
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
      // Store the picked file locally
      _profilePictureFile = File(pickedImage.path);
      // Trigger the update process
      await _updateHorsePhoto();
    }
  }

  // Calls the provider to update the horse's photo
  Future<void> _updateHorsePhoto() async {
    // Ensure a file has been picked
    if (_profilePictureFile == null) return;

    // Set loading state to true and rebuild UI
    setState(() {
      _isUpdatingPhoto = true;
    });

    final horseProvider = Provider.of<HorseProvider>(context, listen: false);
    // Cache ScaffoldMessenger before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Call the provider method which handles the service call and JWT
      await horseProvider.updateHorsePhoto(
        widget.horse.idHorse,
        _profilePictureFile!,
      );

      // Show success message
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Horse photo updated successfully!'),
        ),
      );
      // Provider's notifyListeners will handle UI update for the image itself
    } catch (e) {
      // Show error message if update fails
      debugPrint("Error in _updateHorsePhoto UI: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update horse photo'),
          backgroundColor:
              Theme.of(context).colorScheme.error, // Indicate error
        ),
      );
    } finally {
      // Reset loading state regardless of success or failure
      // Check if mounted before calling setState after async gap
      if (mounted) {
        setState(() {
          _isUpdatingPhoto = false;
          // Optionally clear the file reference if needed
          // _profilePictureFile = null;
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
          // Listen to provider changes for UI updates
          final horseProvider = Provider.of<HorseProvider>(context);
          // Use the potentially updated horse data from the provider, fallback to initial widget data
          final currentHorse = horseProvider.currentHorse ?? widget.horse;

          return Scaffold(
            body: Scrollbar(
              // Add scrollbar for long content
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
                      profileImageProvider: horseProvider.profileImageProvider,
                      onImageSourceSelected:
                          pickImage, // Pass the pickImage method directly
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
                    const SizedBox(height: 16), // Spacing after image

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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge, // Use theme style
                          ),
                          const SizedBox(height: 8),
                          _buildClientList(
                            context,
                            horseProvider.horseOwners,
                            "Owner",
                            Icons.verified_user_outlined, // Example icon
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
                            Icons.people_alt_outlined, // Example icon
                          ),
                          const Divider(height: 32), // Visual separator

                          // --- Basic Info Section ---
                          Text(
                            'Basic Info',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            // Wrap info in a Card
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                // Use CircleAvatar for consistency
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                                child: Icon(
                                  Icons.cake_outlined, // Outline icon
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              title: Text(
                                currentHorse.dateName_birthDateToString() ??
                                    'Not specified',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: const Text("Birthday"),
                            ),
                          ),
                          const SizedBox(height: 24), // Spacing before button

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
                                        builder: (context) => HorseSelector(
                                            selectorType: 'measure'),
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
                                        builder: (context) => HorseSelector(
                                            selectorType: 'x-ray'),
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
                                        builder: (context) => HorseSelector(
                                            selectorType: 'appointment'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Padding at the bottom
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

  // Helper widget to build the list of clients (owners or caretakers)
  Widget _buildClientList(
      BuildContext context, List<Client> clients, String role, IconData icon) {
    if (clients.isEmpty) {
      return Card(
        // Show card even when empty for consistency
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.grey.shade600),
          ),
          title: Text('No ${role}s assigned'),
          dense: true, // Make it slightly smaller
        ),
      );
    }
    return Column(
      children: clients.map((client) {
        return Card(
          // Wrap each client in a Card
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              // Use CircleAvatar
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Icon(
                icon,
                color: Theme.of(context)
                    .primaryColorDark, // Use darker shade for contrast
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
