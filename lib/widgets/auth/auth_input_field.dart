import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? error;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.error,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isFocused
                  ? AppColors.primary
                  : hasError
                      ? AppColors.error
                      : AppColors.textPrimary,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary
                  : hasError
                      ? AppColors.error
                      : AppColors.border,
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            onChanged: (v) {
              widget.onChanged?.call(v);
            },
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 15),
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused
                            ? AppColors.primary
                            : hasError
                                ? AppColors.error
                                : const Color(0xFF999999),
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: hasError
                  ? AppColors.error.withValues(alpha: 0.05)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Row(
              children: [
                Icon(Icons.info_rounded, size: 13, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  widget.error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
