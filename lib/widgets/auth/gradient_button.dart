import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double? width;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.height = 52,
    this.borderRadius = 12,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isDisabled || isLoading;
    final effectiveOnPressed = disabled ? null : onPressed;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: disabled
              ? null
              : const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF1D4ED8),
                  ],
                ),
          color: disabled ? Colors.grey[300] : null,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: disabled
                                ? Colors.grey[500]
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
