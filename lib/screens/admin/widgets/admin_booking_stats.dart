import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminBookingStats extends StatelessWidget {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  const AdminBookingStats({
    super.key,
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.2 : 1.4,
          children: [
            _BookingStatCard(
              label: 'Total Bookings',
              value: total,
              icon: Icons.calendar_today_outlined,
              iconColor: AppColors.primary,
            ),
            _BookingStatCard(
              label: 'Pending',
              value: pending,
              icon: Icons.access_time_outlined,
              iconColor: AppColors.warning,
            ),
            _BookingStatCard(
              label: 'Approved',
              value: approved,
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
            ),
            _BookingStatCard(
              label: 'Rejected',
              value: rejected,
              icon: Icons.cancel_outlined,
              iconColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }
}

class _BookingStatCard extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;

  const _BookingStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_BookingStatCard> createState() => _BookingStatCardState();
}

class _BookingStatCardState extends State<_BookingStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -4, 0)) : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? widget.iconColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? widget.iconColor.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isHovered ? widget.iconColor.withValues(alpha: 0.15) : widget.iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutExpo,
                  tween: Tween<double>(begin: 0, end: widget.value.toDouble()),
                  builder: (context, val, child) {
                    return Text(
                      val.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
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

