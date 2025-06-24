import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:equus/models/measure.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/measure/slider_image_coordinates_picker.dart';
import 'package:equus/widgets/bcs_gauge.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateMeasureScreen extends StatefulWidget {
  const CreateMeasureScreen({
    super.key,
    required this.horse,
    this.appointmentID,
  });

  final Horse horse;
  final int? appointmentID;

  @override
  CreateMeasureScreenState createState() => CreateMeasureScreenState();
}

class CreateMeasureScreenState extends State<CreateMeasureScreen> {
  File? _selectedImage;
  File? _selectedImageWithCoordinates;
  File? _oldImage;
  String? _networkImageUrl;
  final List<Offset> _coordinates = [];
  Measure? measure;

  int? _userBW;
  int? algorithmBW;
  int? _userBCS;
  int? algorithmBCS;
  bool? favorite;

  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    measure = Measure(
      id: 0,
      date: DateTime.now(),
      coordinates: [],
      horseId: widget.horse.idHorse,
      picturePath: '',
      appointmentId: widget.appointmentID,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploading || _isSaving) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
      _networkImageUrl = null;
    });

    if (!context.mounted) return;
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SliderImageCoordinatesPicker(
          selectedImage: _selectedImage!,
        ),
      ),
    );

    if (result != null) {
      if (result['coordinates'] != null && result['selectedImage'] != null) {
        //_selectedImage = result['selectedImage']; to save the image wihout the coordinates
        _selectedImageWithCoordinates = result['selectedImage'];
        _oldImage = _selectedImage;
        _coordinates.clear();
        _coordinates.addAll(result['coordinates'].whereType<Offset>());

        await _createMeasure(_selectedImage!, _coordinates);
      }
    } else {
      setState(() {
        _selectedImage = _oldImage;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Coordinate selection cancelled or failed.')),
        );
      }
    }
  }

  Future<void> _createMeasure(
      File pictureFile, List<Offset> coordinates) async {
    if (measure == null) return;

    setState(() {
      _isUploading = true;
    });

    measure!.picturePath = pictureFile.path;
    measure!.coordinates = coordinates;

    final vetProvider =
        Provider.of<VeterinarianProvider>(context, listen: false);
    final int? currentVetId = vetProvider.veterinarian?.idHuman;

    if (currentVetId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Could not get veterinarian profile.')),
        );
      }
      setState(() {
        _isUploading = false;
      });
      return;
    }

    try {
      bool success = await measure!.firstUploadToServer(
        currentVeterinarianId: currentVetId,
      );

      if (success && mounted) {
        setState(() {
          algorithmBCS = measure!.algorithmBCS;
          algorithmBW = measure!.algorithmBW;
          _networkImageUrl = measure!.picturePath;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Measure created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create measure: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _finalSave() async {
    if (measure == null || measure!.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      bool success = await measure!.editBWandBCS(_userBW, _userBCS);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void popUpBWOrBCS(BuildContext context, String bwOrBcs) {
    final TextEditingController controller = TextEditingController();
    String? errorText;

    if (bwOrBcs == 'Body Weight') {
      controller.text = _userBW?.toString() ?? '';
    } else if (bwOrBcs == 'Body Condition Score') {
      controller.text = _userBCS?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit $bwOrBcs'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: bwOrBcs,
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  int? number = int.tryParse(controller.text);
                  bool isValid = true;
                  String? currentError;

                  if (number == null) {
                    isValid = false;
                    currentError = 'Please enter a valid number.';
                  } else if (bwOrBcs == 'Body Condition Score' &&
                      (number < 1 || number > 5)) {
                    isValid = false;
                    currentError = 'BCS must be between 1 and 5.';
                  } else if (bwOrBcs == 'Body Weight' && number < 0) {
                    isValid = false;
                    currentError = 'Weight cannot be negative.';
                  }

                  if (isValid) {
                    setState(() {
                      if (bwOrBcs == 'Body Weight') {
                        _userBW = number;
                      } else if (bwOrBcs == 'Body Condition Score') {
                        _userBCS = number;
                      }
                    });
                    Navigator.of(context).pop();
                  } else {
                    setDialogState(() {
                      errorText = currentError;
                    });
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    if (_isUploading || _isSaving) return;

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
    Widget bcsTile(int? bcsValue) {
      final displayValue = bcsValue ?? 0;
      return Expanded(
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("BCS", style: TextStyle(fontSize: 20)),
                    GestureDetector(
                      onTap: (_selectedImage == null &&
                                  _networkImageUrl == null ||
                              _isUploading)
                          ? null
                          : () => popUpBWOrBCS(context, "Body Condition Score"),
                      child: Icon(
                        Icons.edit,
                        color: (_selectedImage == null &&
                                    _networkImageUrl == null ||
                                _isUploading)
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: CustomPaint(
                      size: const Size(110, 80),
                      painter: GaugePainter(displayValue.toDouble()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget bwTile(int? weight) {
      final displayValue = weight ?? 0;
      return Expanded(
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("kg", style: TextStyle(fontSize: 20)),
                    GestureDetector(
                      onTap:
                          (_selectedImage == null && _networkImageUrl == null ||
                                  _isUploading)
                              ? null
                              : () => popUpBWOrBCS(context, "Body Weight"),
                      child: Icon(
                        Icons.edit,
                        color: (_selectedImage == null &&
                                    _networkImageUrl == null ||
                                _isUploading)
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      displayValue.toString(),
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget imageContainer = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade100,
        ),
        alignment: Alignment.center,
        child: _isUploading
            ? const CircularProgressIndicator()
            : _selectedImageWithCoordinates != null
                ? Image.file(
                    _selectedImageWithCoordinates!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Error loading local image',
                          style: TextStyle(color: Colors.red));
                    },
                  )
                : _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Error loading local image',
                              style: TextStyle(color: Colors.red));
                        },
                      )
                    : Image.asset(
                        'assets/images/horseAppointmentPlaceHolder.png',
                        fit: BoxFit.contain,
                      ),
      ),
    );

    bool canSave =
        measure != null && measure!.id != 0 && !_isSaving && !_isUploading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            if (measure?.id != null &&
                measure!.id != 0 &&
                !_isSaving &&
                !_isUploading) {
              try {
                await measure!.deleteMeasure();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to discard measure: ${e.toString()}')),
                  );
                }
              }
            }
            if (mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.delete_outline),
        ),
        title: Text("Measure for ${widget.horse.name}"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Save Measure",
            onPressed: canSave ? _finalSave : null,
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))
                : const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              imageContainer,
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text((_selectedImage == null && _networkImageUrl == null)
                    ? 'Select Measure Image'
                    : 'Change Measure Image'),
                onPressed: (_isUploading || _isSaving)
                    ? null
                    : () {
                        if (measure != null && measure!.id != 0) {
                          measure!.deleteMeasure().then((_) {
                            _showImageSourceDialog(context);
                          }).catchError((e) {
                            _showImageSourceDialog(context);
                          });
                        } else {
                          _showImageSourceDialog(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bwTile(_userBW ?? algorithmBW),
                  const SizedBox(width: 16),
                  bcsTile(_userBCS ?? algorithmBCS),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
