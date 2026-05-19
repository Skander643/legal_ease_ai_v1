import 'package:flutter/material.dart';

enum ButtonType { elevated, outlined, text }

class CustomButton extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final ButtonType type;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.type = ButtonType.elevated,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    // Base button widget
    Widget buttonWidget;

    if (type == ButtonType.elevated) {
      buttonWidget = ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(isLoading ? (loadingLabel ?? '...') : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          minimumSize: fullWidth ? const Size.fromHeight(50) : null,
        ),
      );
    } else if (type == ButtonType.outlined) {
      buttonWidget = OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(isLoading ? (loadingLabel ?? '...') : label),
        style: OutlinedButton.styleFrom(
          padding: padding,
          minimumSize: fullWidth ? const Size.fromHeight(50) : null,
        ),
      );
    } else {
      buttonWidget = TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(isLoading ? (loadingLabel ?? '...') : label),
      );
    }

    return buttonWidget;
  }
}
