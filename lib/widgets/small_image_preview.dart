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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
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
          Positioned(
            bottom: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
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
