import 'package:flutter/material.dart';
import 'dart:io';

class ProfileImagePreview extends StatelessWidget {
  final File? profileImageFile;

  final VoidCallback onEditPressed;

  const ProfileImagePreview({
    super.key,
    required this.profileImageFile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          // If there's no image, display text
          if (profileImageFile == null)
            const Center(
              child: Text(
                'Image here',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            // Display image if available
            Image.file(
              profileImageFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

          // Back arrow icon
          Positioned(
            top: 30,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(100),
                ),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Edit Photo Button
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onEditPressed,
            ),
          ),
        ],
      ),
    );
  }
}
