import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class QuickActionCard extends StatefulWidget {
  final String label;
  final String? subLabel;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.subLabel,
    this.accentColor,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.accentColor ?? AppColors.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..translate(4, 0, 0)) : Matrix4.identity(),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? themeColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered ? themeColor.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.01),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isHovered ? themeColor.withValues(alpha: 0.15) : themeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon, 
                    size: 24, 
                    color: themeColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (widget.subLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _isHovered ? themeColor : Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

