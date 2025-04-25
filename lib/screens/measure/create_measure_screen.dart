import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:equus/models/measure.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/measure/slider_image_coordinates_picker.dart';
import 'package:equus/widgets/bcs_gauge.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Import for DateFormat
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
  File? _selectedImage; // For local file picking
  File? _oldImage; // For local file picking
  String? _networkImageUrl; // For URL from API
  final List<Offset> _coordinates = [];
  Measure? measure;

  // State for user inputs and algorithm results
  int? _userBW;
  int? algorithmBW;
  int? _userBCS;
  int? algorithmBCS;
  bool? favorite;

  bool _isUploading = false; // State for initial upload loading
  bool _isSaving = false; // State for final save loading

  @override
  void initState() {
    super.initState();
    // Initialize the measure object
    measure = Measure(
      id: 0, // Initial ID is 0 until saved to server
      date: DateTime.now(),
      coordinates: [],
      horseId: widget.horse.idHorse,
      picturePath: '', // Will be set after image selection/upload
      appointmentId: widget.appointmentID, // Use passed appointment ID
      // veterinarianId will be set during upload
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Prevent picking if already uploading/saving
    if (_isUploading || _isSaving) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: source,
      // imageQuality: 80, // Optional: Adjust quality
    );
    if (pickedImage == null) {
      return; // User cancelled
    }

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
        _selectedImage = result['selectedImage'];
        _oldImage = _selectedImage;
        _coordinates.clear(); // Clear previous coordinates
        _coordinates.addAll(result['coordinates'].whereType<Offset>());

        await _createMeasure(_selectedImage!, _coordinates);
      }
    } else {
/*       setState(() {
        _selectedImage =
            null; // Clear image if coordinate picking was cancelled
        _coordinates.clear();
      }); */
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
    if (measure == null) return; // Should not happen, but safety check

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
          // --- Store the network URL ---
          _networkImageUrl = measure!.picturePath;
          _selectedImage = null;
          // --- End Store the network URL ---
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
      // setState(() { _selectedImage = null; _coordinates.clear(); });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false; // Hide loading indicator
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
    if (_isSaving) return; // Prevent multiple saves

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

  // --- Popups remain largely the same ---
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
                errorText: errorText, // Display error text
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
                    // Update the main screen's state
                    setState(() {
                      if (bwOrBcs == 'Body Weight') {
                        _userBW = number;
                      } else if (bwOrBcs == 'Body Condition Score') {
                        _userBCS = number;
                      }
                    });
                    Navigator.of(context).pop(); // Close dialog on success
                  } else {
                    // Update the dialog's state to show the error
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

  void popUpBCS(
      BuildContext context, Function(int) onBCSSelected, int initialBCS) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedBCS = initialBCS.clamp(1, 5); // Clamp initial value

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Body Condition Score'),
              content: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  int value = index + 1;
                  bool isSelected = selectedBCS == value;
                  return SizedBox(
                    width: 45, // Slightly wider
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedBCS = value;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(45, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // More rounded
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade400,
                          width: isSelected
                              ? 2.0
                              : 1.0, // Thicker border if selected
                        ),
                        backgroundColor: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onBCSSelected(selectedBCS); // Call the callback
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- End Popups ---

  void _showImageSourceDialog(BuildContext context) {
    // Prevent opening if already uploading/saving
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
                  Navigator.pop(modalContext); // Close sheet FIRST
                  _pickImage(ImageSource.gallery); // THEN pick
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(modalContext); // Close sheet FIRST
                  _pickImage(ImageSource.camera); // THEN pick
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
    // --- Define Tiles ---
    Widget bcsTile(int? bcsValue) {
      // Accept nullable int
      final displayValue = bcsValue ?? 0; // Use 0 if null
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
                      // Disable edit if no image selected/loaded or uploading
                      onTap:
                          (_selectedImage == null && _networkImageUrl == null ||
                                  _isUploading)
                              ? null
                              : () => popUpBCS(
                                    context,
                                    (newBCS) {
                                      setState(() {
                                        _userBCS = newBCS;
                                      });
                                    },
                                    _userBCS ??
                                        algorithmBCS ??
                                        0, // Pass current value
                                  ),
                      child: Icon(
                        Icons.edit,
                        color: (_selectedImage == null &&
                                    _networkImageUrl == null ||
                                _isUploading)
                            ? Colors.grey // Disabled color
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  // Allow gauge to take available space
                  child: Center(
                    child: CustomPaint(
                      size: const Size(110, 80), // Keep original size request
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
      // Accept nullable int
      final displayValue = weight ?? 0; // Use 0 if null
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
                      // Disable edit if no image selected/loaded or uploading
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
                            ? Colors.grey // Disabled color
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  // Allow text to take available space and center
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
    // --- End Define Tiles ---

    // --- Define Image Container ---
    Widget imageContainer = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade100,
        ),
        alignment: Alignment.center,
        child: _isUploading // Show loading indicator during initial upload
            ? const CircularProgressIndicator()
            : _networkImageUrl != null // Check for network URL first
                ? Image.network(
                    // Use Image.network
                    _networkImageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 40),
                          SizedBox(height: 8),
                          Text('Error loading network image',
                              style: TextStyle(color: Colors.red)),
                        ],
                      );
                    },
                  )
                : _selectedImage != null // Then check for local file
                    ? Image.file(
                        // Use Image.file
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
    // --- End Define Image Container ---

    // Determine if save should be enabled
    bool canSave =
        measure != null && measure!.id != 0 && !_isSaving && !_isUploading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            // Make async
            // Only attempt delete if an ID exists and not currently saving/uploading
            if (measure?.id != null &&
                measure!.id != 0 &&
                !_isSaving &&
                !_isUploading) {
              try {
                await measure!.deleteMeasure();
                debugPrint("Measure deleted on back navigation.");
              } catch (e) {
                debugPrint("Error deleting measure on back navigation: $e");
                // Optionally show a snackbar if deletion fails
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to discard measure: ${e.toString()}')),
                  );
                }
                // Decide if navigation should proceed even if delete fails
                // return; // Uncomment to prevent navigating back if delete fails
              }
            }
            if (mounted) Navigator.pop(context); // Navigate back
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text("Measure for ${widget.horse.name}"), // More specific title
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Save Measure",
            // Enable save based on the canSave flag
            onPressed: canSave ? _finalSave : null,
            icon: _isSaving // Show loading indicator while saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))
                : const Icon(Icons.save_rounded),
          ),
        ],
      ),
      // Use SafeArea to avoid OS intrusions
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Image Container ---
              imageContainer,
              const SizedBox(height: 16),

              // --- Button to Select/Change Image ---
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text((_selectedImage == null && _networkImageUrl == null)
                    ? 'Select Measure Image'
                    : 'Change Measure Image'),
                // Disable button while uploading/saving
                onPressed: (_isUploading || _isSaving)
                    ? null
                    : () {
                        // If changing image, delete the previous measure first
                        if (measure != null && measure!.id != 0) {
                          measure!.deleteMeasure().then((_) {
                            // Proceed to pick new image regardless of delete success/failure for now
                            // Could add error handling here if delete is critical
                            _showImageSourceDialog(context);
                          }).catchError((e) {
                            debugPrint(
                                "Error deleting previous measure before picking new image: $e");
                            // Still allow picking a new image even if delete failed
                            _showImageSourceDialog(context);
                          });
                        } else {
                          // If no measure exists yet, just show the dialog
                          _showImageSourceDialog(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),

              // --- BW and BCS Tiles ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pass the appropriate values (user input OR algorithm result)
                  bwTile(_userBW ?? algorithmBW),
                  const SizedBox(width: 16),
                  bcsTile(_userBCS ?? algorithmBCS),
                ],
              ),
              // Add Spacer if you want tiles pushed to the bottom
              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
