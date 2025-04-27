import 'package:flutter/material.dart';

class MainButtonBlue extends StatelessWidget {
  const MainButtonBlue({
    super.key,
    this.iconString,
    this.iconImage,
    required this.buttonText,
    required this.onTap,
    this.icon,
    this.child,
  });
  final Icon? icon;
  final IconData? iconString;
  final String? iconImage;
  final String buttonText;
  final void Function()? onTap;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final bool hasIcon =
        iconString != null || iconImage != null || icon != null;

    Widget? displayIcon;
    if (icon != null) {
      displayIcon = icon;
    } else if (iconString != null) {
      displayIcon = Icon(iconString);
    } else if (iconImage != null) {
      displayIcon = ImageIcon(AssetImage(iconImage!), size: 24);
    }

    if (child != null) {
      return ElevatedButton(
        onPressed: onTap,
        style: _buttonStyle(context),
        child: child,
      );
    } else if (hasIcon && displayIcon != null) {
      return ElevatedButton.icon(
        icon: displayIcon,
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
      minimumSize: const Size(88, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
