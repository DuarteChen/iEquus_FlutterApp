import 'package:flutter/material.dart';

class MainButtonBlue extends StatelessWidget {
  const MainButtonBlue({
    super.key,
    this.icon,
    this.iconImage,
    required this.buttonText,
    required this.onTap,
  });

  final IconData? icon;
  final String? iconImage;
  final String buttonText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    // Check if any icon or image is provided
    final hasIcon = icon != null || iconImage != null;

    if (hasIcon) {
      // Button with icon or image
      return ElevatedButton.icon(
        icon: icon != null
            ? Icon(icon)
            : ImageIcon(AssetImage(iconImage!), size: 24),
        onPressed: onTap,
        style: _buttonStyle(),
        label: Text(buttonText),
      );
    } else {
      // Text-only button
      return ElevatedButton(
        onPressed: onTap,
        style: _buttonStyle(),
        child: Text(buttonText),
      );
    }
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
    );
  }
}
