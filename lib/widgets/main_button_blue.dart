import 'package:flutter/material.dart';

class MainButtonBlue extends StatelessWidget {
  const MainButtonBlue({
    super.key,
    this.iconString,
    this.iconImage,
    required this.buttonText,
    required this.onTap,
    this.icon, // The Icon widget parameter
    this.child, // Added child parameter for loading indicator
  });
  final Icon? icon;
  final IconData? iconString;
  final String? iconImage;
  final String buttonText;
  final void Function()? onTap;
  final Widget? child; // Added child parameter

  @override
  Widget build(BuildContext context) {
    // Check if any icon representation is provided
    final bool hasIcon =
        iconString != null || iconImage != null || icon != null;

    // Determine the icon widget to display if one exists
    Widget? displayIcon;
    if (icon != null) {
      displayIcon = icon; // Prioritize the Icon widget if provided
    } else if (iconString != null) {
      displayIcon = Icon(iconString);
    } else if (iconImage != null) {
      displayIcon = ImageIcon(AssetImage(iconImage!), size: 24);
    }

    // If a child is provided (like a loading indicator), show it instead of text/icon
    if (child != null) {
      return ElevatedButton(
        onPressed: onTap,
        style: _buttonStyle(context),
        child: child,
      );
    }
    // Build button with or without icon based on the check
    else if (hasIcon && displayIcon != null) {
      // Button with icon
      return ElevatedButton.icon(
        icon: displayIcon, // Use the determined icon widget
        onPressed: onTap,
        style: _buttonStyle(context),
        label: Text(buttonText),
      );
    } else {
      // Text-only button
      return ElevatedButton(
        onPressed: onTap,
        style: _buttonStyle(context),
        child: Text(buttonText),
      );
    }
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      // Add other consistent styles if needed (padding, shape, etc.)
      minimumSize: const Size(88, 44), // Example minimum size
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Example shape
      ),
    );
  }
}
