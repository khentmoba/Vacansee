import 'package:flutter/material.dart';

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
          childAspectRatio: isMobile ? 1.0 : 1.3,
          children: [
            _BookingStatCard(
              label: 'Total Bookings',
              value: total.toString(),
              icon: Icons.calendar_today_outlined,
              iconColor: const Color(0xFF5287B2),
            ),
            _BookingStatCard(
              label: 'Pending',
              value: pending.toString(),
              icon: Icons.access_time_outlined,
              iconColor: const Color(0xFFFFA000),
            ),
            _BookingStatCard(
              label: 'Approved',
              value: approved.toString(),
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF4CAF50),
            ),
            _BookingStatCard(
              label: 'Rejected',
              value: rejected.toString(),
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFFF44336),
            ),
          ],
        );
      },
    );
  }
}

class _BookingStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _BookingStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
