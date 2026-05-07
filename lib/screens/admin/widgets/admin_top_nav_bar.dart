import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFF1D1B16)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'VacanSee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D1B16),
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.grey),
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          );
        }

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () => onViewChanged(AdminView.dashboard),
                child: Row(
                  children: [
                    const Text(
                      'VacanSee',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D1B16),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 20,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Nav Links
              _NavButton(
                label: 'Dashboard',
                isActive: currentView == AdminView.dashboard,
                onTap: () => onViewChanged(AdminView.dashboard),
              ),
              _NavButton(
                label: 'All Listings',
                isActive: currentView == AdminView.listings,
                onTap: () => onViewChanged(AdminView.listings),
              ),
              _NavButton(
                label: 'All Bookings',
                isActive: currentView == AdminView.bookings,
                onTap: () => onViewChanged(AdminView.bookings),
              ),
              _NavButton(
                label: 'User Management',
                isActive: currentView == AdminView.users,
                onTap: () => onViewChanged(AdminView.users),
              ),
              _NavButton(
                label: 'Profile',
                isActive: currentView == AdminView.profile,
                onTap: () => onViewChanged(AdminView.profile),
              ),
              const SizedBox(width: 24),
              // Logout Button
              ElevatedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    navigator.popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF1D1B16) : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: 20,
              color: isActive ? const Color(0xFF5287B2) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
