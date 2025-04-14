import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class XRayCreation extends StatefulWidget {
  final Horse horse;
  const XRayCreation({super.key, required this.horse});

  @override
  State<XRayCreation> createState() => _XRayCreationState();
}

class _XRayCreationState extends State<XRayCreation> {
  File? _xrayImage;
  // Removed _xRayImage as _selectedImage seems sufficient
  // Removed imageSource as it's only used locally in the dialog callbacks

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    // Consider adding image quality options if needed
    final pickedImage = await imagePicker.pickImage(
      source: source,
      // imageQuality: 80, // Example quality setting
    );
    if (pickedImage == null) {
      return; // User cancelled picker
    }

    // Update the state with the selected image file
    setState(() {
      _xrayImage = File(pickedImage.path);
    });
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        // Use a different context name
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(modalContext); // Close the sheet FIRST
                  _pickImage(ImageSource.gallery); // THEN pick the image
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(modalContext); // Close the sheet FIRST
                  _pickImage(ImageSource.camera); // THEN pick the image
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("X-Ray for ${widget.horse.name}"), // Show horse name
      ),
      body: Center(
        // Center the content
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch horizontally
            children: [
              // Display the selected image or a placeholder
              Expanded(
                // Allow image container to expand
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade100, // Light background
                  ),
                  alignment:
                      Alignment.center, // Center content within container
                  child: _xrayImage != null
                      ? Image.file(
                          _xrayImage!,
                          fit: BoxFit.contain, // Show the whole image
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Error loading image',
                                style: TextStyle(color: Colors.red));
                          },
                        )
                      : const Column(
                          // Placeholder when no image selected
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No X-Ray image selected'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20), // Spacing

              // Button to trigger the image source dialog
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(_xrayImage == null
                    ? 'Select X-Ray Image'
                    : 'Change X-Ray Image'),
                onPressed: () {
                  _showImageSourceDialog(context); // Call the dialog function
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              // Optional: Add a save button if needed, enabled only when image is selected
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _xrayImage == null
                    ? null
                    : () {
                        // TODO: Implement save/upload logic
                        print("Saving X-Ray...");
                        print("Image path: ${_xrayImage?.path}");
                        // Potentially navigate back or show success message
                        // Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).primaryColor, // Use primary color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Save X-Ray'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
