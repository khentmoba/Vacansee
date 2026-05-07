import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AdminTopNavBar(
        currentView: _currentView,
        onViewChanged: (view) {
          setState(() => _currentView = view);
          _refreshData();
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF5287B2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'VacanSee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Admin Portal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
                    child: _buildCurrentView(stats, bookingProvider, propertyProvider, adminProvider, authProvider),
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentView = AdminView.dashboard),
          child: Row(
            children: [
              Icon(Icons.arrow_back, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
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
            color: const Color(0xFF9C27B0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(40),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Color(0xFF9C27B0), size: 50),
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
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
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
                        Icons.edit_outlined,
                        color: Color(0xFF9C27B0),
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
                  color: Color(0xFF1D1B16),
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
                fontWeight: FontWeight.w600,
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
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1D1B16),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersView(AdminProvider adminProvider) {
    final users = adminProvider.users;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      children: [
        const Text(
          'User Management',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D1B16),
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
        // Search & Role Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => adminProvider.setSearchQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
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
            fontWeight: FontWeight.w600,
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
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: constraints.maxWidth < 600 ? 2.5 : 2.2,
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
      selectedColor: const Color(0xFF5287B2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBookingsView(BookingProvider bookingProvider) {
    final bookings = bookingProvider.bookings;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      children: [
        const Text(
          'All Bookings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D1B16),
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
              // TODO: Navigate to booking detail
            },
          )),
      ],
    );
  }

  Widget _buildListingsView(PropertyProvider propertyProvider) {
    final properties = propertyProvider.properties;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      children: [
        const Text(
          'All Listings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D1B16),
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
            // TODO: Implement filters dialog
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
            fontWeight: FontWeight.w600,
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
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: constraints.maxWidth < 600 ? 0.75 : 0.85,
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  return AdminPropertyCard(
                    property: properties[index],
                    onTap: () {
                      // TODO: Navigate to property detail/moderation
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D1B16),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete system overview and management',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
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
      childAspectRatio: isMobile ? 1.4 : 1.6,
      children: [
        AdminStatCard(
          title: 'Total Listings',
          value: stats?.totalProperties.toString() ?? '0',
          icon: Icons.home_outlined,
          iconColor: const Color(0xFF5287B2),
          iconBgColor: const Color(0xFFEEF5FB),
        ),
        AdminStatCard(
          title: 'Occupancy Rate',
          value: '${((stats?.occupancyRate ?? 0) * 100).toInt()}%',
          icon: Icons.trending_up,
          iconColor: const Color(0xFF4CAF50),
          iconBgColor: const Color(0xFFE8F5E9),
        ),
        AdminStatCard(
          title: 'Total Users',
          value: stats?.totalUsers.toString() ?? '0',
          icon: Icons.people_outline,
          iconColor: const Color(0xFF9C27B0),
          iconBgColor: const Color(0xFFF3E5F5),
        ),
        AdminStatCard(
          title: 'Total Bookings',
          value: stats?.totalBookings.toString() ?? '0',
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFFFFC107),
          iconBgColor: const Color(0xFFFFF8E1),
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
      childAspectRatio: isMobile ? 4.5 : 3.5,
      children: [
        AdminSolidStatCard(
          title: 'Active Tenants',
          value: stats?.activeTenants.toString() ?? '0',
          icon: Icons.apartment,
          backgroundColor: const Color(0xFF2196F3),
        ),
        AdminSolidStatCard(
          title: 'Property Owners',
          value: stats?.totalOwners.toString() ?? '0',
          icon: Icons.person_add_alt_1_outlined,
          backgroundColor: const Color(0xFF00C853),
        ),
        AdminSolidStatCard(
          title: 'Pending Bookings',
          value: stats?.pendingBookings.toString() ?? '0',
          icon: Icons.access_time,
          backgroundColor: const Color(0xFFE6A23C),
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
            color: Color(0xFF1D1B16),
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            QuickActionCard(
              label: 'Manage Listings',
              icon: Icons.home_work_outlined,
              onTap: () => setState(() => _currentView = AdminView.listings),
            ),
            QuickActionCard(
              label: 'View Bookings',
              icon: Icons.calendar_month_outlined,
              onTap: () => setState(() => _currentView = AdminView.bookings),
            ),
            QuickActionCard(
              label: 'User Management',
              icon: Icons.group_outlined,
              onTap: () => setState(() => _currentView = AdminView.users),
            ),
            QuickActionCard(
              label: 'Admin Profile',
              icon: Icons.person_outline,
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
                color: Color(0xFF1D1B16),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentView = AdminView.bookings),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
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
                  separatorBuilder: (context, index) => Divider(color: Colors.grey[50]!),
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
      leading: Icon(icon, color: isSelected ? const Color(0xFF5287B2) : Colors.grey[600]),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF5287B2) : Colors.grey[800],
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
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
    return CheckboxListTile(
      value: isEnabled,
      onChanged: null, // Read-only in this view
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1D1B16),
        ),
      ),
      activeColor: const Color(0xFF9C27B0),
      checkColor: Colors.white,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
