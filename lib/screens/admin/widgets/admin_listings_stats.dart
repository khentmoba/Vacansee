import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Listings',
            value: total.toString(),
            color: const Color(0xFF5287B2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _StatCard(
            label: 'Available',
            value: available.toString(),
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _StatCard(
            label: 'Full',
            value: full.toString(),
            color: const Color(0xFFF44336),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _StatCard(
            label: 'Available Rooms',
            value: availableRooms.toString(),
            color: const Color(0xFF9C27B0),
          ),
        ),
      ],
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
