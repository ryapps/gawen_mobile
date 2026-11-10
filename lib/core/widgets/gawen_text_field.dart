import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

import 'gawen_text.dart';

class GawenTextField extends StatefulWidget {
  const GawenTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.suffixTooltip,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.maxLines = 1,
    this.indonesianPhone = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final String? suffixTooltip;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int maxLines;
  final bool indonesianPhone;
  final bool enabled;

  @override
  State<GawenTextField> createState() => _GawenTextFieldState();
}

class _GawenTextFieldState extends State<GawenTextField> {
  late bool _obscured = widget.obscureText;

  @override
  void didUpdateWidget(covariant GawenTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: GawenLabel(widget.label),
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          obscureText: _obscured,
          textCapitalization: widget.textCapitalization,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(fontSize: 14, color: GawenColors.muted),
            prefixIcon: widget.indonesianPhone
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 12),
                    child: Center(
                      widthFactor: 0,
                      child: Text(
                        '+62',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : widget.icon == null
                ? null
                : widget.maxLines > 1
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Icon(widget.icon, size: 19),
                    ),
                  )
                : Icon(widget.icon, size: 19),
            prefixIconConstraints: widget.indonesianPhone
                ? const BoxConstraints(minWidth: 58)
                : null,
            counterText: '',
            suffixIcon: widget.obscureText || widget.suffixIcon != null
                ? IconButton(
                    tooltip: widget.obscureText
                        ? _obscured
                              ? 'Tampilkan password'
                              : 'Sembunyikan password'
                        : widget.suffixTooltip,
                    onPressed: widget.obscureText
                        ? () => setState(() => _obscured = !_obscured)
                        : widget.onSuffixPressed,
                    icon: Icon(
                      widget.obscureText
                          ? _obscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined
                          : widget.suffixIcon,
                      size: 19,
                    ),
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}
