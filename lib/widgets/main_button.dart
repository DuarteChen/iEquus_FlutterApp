import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.iconImage,
    required this.buttonText,
    required this.onTap,
  });

  final String iconImage;
  final String buttonText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: ImageIcon(AssetImage(iconImage)),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      label: Text(buttonText),
    );
  }
}
