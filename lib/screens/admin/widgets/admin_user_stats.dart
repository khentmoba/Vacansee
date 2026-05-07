import 'package:flutter/material.dart';

class AdminUserStats extends StatelessWidget {
  final int total;
  final int tenants;
  final int owners;
  final int admins;

  const AdminUserStats({
    super.key,
    required this.total,
    required this.tenants,
    required this.owners,
    required this.admins,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _UserStatCard(
            label: 'Total Users',
            value: total.toString(),
            icon: Icons.person_outline,
            iconColor: const Color(0xFF5287B2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _UserStatCard(
            label: 'Tenants',
            value: tenants.toString(),
            icon: Icons.person_search_outlined,
            iconColor: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _UserStatCard(
            label: 'Owners',
            value: owners.toString(),
            icon: Icons.home_work_outlined,
            iconColor: const Color(0xFF0288D1),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _UserStatCard(
            label: 'Admins',
            value: admins.toString(),
            icon: Icons.admin_panel_settings_outlined,
            iconColor: const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }
}

class _UserStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _UserStatCard({
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
            color: Colors.black.withOpacity(0.05),
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
              color: iconColor.withOpacity(0.1),
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
