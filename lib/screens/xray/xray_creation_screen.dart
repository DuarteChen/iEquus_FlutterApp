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
  File? _localXrayImageFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  String? _uploadError;

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploading) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage == null) return;

    setState(() {
      _localXrayImageFile = File(pickedImage.path);
      _uploadedImageUrl = null;
      _uploadError = null;
    });
  }

  Future<void> _uploadXRay() async {
    if (_localXrayImageFile == null) {
      setState(() {
        _uploadError = "Please select an image first.";
      });
      return;
    }
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    final headers = <String, String>{};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      setState(() {
        _isUploading = false;
        _uploadError = "Authentication error. Please login again.";
      });
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:9090/xray'),
      );
      request.headers.addAll(headers);
      request.fields['horseId'] = widget.horse.idHorse.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          _localXrayImageFile!.path,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        final String? returnedUrl = jsonResponse['returnedImageUrl'];

        if (returnedUrl != null) {
          setState(() {
            _uploadedImageUrl = returnedUrl;
            _localXrayImageFile = null;
            _isUploading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('X-Ray uploaded successfully!')),
            );
          }
        } else {
          throw Exception('API did not return an image URL.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access uploading X-Ray.');
      } else {
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
    ImageProvider? displayImageProvider;
    if (_uploadedImageUrl != null) {
      displayImageProvider = NetworkImage(_uploadedImageUrl!);
    } else if (_localXrayImageFile != null) {
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade100,
                  ),
                  alignment: Alignment.center,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : displayImageProvider != null
                          ? Image(
                              image: displayImageProvider,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
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
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(displayImageProvider == null
                    ? 'Select X-Ray Image'
                    : 'Change X-Ray Image'),
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (_localXrayImageFile == null || _isUploading)
                    ? null
                    : _uploadXRay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isUploading
                    ? const SizedBox(
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
