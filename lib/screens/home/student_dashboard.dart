import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../booking/my_bookings_screen.dart';
import '../property/property_list_screen.dart';
import '../rating/ratings_screen.dart';
import '../profile/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final int initialIndex;
  const StudentDashboard({super.key, this.initialIndex = 0});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late int _selectedIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screens = [
      const _HomeTab(),
      const _MyBookingsTab(),
      const RatingsScreen(),
      _ProfileTab(onBack: () => setState(() => _selectedIndex = 0)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          extendBody: !isDesktop,
          backgroundColor: const Color(0xFFF8FBFD),
          appBar: isDesktop
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: _TopNavBar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                )
              : null,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
          bottomNavigationBar: !isDesktop
              ? SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1B16).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavItem(Icons.home_rounded, 'Home', 0),
                          _buildNavItem(
                            Icons.calendar_today_rounded,
                            'Bookings',
                            1,
                          ),
                          _buildNavItem(Icons.star_rounded, 'Ratings', 2),
                          _buildNavItem(Icons.person_rounded, 'Profile', 3),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return _AnimatedNavItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _TopNavBar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Container(
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
                'Tenant Dashboard',
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
          _buildTopNavItem('Home', 0),
          _buildTopNavItem('My Bookings', 1),
          _buildTopNavItem('Ratings', 2),
          _buildTopNavItem('Profile', 3),
          const SizedBox(width: 24),
          // Logout Button
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authProvider.signOut();
              if (context.mounted) {
                navigator.popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5287B2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.logout_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavItem(String label, int index) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
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
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: 20,
              color: isSelected ? const Color(0xFF5287B2) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool isHovered = false;

  Color get backgroundColor {
    if (widget.isSelected) return const Color(0xFF5287B2);
    if (isHovered) return const Color(0xFF5287B2).withValues(alpha: 0.15);
    return Colors.transparent;
  }

  Color get iconColor {
    if (widget.isSelected) return Colors.white;
    if (isHovered) return const Color(0xFF5287B2);
    return Colors.grey[500]!;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 20 : 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: iconColor, size: 24),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return const PropertyListScreen();
  }
}

class _MyBookingsTab extends StatelessWidget {
  const _MyBookingsTab();

  @override
  Widget build(BuildContext context) {
    return const MyBookingsScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback onBack;
  const _ProfileTab({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: isDesktop ? 40 : 20,
            right: isDesktop ? 40 : 20,
            top: 32,
            bottom: isDesktop ? 32 : 140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Back Button
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Dashboard'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              textStyle: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 24),

          // Main Profile Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5287B2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: Color(0xFF5287B2),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Student Name',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tenant Account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Personal Information Section
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1B16),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF5287B2).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Color(0xFF5287B2),
                                size: 20,
                              ),
                              tooltip: 'Edit Profile',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Fields Grid
                      if (isDesktop) ...[
                        Row(
                          children: [
                            Expanded(child: _buildProfileField('First Name', user?.firstName ?? 'First Name')),
                            const SizedBox(width: 24),
                            Expanded(child: _buildProfileField('Last Name', user?.lastName ?? 'Last Name')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildProfileField('Gender', user?.gender?.toUpperCase() ?? 'Not Set', icon: Icons.people_outline)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildProfileField('Phone Number', user?.phoneNumber ?? 'Phone', icon: Icons.phone_outlined)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildProfileField('Email Address', user?.email ?? 'Email', icon: Icons.email_outlined)),
                            const SizedBox(width: 24),
                            const Spacer(), // Keep it two-column aligned
                          ],
                        ),
                      ] else ...[
                        _buildProfileField('First Name', user?.firstName ?? 'First Name'),
                        const SizedBox(height: 24),
                        _buildProfileField('Last Name', user?.lastName ?? 'Last Name'),
                        const SizedBox(height: 24),
                        _buildProfileField('Gender', user?.gender?.toUpperCase() ?? 'Not Set', icon: Icons.people_outline),
                        const SizedBox(height: 24),
                        _buildProfileField('Phone Number', user?.phoneNumber ?? 'Phone', icon: Icons.phone_outlined),
                        const SizedBox(height: 24),
                        _buildProfileField('Email Address', user?.email ?? 'Email', icon: Icons.email_outlined),
                      ],
                      const SizedBox(height: 24),
                      _buildProfileField('Address', user?.address ?? 'Your Address'),

                      const SizedBox(height: 48),

                      // Emergency Contact Section
                      const Text(
                        'Emergency Contact',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B16),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          children: [
                            Expanded(child: _buildProfileField('Contact Name', user?.emergencyContactName ?? 'Emergency Contact Name')),
                            const SizedBox(width: 24),
                            Expanded(child: _buildProfileField('Contact Number', user?.emergencyContactPhone ?? 'Emergency Contact Number')),
                          ],
                        )
                      else ...[
                        _buildProfileField('Contact Name', user?.emergencyContactName ?? 'Emergency Contact Name'),
                        const SizedBox(height: 24),
                        _buildProfileField('Contact Number', user?.emergencyContactPhone ?? 'Emergency Contact Number'),
                      ],
                      
                      const SizedBox(height: 48),
                      // Sign Out Button (Optional, keeping it for utility)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => authProvider.signOut(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1D1B16),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}
