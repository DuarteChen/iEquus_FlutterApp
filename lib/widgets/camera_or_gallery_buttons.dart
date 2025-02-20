import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraOrGalleryButtons extends StatelessWidget {
  const CameraOrGalleryButtons(
      {super.key,
      required this.picType,
      required this.setImageToVariable,
      required this.source});

  final String picType;
  final ImageSource source;
  final void Function(ImageSource source, String picType) setImageToVariable;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => setImageToVariable(source, picType),
          icon: const Icon(Icons.camera),
          label: const Text("Take Picture"),
        ),
        ElevatedButton.icon(
          onPressed: () => setImageToVariable(source, picType),
          icon: const Icon(Icons.photo_library),
          label: const Text("Choose from Gallery"),
        ),
      ],
    );
  }
}
