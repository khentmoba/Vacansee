import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

import '../admin_dashboard.dart';

class AdminTopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final AdminView currentView;
  final Function(AdminView) onViewChanged;

  const AdminTopNavBar({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final email = user?.email ?? 'Admin';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'A';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 950;

        if (isMobile) {
          return Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'VacanSee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                // Quick notification icon
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 22),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                // Simple circular avatar for mobile
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final viewIndexes = {
          AdminView.dashboard: 0,
          AdminView.listings: 1,
          AdminView.bookings: 2,
          AdminView.users: 3,
          AdminView.profile: 4,
        };

        final currentIndex = viewIndexes[currentView] ?? 0;

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
            ),
          ),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () => onViewChanged(AdminView.dashboard),
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'VacanSee',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Navigation pill slider selector
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    // Sliding background pill
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        -1.0 + (currentIndex * 2.0 / 4.0),
                        0.0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Nav targets overlay
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavTab(
                          label: 'Dashboard',
                          isActive: currentView == AdminView.dashboard,
                          onTap: () => onViewChanged(AdminView.dashboard),
                        ),
                        _NavTab(
                          label: 'Listings',
                          isActive: currentView == AdminView.listings,
                          onTap: () => onViewChanged(AdminView.listings),
                        ),
                        _NavTab(
                          label: 'Bookings',
                          isActive: currentView == AdminView.bookings,
                          onTap: () => onViewChanged(AdminView.bookings),
                        ),
                        _NavTab(
                          label: 'Users',
                          isActive: currentView == AdminView.users,
                          onTap: () => onViewChanged(AdminView.users),
                        ),
                        _NavTab(
                          label: 'Profile',
                          isActive: currentView == AdminView.profile,
                          onTap: () => onViewChanged(AdminView.profile),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Notification Bell with Indicator
              IconButton(
                hoverColor: Colors.grey[100],
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 24),
                    Positioned(
                      right: 3,
                      top: 3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // User Admin Profile Chip / Dropdown lookalike
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      email.split('@')[0],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          navigator.popUntil((route) => route.isFirst);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _NavTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 38,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? AppColors.textPrimary : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

