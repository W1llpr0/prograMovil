import 'package:flutter/material.dart';

/// Underline text field matching VetCare's design system.
/// Shows an animated MONO label above + 1px bottom border.
class LineInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextCapitalization textCapitalization;

  const LineInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<LineInput> createState() => _LineInputState();
}

class _LineInputState extends State<LineInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labelColor = _focused ? cs.onSurface : cs.onSurface.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 9,
                letterSpacing: 0.22,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
              child: Text(widget.label.toUpperCase()),
            ),
            TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              textCapitalization: widget.textCapitalization,
              validator: widget.validator,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.02,
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: cs.onSurface, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: cs.onSurface, width: 1),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: cs.onSurface, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
