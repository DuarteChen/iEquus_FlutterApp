import 'dart:convert';
import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:equus/models/xray_label.dart';
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
  List<XRayLabel> _xrayLabels = [];
  bool _isUploading = false;
  String? _uploadError;
  ImageInfo? _imageInfo;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  bool _showLabels = true;

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploading) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage == null) return;

    setState(() {
      _localXrayImageFile = File(pickedImage.path);
      _uploadedImageUrl = null;
      _uploadError = null;
      _xrayLabels = [];
      _clearImageInfo();
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
        final Map<String, dynamic>? coordinatesData =
            jsonResponse['coordinates_data'] as Map<String, dynamic>?;

        if (returnedUrl != null) {
          List<XRayLabel> parsedLabels = [];
          if (coordinatesData != null) {
            for (var value in coordinatesData.values) {
              if (value is Map<String, dynamic>) {
                parsedLabels.add(XRayLabel(
                  name: value['label'] as String? ?? 'Unknown Label',
                  x: value['x'] as int? ?? 0,
                  y: value['y'] as int? ?? 0,
                  description:
                      value['description'] as String? ?? 'No description',
                ));
              }
            }
          }
          setState(() {
            _uploadedImageUrl = returnedUrl;
            _xrayLabels = parsedLabels;
            _localXrayImageFile = null;
            _updateImageListener();
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
          _xrayLabels = [];
          _clearImageInfo();
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

  void _showLabelDetailsDialog(BuildContext context, XRayLabel label) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(label.name),
          content: Text(label.description),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _imageListener =
        ImageStreamListener(_handleImageLoaded, onError: _handleImageError);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateImageListener();
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageListener!);
    super.dispose();
  }

  void _handleImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
    });
  }

  void _handleImageError(dynamic exception, StackTrace? stackTrace) {
    debugPrint("Error loading image for dimension calculation: $exception");
    setState(() {
      _imageInfo = null;
    });
  }

  void _clearImageInfo() {
    if (mounted) {
      setState(() {
        _imageInfo = null;
      });
    }

    _imageStream?.removeListener(_imageListener!);
    _imageStream = null;
  }

  void _updateImageListener() {
    _clearImageInfo();
    final ImageProvider? provider = _getImageProvider();
    if (provider != null) {
      _imageStream = provider.resolve(createLocalImageConfiguration(context));
      _imageStream!.addListener(_imageListener!);
    }
  }

  ImageProvider? _getImageProvider() {
    if (_uploadedImageUrl != null) {
      return NetworkImage(_uploadedImageUrl!);
    } else if (_localXrayImageFile != null) {
      return FileImage(_localXrayImageFile!);
    }
    return null;
  }

  Offset _calculateMarkerPosition(XRayLabel label, Size containerSize,
      Size imageSize, FittedSizes fittedSizes) {
    final double scale =
        fittedSizes.destination.width / fittedSizes.source.width;
    final double offsetX =
        (containerSize.width - fittedSizes.destination.width) / 2.0;
    final double offsetY =
        (containerSize.height - fittedSizes.destination.height) / 2.0;

    final double finalX = (label.x * scale) + offsetX;
    final double finalY = (label.y * scale) + offsetY;

    return Offset(finalX, finalY);
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? displayImageProvider = _getImageProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text("X-Ray for ${widget.horse.name}"),
        actions: [
          if (_xrayLabels.isNotEmpty && !_isUploading)
            IconButton(
              icon: Icon(_showLabels ? Icons.visibility_off : Icons.visibility),
              tooltip: _showLabels ? 'Hide Labels' : 'Show Labels',
              onPressed: () {
                setState(() => _showLabels = !_showLabels);
              },
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Image Display Area ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade100,
                  ),
                  alignment: Alignment.center,
                  // Use LayoutBuilder to get container size
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final containerSize =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      FittedSizes? fittedSizes;
                      Size? imageSize;

                      if (_imageInfo != null) {
                        imageSize = Size(_imageInfo!.image.width.toDouble(),
                            _imageInfo!.image.height.toDouble());
                        fittedSizes = applyBoxFit(
                            BoxFit.contain, imageSize, containerSize);
                      }

                      return Stack(
                        children: [
                          // --- Image or Placeholder ---
                          if (_isUploading)
                            const Center(child: CircularProgressIndicator())
                          else if (displayImageProvider != null)
                            Center(
                              child: SizedBox(
                                width: fittedSizes?.destination.width ??
                                    containerSize.width,
                                height: fittedSizes?.destination.height ??
                                    containerSize.height,
                                child: Image(
                                  image: displayImageProvider,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey, size: 50));
                                  },
                                ),
                              ),
                            )
                          else
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported_outlined,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('No X-Ray image selected'),
                              ],
                            ),

                          // --- Positioned Labels ---
                          if (fittedSizes != null &&
                              imageSize != null &&
                              _xrayLabels.isNotEmpty &&
                              !_isUploading)
                            if (_showLabels)
                              ..._xrayLabels.map(
                                (label) {
                                  final Offset position =
                                      _calculateMarkerPosition(
                                          label,
                                          containerSize,
                                          imageSize!,
                                          fittedSizes!);

                                  return Positioned(
                                    left: position.dx - 12,
                                    top: position.dy - 12,
                                    child: GestureDetector(
                                      onTap: () => _showLabelDetailsDialog(
                                          context, label),
                                      child: Tooltip(
                                        message: label.name,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add,
                                              size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ],
                      );
                    },
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
