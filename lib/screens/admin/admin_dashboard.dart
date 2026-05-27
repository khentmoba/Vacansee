import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_top_nav_bar.dart';
import 'widgets/dashboard_stat_cards.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/recent_booking_row.dart';
import 'widgets/admin_listings_stats.dart';
import 'widgets/admin_search_bar.dart';
import 'widgets/admin_property_card.dart';
import 'widgets/admin_booking_stats.dart';
import 'widgets/admin_booking_filter_bar.dart';
import 'widgets/admin_booking_card.dart';
import 'widgets/admin_user_stats.dart';
import 'widgets/admin_user_card.dart';

import '../../models/admin_stats_model.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../profile/profile_screen.dart';

enum AdminView { dashboard, listings, bookings, users, profile }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminView _currentView = AdminView.dashboard;
  BookingStatus? _bookingStatusFilter;
  UserRole? _userRoleFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final adminProvider = context.read<AdminProvider>();
    final propertyProvider = context.read<PropertyProvider>();
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    adminProvider.loadStats();
    
    if (_currentView == AdminView.listings) {
      propertyProvider.loadAdminProperties();
    } else {
      propertyProvider.loadProperties();
    }
    
    if (_currentView == AdminView.bookings) {
      bookingProvider.loadAdminBookings(statusFilter: _bookingStatusFilter);
    } else {
      bookingProvider.loadRecentBookings(limit: 4);
    }

    if (_currentView == AdminView.users) {
      adminProvider.loadAllUsers();
    }
    
    authProvider.loadPendingOwners();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final stats = adminProvider.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminTopNavBar(
        currentView: _currentView,
        onViewChanged: (view) {
          setState(() => _currentView = view);
          _refreshData();
        },
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'VacanSee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin Portal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard_rounded, 'Dashboard', AdminView.dashboard),
            _buildDrawerItem(Icons.list_alt_rounded, 'All Listings', AdminView.listings),
            _buildDrawerItem(Icons.calendar_month_rounded, 'All Bookings', AdminView.bookings),
            _buildDrawerItem(Icons.people_rounded, 'User Management', AdminView.users),
            _buildDrawerItem(Icons.person_rounded, 'Profile', AdminView.profile),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Logout', 
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final navigator = Navigator.of(context);
                await authProvider.signOut();
                if (mounted) {
                  navigator.popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
      body: adminProvider.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey<AdminView>(_currentView),
                      child: _buildCurrentView(stats, bookingProvider, propertyProvider, adminProvider, authProvider),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentView(
    AdminStatsModel? stats,
    BookingProvider bookingProvider,
    PropertyProvider propertyProvider,
    AdminProvider adminProvider,
    AuthProvider authProvider,
  ) {
    switch (_currentView) {
      case AdminView.dashboard:
        final isMobile = MediaQuery.of(context).size.width < 800;
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: isMobile ? 24 : 40,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsGrid(stats),
            const SizedBox(height: 24),
            _buildSolidStatsGrid(stats),
            const SizedBox(height: 48),
            _buildBottomGrids(bookingProvider),
          ],
        );
      case AdminView.listings:
        return _buildListingsView(propertyProvider);
      case AdminView.bookings:
        return _buildBookingsView(bookingProvider);
      case AdminView.users:
        return _buildUsersView(adminProvider);
      case AdminView.profile:
        return _buildProfileView(authProvider);
    }
  }

  Widget _buildProfileView(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentView = AdminView.dashboard),
          child: Row(
            children: [
              Icon(Icons.arrow_back_rounded, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Profile Header Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          child: isMobile
              ? Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      user.displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 50),
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administrator',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          'Super Admin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 40),
        // Admin Information Section
        Container(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
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
                        color: AppColors.primary,
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
              if (isMobile) ...[
                _buildProfileField('First Name', user.firstName ?? user.displayName.split(' ').first),
                const SizedBox(height: 24),
                _buildProfileField('Last Name', user.lastName ?? (user.displayName.split(' ').length > 1 ? user.displayName.split(' ')[1] : '')),
                const SizedBox(height: 24),
                _buildProfileField('Email Address', user.email, icon: Icons.email_outlined),
                const SizedBox(height: 24),
                _buildProfileField('Phone Number', user.phoneNumber ?? 'Not provided', icon: Icons.phone_outlined),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _buildProfileField('First Name', user.firstName ?? user.displayName.split(' ').first)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProfileField('Last Name', user.lastName ?? (user.displayName.split(' ').length > 1 ? user.displayName.split(' ')[1] : ''))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildProfileField('Email Address', user.email, icon: Icons.email_outlined)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProfileField('Phone Number', user.phoneNumber ?? 'Not provided', icon: Icons.phone_outlined)),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              _buildProfileField('Admin Level', 'Super Admin', icon: Icons.shield_outlined),
              const SizedBox(height: 8),
              Text(
                'Admin level cannot be changed through this interface',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 48),
              const Text(
                'System Permissions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildPermissionSection('Core Management', [
                _PermissionItem(label: 'Manage All Listings', isEnabled: true),
                _PermissionItem(label: 'View All Bookings', isEnabled: true),
              ]),
              const SizedBox(height: 24),
              _buildPermissionSection('Administrative', [
                _PermissionItem(label: 'User Management', isEnabled: true),
                _PermissionItem(label: 'System Settings', isEnabled: true),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersView(AdminProvider adminProvider) {
    final users = adminProvider.users;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      children: [
        Text(
          'User Management',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage all users registered on the platform',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        AdminUserStats(
          total: adminProvider.totalUsersCount,
          tenants: adminProvider.tenantsCount,
          owners: adminProvider.ownersCount,
          admins: adminProvider.adminsCount,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => adminProvider.setSearchQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRoleFilterChip(null, 'All', adminProvider),
                        const SizedBox(width: 8),
                        _buildRoleFilterChip(UserRole.student, 'Tenants', adminProvider),
                        const SizedBox(width: 8),
                        _buildRoleFilterChip(UserRole.owner, 'Owners', adminProvider),
                        const SizedBox(width: 8),
                        _buildRoleFilterChip(UserRole.admin, 'Admins', adminProvider),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => adminProvider.setSearchQuery(v),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildRoleFilterChip(null, 'All', adminProvider),
                  const SizedBox(width: 8),
                  _buildRoleFilterChip(UserRole.student, 'Tenants', adminProvider),
                  const SizedBox(width: 8),
                  _buildRoleFilterChip(UserRole.owner, 'Owners', adminProvider),
                  const SizedBox(width: 8),
                  _buildRoleFilterChip(UserRole.admin, 'Admins', adminProvider),
                ],
              ),
        ),
        const SizedBox(height: 32),
        Text(
          'Showing ${users.length} of ${adminProvider.totalUsersCount} users',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        if (adminProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (users.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1200 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 16 : 24,
                  mainAxisSpacing: isMobile ? 16 : 24,
                  childAspectRatio: isMobile ? 1.4 : (constraints.maxWidth < 1200 ? 2.0 : 2.2),
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return AdminUserCard(
                    user: users[index],
                    onViewDetails: () {},
                    onEdit: () {},
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildRoleFilterChip(UserRole? role, String label, AdminProvider adminProvider) {
    final isSelected = _userRoleFilter == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _userRoleFilter = role);
        adminProvider.setRoleFilter(role);
      },
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(color: Colors.transparent),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBookingsView(BookingProvider bookingProvider) {
    final bookings = bookingProvider.bookings;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      children: [
        Text(
          'All Bookings',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor and manage all booking requests across the platform',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        AdminBookingStats(
          total: bookingProvider.totalBookingCount,
          pending: bookingProvider.pendingBookingCount,
          approved: bookingProvider.approvedBookingCount,
          rejected: bookingProvider.rejectedBookingCount,
        ),
        const SizedBox(height: 24),
        AdminBookingFilterBar(
          selectedStatus: _bookingStatusFilter,
          onStatusChanged: (status) {
            setState(() => _bookingStatusFilter = status);
            _refreshData();
          },
          totalCount: bookingProvider.totalBookingCount,
          pendingCount: bookingProvider.pendingBookingCount,
          approvedCount: bookingProvider.approvedBookingCount,
          rejectedCount: bookingProvider.rejectedBookingCount,
        ),
        const SizedBox(height: 32),
        if (bookingProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (bookings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          ...bookings.map((booking) => AdminBookingCard(
            booking: booking,
            onTap: () {
              // Navigate to booking detail
            },
          )),
      ],
    );
  }

  Widget _buildListingsView(PropertyProvider propertyProvider) {
    final properties = propertyProvider.properties;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      children: [
        Text(
          'All Listings',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage all boarding house listings across the platform',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        AdminSearchBar(
          onSearch: (query) {
            propertyProvider.setSearchQuery(query);
            propertyProvider.loadAdminProperties();
          },
          onFilterTap: () {
            // Implement filters dialog
          },
        ),
        const SizedBox(height: 24),
        AdminListingStats(
          total: propertyProvider.totalListings,
          available: propertyProvider.availableListings,
          full: propertyProvider.fullListings,
          availableRooms: propertyProvider.totalAvailableRoomCount,
        ),
        const SizedBox(height: 32),
        Text(
          'Showing ${properties.length} of ${propertyProvider.totalListings} listings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        if (propertyProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (properties.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No listings found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1200 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 16 : 24,
                  mainAxisSpacing: isMobile ? 16 : 24,
                  childAspectRatio: isMobile ? 0.7 : (constraints.maxWidth < 1200 ? 0.8 : 0.85),
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  return AdminPropertyCard(
                    property: properties[index],
                    onTap: () {
                      // Navigate to property detail/moderation
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = formatter.format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(dynamic stats) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: isMobile ? 16 : 24,
      mainAxisSpacing: isMobile ? 16 : 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 1.2 : 1.4,
      children: [
        AdminStatCard(
          title: 'Total Listings',
          value: stats?.totalProperties.toString() ?? '0',
          icon: Icons.home_outlined,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primary.withValues(alpha: 0.08),
          trendPercent: 4.8,
          isPositiveTrend: true,
        ),
        AdminStatCard(
          title: 'Occupancy Rate',
          value: '${((stats?.occupancyRate ?? 0) * 100).toInt()}%',
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.success,
          iconBgColor: AppColors.success.withValues(alpha: 0.08),
          trendPercent: 2.1,
          isPositiveTrend: true,
        ),
        AdminStatCard(
          title: 'Total Users',
          value: stats?.totalUsers.toString() ?? '0',
          icon: Icons.people_outline_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          trendPercent: 1.2,
          isPositiveTrend: true,
        ),
        AdminStatCard(
          title: 'Total Bookings',
          value: stats?.totalBookings.toString() ?? '0',
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFFF59E0B),
          iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
          trendPercent: 0.4,
          isPositiveTrend: false,
        ),
      ],
    );
  }

  Widget _buildSolidStatsGrid(dynamic stats) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      crossAxisSpacing: isMobile ? 16 : 24,
      mainAxisSpacing: isMobile ? 16 : 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 4.5 : 3.2,
      children: [
        AdminSolidStatCard(
          title: 'Active Tenants',
          value: stats?.activeTenants.toString() ?? '0',
          icon: Icons.apartment_rounded,
          backgroundColor: AppColors.primary,
        ),
        AdminSolidStatCard(
          title: 'Property Owners',
          value: stats?.totalOwners.toString() ?? '0',
          icon: Icons.person_add_alt_1_outlined,
          backgroundColor: AppColors.success,
        ),
        AdminSolidStatCard(
          title: 'Pending Bookings',
          value: stats?.pendingBookings.toString() ?? '0',
          icon: Icons.access_time_rounded,
          backgroundColor: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildBottomGrids(BookingProvider bookingProvider) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(),
          const SizedBox(height: 40),
          _buildRecentBookings(bookingProvider),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Actions
        Expanded(
          flex: 4,
          child: _buildQuickActions(),
        ),
        const SizedBox(width: 48),
        // Recent Bookings
        Expanded(
          flex: 5,
          child: _buildRecentBookings(bookingProvider),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            QuickActionCard(
              label: 'Manage Listings',
              subLabel: 'Approve & view listings',
              icon: Icons.home_work_outlined,
              accentColor: AppColors.primary,
              onTap: () => setState(() => _currentView = AdminView.listings),
            ),
            QuickActionCard(
              label: 'View Bookings',
              subLabel: 'Track request stats',
              icon: Icons.calendar_month_outlined,
              accentColor: const Color(0xFFF59E0B),
              onTap: () => setState(() => _currentView = AdminView.bookings),
            ),
            QuickActionCard(
              label: 'User Management',
              subLabel: 'Review owner verifications',
              icon: Icons.group_outlined,
              accentColor: const Color(0xFF8B5CF6),
              onTap: () => setState(() => _currentView = AdminView.users),
            ),
            QuickActionCard(
              label: 'Admin Profile',
              subLabel: 'System permissions & settings',
              icon: Icons.person_outline,
              accentColor: AppColors.secondary,
              onTap: () => setState(() => _currentView = AdminView.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookings(BookingProvider bookingProvider) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentView = AdminView.bookings),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (bookingProvider.bookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No recent bookings')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookingProvider.bookings.length > 4 ? 4 : bookingProvider.bookings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return RecentBookingRow(booking: bookingProvider.bookings[index]);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, AdminView view) {
    final isSelected = _currentView == view;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[600]),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _currentView = view);
        _refreshData();
        Navigator.pop(context); // Close drawer
      },
    );
  }

  Widget _buildPermissionSection(String title, List<_PermissionItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
          ),
          child: Column(
            children: items.map((item) => item).toList(),
          ),
        ),
      ],
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final String label;
  final bool isEnabled;

  const _PermissionItem({
    required this.label,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: isEnabled,
      onChanged: null, // Read-only in this view
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      activeColor: AppColors.primary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}

