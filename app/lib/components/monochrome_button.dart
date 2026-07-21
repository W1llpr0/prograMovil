import 'package:flutter/material.dart';

class MonochromeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isLoading;
  final IconData? icon;

  const MonochromeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (icon != null) ...[
                const SizedBox(width: 10),
                Icon(icon, size: 20),
              ],
            ],
          );
    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
    );
  }
}
