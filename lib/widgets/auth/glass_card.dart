import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
