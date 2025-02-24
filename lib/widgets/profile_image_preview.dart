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
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 4,
      child: Stack(
        children: [
          // If there's no image, display text
          if (profileImageFile == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Image.asset(
                  'assets/images/horse_empty_profile_image.png', // Ensure the path is correct
                  fit: BoxFit.cover,
                ),
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
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onEditPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
