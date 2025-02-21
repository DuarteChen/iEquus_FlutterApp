import 'package:flutter/material.dart';
import 'dart:io';

class SmallImagePreview extends StatelessWidget {
  final File? profileImageFile;

  final VoidCallback onEditPressed;

  const SmallImagePreview({
    super.key,
    required this.profileImageFile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (profileImageFile == null)
            const Center(
              child: Text(
                'Image here',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Image.file(
              profileImageFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          // Edit Photo Button
          Positioned(
            bottom: 2,
            right: 2,
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
