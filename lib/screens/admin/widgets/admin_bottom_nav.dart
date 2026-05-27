import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../admin_dashboard.dart';

class AdminBottomNav extends StatelessWidget {
  final AdminView currentView;
  final Function(AdminView) onViewChanged;

  const AdminBottomNav({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.dashboard_rounded,
                'Dashboard',
                AdminView.dashboard,
              ),
              _buildNavItem(
                Icons.list_alt_rounded,
                'Listings',
                AdminView.listings,
              ),
              _buildNavItem(
                Icons.calendar_month_rounded,
                'Bookings',
                AdminView.bookings,
              ),
              _buildNavItem(Icons.people_rounded, 'Users', AdminView.users),
              _buildNavItem(Icons.person_rounded, 'Profile', AdminView.profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, AdminView view) {
    final isSelected = currentView == view;
    return InkWell(
      onTap: () => onViewChanged(view),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[500],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
