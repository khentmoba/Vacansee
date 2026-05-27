import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
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
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.holiday_village_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'VacanSee',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.border,
                ),
                const SizedBox(width: 10),
                Text(
                  'Owner Dashboard',
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Nav Items
            _TopNavItem(
              label: 'Dashboard',
              isSelected: currentRoute == 'Dashboard',
              onTap: () {
                if (currentRoute != 'Dashboard') {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
            _TopNavItem(
              label: 'Booking Requests',
              isSelected: currentRoute == 'Booking Requests',
              onTap: () {
                if (currentRoute != 'Booking Requests') {
                  Navigator.push(
                    context,
                    FadePageRoute(child: const OwnerBookingsScreen()),
                  );
                }
              },
            ),
            _TopNavItem(
              label: 'Profile',
              isSelected: currentRoute == 'Profile',
              onTap: () {
                if (currentRoute != 'Profile') {
                  Navigator.push(
                    context,
                    FadePageRoute(child: const OwnerProfileScreen()),
                  );
                }
              },
            ),
            const SizedBox(width: 16),
            // Logout Button
            OutlinedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await authProvider.signOut();
                if (context.mounted) {
                  navigator.popUntil((route) => route.isFirst);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopNavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TopNavItem> createState() => _TopNavItemState();
}

class _TopNavItemState extends State<_TopNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected
                    ? AppColors.primary
                    : _isHovered
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              color: widget.isSelected
                  ? AppColors.textPrimary
                  : _isHovered
                      ? AppColors.primary
                      : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
