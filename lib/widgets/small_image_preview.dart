import 'package:flutter/material.dart';
import 'dart:io';

class SmallImagePreview extends StatelessWidget {
  final ImageProvider<Object>? profileImageProvider; // Changed to ImageProvider
  final VoidCallback onEditPressed;
  final String emptyLegImage;

  const SmallImagePreview({
    super.key,
    this.profileImageProvider, // Changed to ImageProvider
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
          if (profileImageProvider ==
              null) // Check for ImageProvider being null
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Image.asset(
                emptyLegImage,
                color: Theme.of(context).primaryColor,
              )),
            )
          else
            Image(
              // Use Image Widget to display ImageProvider
              image: profileImageProvider!,
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
