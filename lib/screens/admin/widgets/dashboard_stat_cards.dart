import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final double? trendPercent;
  final bool? isPositiveTrend;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = Colors.blue,
    this.iconBgColor = const Color(0xFFF0F7FF),
    this.trendPercent,
    this.isPositiveTrend,
  });

  @override
  State<AdminStatCard> createState() => _AdminStatCardState();
}

class _AdminStatCardState extends State<AdminStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 500;

    final numericOnly = widget.value.replaceAll(RegExp(r'[^0-9.]'), '');
    final double? endValue = double.tryParse(numericOnly);
    final isPercent = widget.value.contains('%');
    final prefix = widget.value.startsWith(RegExp(r'[^0-9]')) && !isPercent && widget.value.isNotEmpty
        ? widget.value.substring(0, 1)
        : '';
    final suffix = isPercent ? '%' : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        padding: EdgeInsets.all(isSmall ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? widget.iconColor.withValues(alpha: 0.3) : AppColors.border,
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [AppShadows.lg.copyWith(color: widget.iconColor.withValues(alpha: 0.08))]
              : [AppShadows.md],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: AppDurations.medium,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: _isHovered
                        ? LinearGradient(
                            colors: [widget.iconColor, widget.iconColor.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isHovered ? null : widget.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isHovered ? Colors.white : widget.iconColor,
                    size: 22,
                  ),
                ),
                if (widget.trendPercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (widget.isPositiveTrend ?? true)
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (widget.isPositiveTrend ?? true)
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: (widget.isPositiveTrend ?? true)
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.trendPercent!.toStringAsFixed(1)}%',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: (widget.isPositiveTrend ?? true)
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                endValue != null
                    ? TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutExpo,
                        tween: Tween<double>(begin: 0, end: endValue),
                        builder: (context, val, child) {
                          String formattedVal;
                          if (endValue == endValue.toInt()) {
                            formattedVal = val.toInt().toString();
                          } else {
                            formattedVal = val.toStringAsFixed(1);
                          }
                          return Text(
                            '$prefix$formattedVal$suffix',
                            style: GoogleFonts.outfit(
                              fontSize: isSmall ? 24 : 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                          );
                        },
                      )
                    : Text(
                        widget.value,
                        style: GoogleFonts.outfit(
                          fontSize: isSmall ? 24 : 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                const SizedBox(height: 6),
                Text(
                  widget.title,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
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

class AdminSolidStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;

  const AdminSolidStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  State<AdminSolidStatCard> createState() => _AdminSolidStatCardState();
}

class _AdminSolidStatCardState extends State<AdminSolidStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 500;

    final numericOnly = widget.value.replaceAll(RegExp(r'[^0-9.]'), '');
    final double? endValue = double.tryParse(numericOnly);
    final isPercent = widget.value.contains('%');
    final prefix = widget.value.startsWith(RegExp(r'[^0-9]')) && !isPercent && widget.value.isNotEmpty
        ? widget.value.substring(0, 1)
        : '';
    final suffix = isPercent ? '%' : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        padding: EdgeInsets.all(isSmall ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.backgroundColor, widget.backgroundColor.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withValues(alpha: _isHovered ? 0.35 : 0.25),
              blurRadius: _isHovered ? 24 : 12,
              offset: _isHovered ? const Offset(0, 12) : const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      endValue != null
                          ? TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutExpo,
                              tween: Tween<double>(begin: 0, end: endValue),
                              builder: (context, val, child) {
                                String formattedVal;
                                if (endValue == endValue.toInt()) {
                                  formattedVal = val.toInt().toString();
                                } else {
                                  formattedVal = val.toStringAsFixed(1);
                                }
                                return Text(
                                  '$prefix$formattedVal$suffix',
                                  style: GoogleFonts.outfit(
                                    fontSize: isSmall ? 28 : 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            )
                          : Text(
                              widget.value,
                              style: GoogleFonts.outfit(
                                fontSize: isSmall ? 28 : 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(height: 6),
                      Text(
                        widget.title,
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
