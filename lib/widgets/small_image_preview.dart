import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SmallImagePreview extends StatelessWidget {
  final ImageProvider<Object>? profileImageProvider;
  final Function(ImageSource)
      onImageSourceSelected; // Changed to accept ImageSource
  final String emptyLegImage;

  const SmallImagePreview({
    super.key,
    this.profileImageProvider,
    required this.onImageSourceSelected,
    required this.emptyLegImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (profileImageProvider == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Image.asset(
                  emptyLegImage,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          else
            Image(
              image: profileImageProvider!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                _showImageSourceDialog(context);
              },
              child: Container(
                padding: EdgeInsets.all(8), // Adjusted padding
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor, // Adjusted icon size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onImageSourceSelected(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  onImageSourceSelected(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
