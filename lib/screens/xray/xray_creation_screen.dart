import 'dart:convert';
import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class XRayCreation extends StatefulWidget {
  final Horse horse;
  const XRayCreation({super.key, required this.horse});

  @override
  State<XRayCreation> createState() => _XRayCreationState();
}

class _XRayCreationState extends State<XRayCreation> {
  File? _localXrayImageFile; // Store the locally picked file
  String? _uploadedImageUrl; // Store the URL returned by the API
  bool _isUploading = false; // Loading state for upload
  String? _uploadError; // Error message state

  Future<void> _pickImage(ImageSource source) async {
    // Prevent picking if already uploading
    if (_isUploading) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: source,
      // imageQuality: 80, // Optional
    );
    if (pickedImage == null) {
      return; // User cancelled picker
    }

    // Update the state with the selected image file
    // Reset uploaded URL and error when a new local image is picked
    setState(() {
      _localXrayImageFile = File(pickedImage.path);
      _uploadedImageUrl = null;
      _uploadError = null;
    });
  }

  // Renamed from _saveXRay to _uploadXRay for clarity
  Future<void> _uploadXRay() async {
    if (_localXrayImageFile == null) {
      setState(() {
        _uploadError = "Please select an image first.";
      });
      return;
    }
    if (_isUploading) return; // Prevent multiple uploads

    setState(() {
      _isUploading = true;
      _uploadError = null; // Clear previous errors
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    final headers = <String, String>{};

    // Add Authorization header if token exists
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      // Handle missing token case
      setState(() {
        _isUploading = false;
        _uploadError = "Authentication error. Please login again.";
      });
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        // Ensure this is the correct endpoint for uploading X-Rays
        Uri.parse('http://10.0.2.2:9090/xray'),
      );
      // Add JWT token to headers
      request.headers.addAll(headers);

      // Add horse ID as a field (adjust field name if needed by backend)
      request.fields['horseId'] = widget.horse.idHorse.toString();

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture', // Ensure this field name matches backend expectation
          _localXrayImageFile!.path, // Use the local file path
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check for 200 or 201 Created
        var jsonResponse = jsonDecode(responseBody);

        // --- Extract the returned image URL ---
        // IMPORTANT: Adjust 'imageUrl' or 'xrayPath' to the actual key your API returns
        final String? returnedUrl = jsonResponse['returnedImageUrl'];

        if (returnedUrl != null) {
          setState(() {
            _uploadedImageUrl = returnedUrl; // Store the returned URL
            _localXrayImageFile =
                null; // Clear local file after successful upload (optional)
            _isUploading = false;
          });
          // Optionally show success message or navigate back
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('X-Ray uploaded successfully!')),
            );
            // Navigator.pop(context); // Example: Go back after upload
          }
        } else {
          // Handle case where API response is successful but URL is missing
          throw Exception('API did not return an image URL.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access uploading X-Ray.');
      } else {
        // Throw detailed error
        throw Exception(
            'Upload failed. Status: ${response.statusCode}. Body: $responseBody');
      }
    } catch (e) {
      debugPrint("Error uploading X-Ray: $e");
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadError = "Upload failed: ${e.toString()}";
        });
      }
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    // Prevent opening if uploading
    if (_isUploading) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(modalContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(modalContext);
                  _pickImage(ImageSource.camera);
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
    // Determine which image source to use for display
    ImageProvider? displayImageProvider;
    if (_uploadedImageUrl != null) {
      // If uploaded URL exists, use NetworkImage
      displayImageProvider = NetworkImage(_uploadedImageUrl!);
    } else if (_localXrayImageFile != null) {
      // Otherwise, if local file exists, use FileImage
      displayImageProvider = FileImage(_localXrayImageFile!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("X-Ray for ${widget.horse.name}"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the selected image (local or network) or a placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade100,
                  ),
                  alignment: Alignment.center,
                  child: _isUploading // Show loading indicator during upload
                      ? const CircularProgressIndicator()
                      : displayImageProvider != null
                          ? Image(
                              image: displayImageProvider,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Handle network or file loading errors
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.red, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                        _uploadedImageUrl != null
                                            ? 'Error loading network image'
                                            : 'Error loading local file',
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ],
                                );
                              },
                            )
                          : const Column(
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
              // Display upload error message if any
              if (_uploadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _uploadError!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),

              // Button to trigger the image source dialog
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(displayImageProvider == null
                    ? 'Select X-Ray Image'
                    : 'Change X-Ray Image'),
                // Disable button while uploading
                onPressed: _isUploading
                    ? null
                    : () {
                        _showImageSourceDialog(context);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              // Save/Upload button
              const SizedBox(height: 10),
              ElevatedButton(
                // Disable if no local image is selected or if currently uploading
                onPressed: (_localXrayImageFile == null || _isUploading)
                    ? null
                    : _uploadXRay, // Call the upload function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isUploading
                    ? const SizedBox(
                        // Show indicator inside button when uploading
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('See X-Ray'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
