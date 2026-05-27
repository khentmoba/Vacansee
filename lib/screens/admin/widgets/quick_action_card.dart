import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(4, 0, 0) : Matrix4.identity(),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? themeColor.withValues(alpha: 0.3) : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                _isHovered
                    ? AppShadows.lg.copyWith(color: themeColor.withValues(alpha: 0.06))
                    : AppShadows.sm,
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.medium,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: _isHovered
                        ? LinearGradient(
                            colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isHovered ? null : themeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 24,
                    color: _isHovered ? Colors.white : themeColor,
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
                        style: GoogleFonts.outfit(
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
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
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
                  color: _isHovered ? themeColor : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
