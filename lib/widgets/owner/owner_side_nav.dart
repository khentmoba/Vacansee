import 'package:flutter/material.dart';

class OwnerSideNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final VoidCallback onLogout;
  final int pendingBookingsCount;

  const OwnerSideNav({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onLogout,
    this.pendingBookingsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1A2B4B), // Deep navy from guidelines
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header/Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5287B2).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.holiday_village_rounded,
                        color: Color(0xFF5287B2),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'VacanSee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 4),
                  child: Text(
                    'OWNER PORTAL',
                    style: TextStyle(
                      color: const Color(0xFF5287B2).withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2C3E60), height: 1),
          const SizedBox(height: 16),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, 'Dashboard', Icons.dashboard_rounded),
                _buildNavItem(1, 'My Listings', Icons.home_work_rounded),
                _buildNavItem(
                  2,
                  'Booking Requests',
                  Icons.book_online_rounded,
                  badgeCount: pendingBookingsCount,
                ),
                _buildNavItem(3, 'Messages', Icons.mail_rounded),
                _buildNavItem(4, 'Performance', Icons.analytics_rounded),
                _buildNavItem(5, 'Payments', Icons.payments_rounded),
                _buildNavItem(6, 'Profile/Settings', Icons.person_rounded),
              ],
            ),
          ),

          // Footer
          const Divider(color: Color(0xFF2C3E60), height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildNavItem(7, 'Help & Support', Icons.help_outline_rounded, isUtility: true),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String title,
    IconData icon, {
    int badgeCount = 0,
    bool isUtility = false,
  }) {
    final isSelected = selectedIndex == index;
    final activeColor = const Color(0xFF5287B2);
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: MouseRegion(
            onEnter: (_) => setStateBuilder(() => isHovered = true),
            onExit: (_) => setStateBuilder(() => isHovered = false),
            child: InkWell(
              onTap: () => onIndexChanged(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.15)
                      : isHovered 
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border(
                          left: BorderSide(color: activeColor, width: 4),
                        )
                      : Border(
                          left: BorderSide(
                            color: isHovered ? activeColor.withValues(alpha: 0.5) : Colors.transparent, 
                            width: 4,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected 
                          ? activeColor 
                          : isHovered 
                              ? Colors.white 
                              : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : isHovered 
                                  ? Colors.white.withValues(alpha: 0.9) 
                                  : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (badgeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
