import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Underline text field matching VetCare's design system.
/// Shows an animated MONO label above + 1px bottom border + focus square indicator.
class LineInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showPasswordToggle;
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
    this.showPasswordToggle = false,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<LineInput> createState() => _LineInputState();
}

class _LineInputState extends State<LineInput> {
  bool _focused = false;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

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
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 0.22,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: _obscure,
                  maxLines: widget.maxLines,
                  textCapitalization: widget.textCapitalization,
                  validator: widget.validator,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.02 * 18,
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      color: cs.onSurface.withValues(alpha: 0.35),
                    ),
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
                    contentPadding: EdgeInsets.fromLTRB(0, 6, widget.showPasswordToggle ? 44 : 20, 10),
                    suffixIcon: widget.showPasswordToggle
                        ? IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                            splashRadius: 18,
                          )
                        : null,
                  ),
                ),
                // Focus indicator — small filled square (from mockup); hidden when toggle is shown
                if (!widget.showPasswordToggle)
                  AnimatedOpacity(
                    opacity: _focused ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 4),
                      color: cs.onSurface,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
