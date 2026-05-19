import 'package:flutter/material.dart';

/// Primary full-width action button — monochrome, zero-radius, 1px border.
class MonochromeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled; // true = filled (primary), false = outlined (secondary)
  final bool isLoading;

  const MonochromeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final child = isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: filled ? cs.onPrimary : cs.primary,
            ),
          )
        : Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.22,
            ),
          );

    if (filled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
