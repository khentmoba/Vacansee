import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/owner/owner_bookings_screen.dart';
import '../../screens/owner/owner_profile_screen.dart';
import '../../core/utils/fade_page_route.dart';

class OwnerTopNavBar extends StatelessWidget {
  final String currentRoute;
  const OwnerTopNavBar({super.key, this.currentRoute = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Hero(
      tag: 'owner_nav_bar',
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return Material(
          color: Colors.transparent,
          child: toHeroContext.widget,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo
              Row(
                children: [
                  const Text(
                    'VacanSee',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Owner Dashboard',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Nav Items
              _buildTopNavItem(context, 'Dashboard', currentRoute == 'Dashboard', onTap: () {
                if (currentRoute != 'Dashboard') {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }),
              _buildTopNavItem(context, 'Booking Requests', currentRoute == 'Booking Requests', onTap: () {
                if (currentRoute != 'Booking Requests') {
                  Navigator.push(
                    context,
                    FadePageRoute(child: const OwnerBookingsScreen()),
                  );
                }
              }),
              _buildTopNavItem(context, 'Profile', currentRoute == 'Profile', onTap: () {
                if (currentRoute != 'Profile') {
                  Navigator.push(
                    context,
                    FadePageRoute(child: const OwnerProfileScreen()),
                  );
                }
              }),
              const SizedBox(width: 24),
              // Logout Button
              ElevatedButton.icon(
                onPressed: () => authProvider.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavItem(BuildContext context, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 80,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF1D1B16) : Colors.grey[600],
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: const Color(0xFF5287B2),
              ),
          ],
        ),
      ),
    );
  }
}
