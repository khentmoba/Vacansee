import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminListingStats extends StatelessWidget {
  final int total;
  final int available;
  final int full;
  final int availableRooms;

  const AdminListingStats({
    super.key,
    required this.total,
    required this.available,
    required this.full,
    required this.availableRooms,
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
          childAspectRatio: isMobile ? 1.3 : 1.5,
          children: [
            _StatCard(
              label: 'Total Listings',
              value: total.toString(),
              color: AppColors.primary,
            ),
            _StatCard(
              label: 'Available',
              value: available.toString(),
              color: AppColors.success,
            ),
            _StatCard(
              label: 'Full',
              value: full.toString(),
              color: AppColors.error,
            ),
            _StatCard(
              label: 'Available Rooms',
              value: availableRooms.toString(),
              color: AppColors.secondary,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
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
