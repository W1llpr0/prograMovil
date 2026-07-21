import 'package:flutter/material.dart';

class LineInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
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
    this.prefixIcon,
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
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          textCapitalization: widget.textCapitalization,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon:
                widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    tooltip:
                        _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      );
}
