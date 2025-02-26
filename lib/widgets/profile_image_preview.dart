import 'package:flutter/material.dart';

class ProfileImagePreview extends StatelessWidget {
  final ImageProvider<Object>? profileImageProvider;
  final VoidCallback onEditPressed;

  const ProfileImagePreview({
    super.key,
    this.profileImageProvider,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 4,
      child: Stack(
        children: [
          // Display image using ImageProvider
          Center(
            child: profileImageProvider != null
                ? Image(
                    // Use Image widget to display ImageProvider
                    image: profileImageProvider!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.asset(
                    'assets/images/horse_empty_profile_image.png',
                    fit: BoxFit.cover,
                  ),
          ),

          // Back arrow icon
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => Navigator.pop(context),
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
