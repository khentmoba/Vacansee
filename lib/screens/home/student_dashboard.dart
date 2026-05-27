import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
          backgroundColor: AppColors.background,
          appBar: isDesktop
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: _TopNavBar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                )
              : null,
          body: AnimatedSwitcher(
            duration: AppDurations.medium,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.98,
                    end: 1.0,
                  ).animate(animation),
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
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              ...AppShadows.depth2,
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
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
    final user = authProvider.user;
    final displayName = user?.displayName;
    final ownerInit = (displayName != null && displayName.isNotEmpty)
        ? displayName[0].toUpperCase()
        : 'S';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: const Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Logo
              _LogoButton(onTap: () => onItemSelected(0)),
              const Spacer(),
              // Center Nav Tabs
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopNavItem('Home', 0),
                  _buildTopNavItem('Bookings', 1),
                  _buildTopNavItem('Ratings', 2),
                  _buildTopNavItem('Profile', 3),
                ],
              ),
              const Spacer(),
              // Right Controls
              Row(
                children: [
                  // Profile Menu
                  PopupMenuButton<String>(
                    offset: const Offset(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        width: 0.8,
                      ),
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        final navigator = Navigator.of(context);
                        await authProvider.signOut();
                        navigator.popUntil((route) => route.isFirst);
                      } else if (value == 'bookings') {
                        onItemSelected(1);
                      } else if (value == 'ratings') {
                        onItemSelected(2);
                      } else if (value == 'profile') {
                        onItemSelected(3);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text('My Profile', style: GoogleFonts.workSans(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'bookings',
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Text('My Bookings', style: GoogleFonts.workSans()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'ratings',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline_rounded, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Text('My Ratings', style: GoogleFonts.workSans()),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                            const SizedBox(width: 10),
                            Text('Log Out', style: GoogleFonts.workSans(color: AppColors.error, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        color: AppColors.secondaryContainer,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_rounded, size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.avatarRing,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Text(
                                ownerInit,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavItem(String label, int index) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 72,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: AppDurations.fast,
              curve: Curves.easeOutCubic,
              height: 2.5,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isSelected ? AppGradients.primaryHorizontal : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoButton({required this.onTap});

  @override
  State<_LogoButton> createState() => _LogoButtonState();
}

class _LogoButtonState extends State<_LogoButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            boxShadow: _isHovered ? AppShadows.glow : [],
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppGradients.primaryGradient.createShader(bounds),
                child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => AppGradients.primaryGradient.createShader(bounds),
                child: Text(
                  'VacanSee',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ],
          ),
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

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _bounceAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
      );
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Color get backgroundColor {
    if (widget.isSelected) return Colors.transparent;
    if (isHovered) return AppColors.primary.withValues(alpha: 0.08);
    return Colors.transparent;
  }

  Color get iconColor {
    if (widget.isSelected) return AppColors.primary;
    if (isHovered) return AppColors.primary;
    return AppColors.textMuted;
  }

  Color get labelColor {
    if (widget.isSelected) return AppColors.primary;
    if (isHovered) return AppColors.primary;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _bounceAnimation,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSelected ? 20 : 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: widget.isSelected
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                      : const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: widget.isSelected ? AppGradients.primaryGradient : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: widget.isSelected ? Colors.white : iconColor, size: 22),
                      if (widget.isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          widget.label,
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!widget.isSelected) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: GoogleFonts.workSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                ],
              ],
            ),
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
    final initials = user != null
        ? '${(user.firstName ?? '').isNotEmpty ? user.firstName![0] : ''}${(user.lastName ?? '').isNotEmpty ? user.lastName![0] : ''}'.toUpperCase()
        : 'S';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: isDesktop ? 40 : 20,
            right: isDesktop ? 40 : 20,
            top: AppSpacing.xl,
            bottom: isDesktop ? AppSpacing.xl : 140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Back to Dashboard',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.w500),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Main Profile Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.depth2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner — Blue gradient with wave clip styling
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Animated gradient ring avatar
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.avatarRing,
                            ),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.white,
                              child: Text(
                                initials,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'Student Name',
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.primaryGradient,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Personal Information',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
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
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  tooltip: 'Edit Profile',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Fields Grid
                          if (isDesktop) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProfileField(
                                    'First Name',
                                    user?.firstName ?? 'First Name',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: _buildProfileField(
                                    'Last Name',
                                    user?.lastName ?? 'Last Name',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProfileField(
                                    'Gender',
                                    user?.gender?.toUpperCase() ?? 'Not Set',
                                    icon: Icons.people_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: _buildProfileField(
                                    'Phone Number',
                                    user?.phoneNumber ?? 'Phone',
                                    icon: Icons.phone_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProfileField(
                                    'Email Address',
                                    user?.email ?? 'Email',
                                    icon: Icons.email_outlined,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                const Spacer(),
                              ],
                            ),
                          ] else ...[
                            _buildProfileField(
                              'First Name',
                              user?.firstName ?? 'First Name',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildProfileField(
                              'Last Name',
                              user?.lastName ?? 'Last Name',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildProfileField(
                              'Gender',
                              user?.gender?.toUpperCase() ?? 'Not Set',
                              icon: Icons.people_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildProfileField(
                              'Phone Number',
                              user?.phoneNumber ?? 'Phone',
                              icon: Icons.phone_outlined,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildProfileField(
                              'Email Address',
                              user?.email ?? 'Email',
                              icon: Icons.email_outlined,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          _buildProfileField(
                            'Address',
                            user?.address ?? 'Your Address',
                            icon: Icons.location_on_outlined,
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Emergency Contact Section
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.dangerGradient,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Emergency Contact',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProfileField(
                                    'Contact Name',
                                    user?.emergencyContactName ??
                                        'Emergency Contact Name',
                                    icon: Icons.contact_page_outlined,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: _buildProfileField(
                                    'Contact Number',
                                    user?.emergencyContactPhone ??
                                        'Emergency Contact Number',
                                    icon: Icons.phone_callback_outlined,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildProfileField(
                              'Contact Name',
                              user?.emergencyContactName ??
                                  'Emergency Contact Name',
                              icon: Icons.contact_page_outlined,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildProfileField(
                              'Contact Number',
                              user?.emergencyContactPhone ??
                                  'Emergency Contact Number',
                              icon: Icons.phone_callback_outlined,
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xxl),
                          // Sign Out Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => authProvider.signOut(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withValues(alpha: 0.5),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sign Out',
                                    style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.w600,
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
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
