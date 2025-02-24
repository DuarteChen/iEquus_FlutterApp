import 'package:flutter/material.dart';
import 'dart:io';

class SmallImagePreview extends StatelessWidget {
  final File? profileImageFile;

  final VoidCallback onEditPressed;
  final String emptyLegImage;

  const SmallImagePreview({
    super.key,
    required this.profileImageFile,
    required this.onEditPressed,
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
          if (profileImageFile == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Image.asset(
                emptyLegImage,
                color: const Color.fromARGB(255, 222, 222, 222),
              )),
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
