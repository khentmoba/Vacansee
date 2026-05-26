import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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
            _UserStatCard(
              label: 'Total Users',
              value: total.toString(),
              icon: Icons.person_outline,
              iconColor: AppColors.primary,
            ),
            _UserStatCard(
              label: 'Tenants',
              value: tenants.toString(),
              icon: Icons.person_search_outlined,
              iconColor: AppColors.success,
            ),
            _UserStatCard(
              label: 'Owners',
              value: owners.toString(),
              icon: Icons.home_work_outlined,
              iconColor: AppColors.secondary,
            ),
            _UserStatCard(
              label: 'Admins',
              value: admins.toString(),
              icon: Icons.admin_panel_settings_outlined,
              iconColor: const Color(0xFF9C27B0), // admin color can stay purple or we can use another shade
            ),
          ],
        );
      },
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
              color: AppColors.textPrimary,
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
