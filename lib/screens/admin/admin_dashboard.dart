import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/room_provider.dart';
import 'widgets/admin_top_nav_bar.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_kpi_panel.dart';
import 'widgets/dashboard_stat_cards.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/recent_booking_row.dart';
import 'widgets/admin_search_bar.dart';
import 'widgets/admin_property_card.dart';
import 'widgets/admin_booking_filter_bar.dart';
import 'widgets/admin_booking_card.dart';
import 'widgets/admin_user_card.dart';
import '../../models/admin_stats_model.dart';
import '../../models/user_model.dart';
import '../../models/property_model.dart';
import '../profile/profile_screen.dart';
import 'admin_user_detail_screen.dart';
import 'admin_property_detail_screen.dart';

enum AdminView { dashboard, listings, bookings, users, profile }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminView _currentView = AdminView.dashboard;
  UserRole? _userRoleFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _subscribeToRealTime();
    });
  }

  void _subscribeToRealTime() {
    final propertyProvider = context.read<PropertyProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final adminProvider = context.read<AdminProvider>();
    propertyProvider.subscribeToAdminProperties();
    bookingProvider.subscribeToAdminBookings();
    adminProvider.subscribeToStats();
    adminProvider.subscribeToAllUsers();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    final adminProvider = context.read<AdminProvider>();
    final propertyProvider = context.read<PropertyProvider>();
    final bookingProvider = context.read<BookingProvider>();

    adminProvider.loadStats();
    if (_currentView == AdminView.listings) {
      propertyProvider.loadAdminProperties();
    } else {
      propertyProvider.loadProperties();
    }
    if (_currentView == AdminView.bookings) {
      bookingProvider.loadAdminBookings();
    } else {
      bookingProvider.loadRecentBookings(limit: 4);
    }
    if (_currentView == AdminView.users) {
      adminProvider.loadAllUsers();
    }
  }

  void _onViewChanged(AdminView view) {
    setState(() => _currentView = view);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final stats = adminProvider.stats;
    final isMobile = MediaQuery.of(context).size.width < 900;

    Widget mainContent = adminProvider.isLoading && stats == null
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refreshData,
            child: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: KeyedSubtree(
                key: ValueKey<AdminView>(_currentView),
                child: _buildCurrentView(stats, bookingProvider, propertyProvider, adminProvider, authProvider),
              ),
            ),
          );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminTopNavBar(currentView: _currentView, onViewChanged: _onViewChanged, isMobile: true),
        drawer: Drawer(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
          child: AdminSidebar(currentView: _currentView, onViewChanged: _onViewChanged, inDrawer: true),
        ),
        bottomNavigationBar: AdminBottomNav(currentView: _currentView, onViewChanged: _onViewChanged),
        body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200), child: mainContent)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AdminSidebar(currentView: _currentView, onViewChanged: _onViewChanged),
          Expanded(
            child: Column(
              children: [
                AdminTopNavBar(currentView: _currentView, onViewChanged: _onViewChanged, isMobile: false),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200), child: mainContent),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 24 : 40),
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsGrid(stats),
            const SizedBox(height: 24),
            _buildSolidStatsGrid(stats),
            const SizedBox(height: 32),
            _buildOccupancyChart(propertyProvider),
            const SizedBox(height: 40),
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

  Widget _buildOccupancyChart(PropertyProvider propertyProvider) {
    final totalOccupied = propertyProvider.totalOccupiedRooms;
    final totalAvailable = propertyProvider.totalAvailableRooms;
    final totalRooms = totalOccupied + totalAvailable;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.md],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Occupancy Overview',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          if (totalRooms == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No room data available', style: GoogleFonts.workSans(color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: totalOccupied.toDouble(),
                            color: AppColors.primary,
                            title: '${(totalOccupied / totalRooms * 100).toStringAsFixed(0)}%',
                            titleStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: totalAvailable.toDouble(),
                            color: AppColors.success,
                            title: '${(totalAvailable / totalRooms * 100).toStringAsFixed(0)}%',
                            titleStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            radius: 50,
                          ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                      ),
                      duration: AppDurations.slow,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(AppColors.primary, 'Occupied', totalOccupied.toString()),
                    const SizedBox(height: 16),
                    _legendItem(AppColors.success, 'Vacant', totalAvailable.toString()),
                    const SizedBox(height: 16),
                    _legendItem(AppColors.textMuted, 'Total Rooms', totalRooms.toString()),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.workSans(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildProfileView(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final isMobile = MediaQuery.of(context).size.width < 800;
    final initials = user.displayName.isNotEmpty
        ? user.displayName.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').take(2).join().toUpperCase()
        : 'A';

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 24 : 40),
      children: [
        // Profile Header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [AppShadows.xl.copyWith(color: AppColors.primary.withValues(alpha: 0.25))],
          ),
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          child: isMobile
              ? Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(initials, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    Text(user.displayName, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Administrator', style: GoogleFonts.workSans(fontSize: 16, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                )
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(initials, style: GoogleFonts.outfit(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Administrator', style: GoogleFonts.workSans(fontSize: 18, color: Colors.white.withValues(alpha: 0.9))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text('Super Admin', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 40),
        // Personal Information
        Container(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: const Border(top: BorderSide(color: AppColors.primary, width: 3)),
            boxShadow: [AppShadows.lg],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Personal Information', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                    tooltip: 'Edit Profile',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(12),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (isMobile) ...[
                _buildProfileField('First Name', user.firstName ?? user.displayName.split(' ').first),
                const SizedBox(height: 20),
                _buildProfileField('Last Name', user.lastName ?? (user.displayName.split(' ').length > 1 ? user.displayName.split(' ')[1] : '')),
                const SizedBox(height: 20),
                _buildProfileField('Email Address', user.email, icon: Icons.email_outlined),
                const SizedBox(height: 20),
                _buildProfileField('Phone Number', user.phoneNumber ?? 'Not provided', icon: Icons.phone_outlined),
              ] else ...[
                Row(children: [
                  Expanded(child: _buildProfileField('First Name', user.firstName ?? user.displayName.split(' ').first)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildProfileField('Last Name', user.lastName ?? (user.displayName.split(' ').length > 1 ? user.displayName.split(' ')[1] : ''))),
                ]),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _buildProfileField('Email Address', user.email, icon: Icons.email_outlined)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildProfileField('Phone Number', user.phoneNumber ?? 'Not provided', icon: Icons.phone_outlined)),
                ]),
              ],
              const SizedBox(height: 24),
              _buildProfileField('Admin Level', 'Super Admin', icon: Icons.shield_outlined),
              const SizedBox(height: 48),
              Text('System Permissions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
            if (icon != null) ...[Icon(icon, size: 16, color: AppColors.textMuted), const SizedBox(width: 8)],
            Text(label, style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(value, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildUsersView(AdminProvider adminProvider) {
    final users = adminProvider.users;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 24 : 40),
      children: [
        AdminKpiPanel(items: [
          KpiItem(label: 'Total Users', value: adminProvider.totalUsersCount.toString(), icon: Icons.people_rounded, color: AppColors.primary),
          KpiItem(label: 'Tenants', value: adminProvider.tenantsCount.toString(), icon: Icons.person_rounded, color: AppColors.success),
          KpiItem(label: 'Property Owners', value: adminProvider.ownersCount.toString(), icon: Icons.business_center_rounded, color: AppColors.warning),
          KpiItem(label: 'Administrators', value: adminProvider.adminsCount.toString(), icon: Icons.shield_rounded, color: const Color(0xFF8B5CF6)),
        ]),
        const SizedBox(height: 24),
        // Search + Filter
        AdminSearchBar(
          onSearch: (query) => adminProvider.setSearchQuery(query),
          showFilterButton: false,
          hintText: 'Search by name or email...',
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
        const SizedBox(height: 32),
        Text('Showing ${users.length} of ${adminProvider.totalUsersCount} users',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 24),
        if (adminProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (users.isEmpty)
          _buildEmptyState(Icons.people_outline, 'No users found')
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
                  final u = users[index];
                  return AdminUserCard(
                    user: u,
                    onViewDetails: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) => DraggableScrollableSheet(
                        initialChildSize: 0.85,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        expand: false,
                        builder: (_, scrollController) => AdminUserDetailScreen(user: u),
                      ),
                    ),
                    onEdit: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) => DraggableScrollableSheet(
                        initialChildSize: 0.85,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        expand: false,
                        builder: (_, scrollController) => AdminUserDetailScreen(user: u, editMode: true),
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  void _showListingsFilterSheet(PropertyProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Listings',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),
                  Text('Gender Orientation',
                      style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(label: const Text('All'), selected: provider.genderFilter == null,
                        onSelected: (_) { provider.setGenderFilter(null); setSheetState(() {}); },
                        selectedColor: AppColors.primary, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.genderFilter == null ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ChoiceChip(label: const Text('Male'), selected: provider.genderFilter == GenderOrientation.male,
                        onSelected: (_) { provider.setGenderFilter(GenderOrientation.male); setSheetState(() {}); },
                        selectedColor: AppColors.primary, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.genderFilter == GenderOrientation.male ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ChoiceChip(label: const Text('Female'), selected: provider.genderFilter == GenderOrientation.female,
                        onSelected: (_) { provider.setGenderFilter(GenderOrientation.female); setSheetState(() {}); },
                        selectedColor: AppColors.primary, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.genderFilter == GenderOrientation.female ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ChoiceChip(label: const Text('Mixed'), selected: provider.genderFilter == GenderOrientation.mixed,
                        onSelected: (_) { provider.setGenderFilter(GenderOrientation.mixed); setSheetState(() {}); },
                        selectedColor: AppColors.primary, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.genderFilter == GenderOrientation.mixed ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Vacancy Status',
                      style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(label: const Text('All'), selected: provider.adminVacancyFilter == null,
                        onSelected: (_) { provider.setAdminVacancyFilter(null); setSheetState(() {}); },
                        selectedColor: AppColors.primary, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.adminVacancyFilter == null ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ChoiceChip(label: const Text('Has Vacancy'), selected: provider.adminVacancyFilter == true,
                        onSelected: (_) { provider.setAdminVacancyFilter(true); setSheetState(() {}); },
                        selectedColor: AppColors.success, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.adminVacancyFilter == true ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ChoiceChip(label: const Text('Fully Occupied'), selected: provider.adminVacancyFilter == false,
                        onSelected: (_) { provider.setAdminVacancyFilter(false); setSheetState(() {}); },
                        selectedColor: AppColors.error, backgroundColor: AppColors.divider,
                        labelStyle: TextStyle(color: provider.adminVacancyFilter == false ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          setSheetState(() {});
                        },
                        child: Text('Clear All',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        ),
                        child: Text('Apply',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoleFilterChip(UserRole? role, String label, AdminProvider adminProvider) {
    final isSelected = _userRoleFilter == role;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textMuted)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _userRoleFilter = role);
        adminProvider.setRoleFilter(role);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.divider,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: const BorderSide(color: Colors.transparent)),
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBookingsView(BookingProvider bookingProvider) {
    final bookings = bookingProvider.filteredBookings;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 24 : 40),
      children: [
        AdminKpiPanel(items: [
          KpiItem(label: 'Total Bookings', value: bookingProvider.totalBookingCount.toString(), icon: Icons.calendar_month_rounded, color: AppColors.primary),
          KpiItem(label: 'Pending Requests', value: bookingProvider.pendingBookingCount.toString(), icon: Icons.pending_actions_rounded, color: AppColors.warning),
          KpiItem(label: 'Approved Bookings', value: bookingProvider.approvedBookingCount.toString(), icon: Icons.check_circle_rounded, color: AppColors.success),
          KpiItem(label: 'Rejected Bookings', value: bookingProvider.rejectedBookingCount.toString(), icon: Icons.cancel_rounded, color: AppColors.error),
        ]),
        const SizedBox(height: 24),
        AdminSearchBar(
          onSearch: (query) => bookingProvider.setSearchQuery(query),
          showFilterButton: false,
          hintText: 'Search by student name, property, or email...',
        ),
        const SizedBox(height: 12),
        AdminBookingFilterBar(
          selectedStatus: bookingProvider.statusFilter,
          onStatusChanged: (status) => bookingProvider.setStatusFilter(status),
          totalCount: bookingProvider.totalBookingCount,
          pendingCount: bookingProvider.pendingBookingCount,
          approvedCount: bookingProvider.approvedBookingCount,
          rejectedCount: bookingProvider.rejectedBookingCount,
        ),
        const SizedBox(height: 32),
        Text('Showing ${bookings.length} of ${bookingProvider.totalBookingCount} bookings',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 24),
        if (bookingProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (bookings.isEmpty)
          _buildEmptyState(Icons.calendar_month_outlined, 'No bookings found')
        else
          ...bookings.map((booking) => AdminBookingCard(booking: booking, onTap: () {})),
      ],
    );
  }

  Widget _buildListingsView(PropertyProvider propertyProvider) {
    final properties = propertyProvider.adminProperties;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 24 : 40),
      children: [
        AdminSearchBar(
          onSearch: (query) => propertyProvider.setSearchQuery(query),
          onFilterTap: () => _showListingsFilterSheet(propertyProvider),
        ),
        const SizedBox(height: 24),
        AdminKpiPanel(items: [
          KpiItem(label: 'Total Listings', value: propertyProvider.totalListings.toString(), icon: Icons.home_work_rounded, color: AppColors.primary),
          KpiItem(label: 'Available Listings', value: propertyProvider.availableListings.toString(), icon: Icons.home_rounded, color: AppColors.success),
          KpiItem(label: 'Fully Occupied', value: propertyProvider.fullListings.toString(), icon: Icons.house_rounded, color: AppColors.error),
          KpiItem(label: 'Available Rooms', value: propertyProvider.totalAvailableRoomCount.toString(), icon: Icons.single_bed_rounded, color: AppColors.secondary),
        ]),
        const SizedBox(height: 32),
        Text('Showing ${properties.length} of ${propertyProvider.totalListings} listings',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 24),
        if (propertyProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (properties.isEmpty)
          _buildEmptyState(Icons.home_work_outlined, 'No listings found')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 32,
                  childAspectRatio: 0.76,
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) => AdminPropertyCard(
                  property: properties[index],
                  liveVacancy: (() {
                    try {
                      return context.read<RoomProvider>().hasVacancyForProperty(properties[index].propertyId, fallback: properties[index].hasVacancy);
                    } catch (_) {
                      return properties[index].hasVacancy;
                    }
                  })(),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPropertyDetailScreen(property: properties[index]))),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admin Dashboard', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1)),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(formattedDate, style: GoogleFonts.workSans(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AdminStatsModel? stats) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: isMobile ? 16 : 24,
      mainAxisSpacing: isMobile ? 16 : 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 1.2 : 1.4,
      children: [
        AdminStatCard(title: 'Total Listings', value: stats?.totalProperties.toString() ?? '0', icon: Icons.home_outlined, iconColor: AppColors.primary, iconBgColor: AppColors.primary.withValues(alpha: 0.08), trendPercent: 4.8, isPositiveTrend: true),
        AdminStatCard(title: 'Occupancy Rate', value: '${((stats?.occupancyRate ?? 0) * 100).toInt()}%', icon: Icons.trending_up_rounded, iconColor: AppColors.success, iconBgColor: AppColors.success.withValues(alpha: 0.08), trendPercent: 2.1, isPositiveTrend: true),
        AdminStatCard(title: 'Total Users', value: stats?.totalUsers.toString() ?? '0', icon: Icons.people_outline_rounded, iconColor: const Color(0xFF8B5CF6), iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08), trendPercent: 1.2, isPositiveTrend: true),
        AdminStatCard(title: 'Total Bookings', value: stats?.totalBookings.toString() ?? '0', icon: Icons.calendar_today_outlined, iconColor: AppColors.warning, iconBgColor: AppColors.warning.withValues(alpha: 0.08), trendPercent: 0.4, isPositiveTrend: false),
      ],
    );
  }

  Widget _buildSolidStatsGrid(AdminStatsModel? stats) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      crossAxisSpacing: isMobile ? 16 : 24,
      mainAxisSpacing: isMobile ? 16 : 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 4.5 : 3.2,
      children: [
        AdminSolidStatCard(title: 'Active Tenants', value: stats?.activeTenants.toString() ?? '0', icon: Icons.apartment_rounded, backgroundColor: AppColors.primary),
        AdminSolidStatCard(title: 'Property Owners', value: stats?.totalOwners.toString() ?? '0', icon: Icons.person_add_alt_1_outlined, backgroundColor: AppColors.success),
        AdminSolidStatCard(title: 'Pending Bookings', value: stats?.pendingBookings.toString() ?? '0', icon: Icons.access_time_rounded, backgroundColor: AppColors.warning),
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
        Expanded(flex: 4, child: _buildQuickActions()),
        const SizedBox(width: 48),
        Expanded(flex: 5, child: _buildRecentBookings(bookingProvider)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            QuickActionCard(label: 'Manage Listings', subLabel: 'Approve & view listings', icon: Icons.home_work_outlined, accentColor: AppColors.primary, onTap: () => _onViewChanged(AdminView.listings)),
            QuickActionCard(label: 'View Bookings', subLabel: 'Track request stats', icon: Icons.calendar_month_outlined, accentColor: AppColors.warning, onTap: () => _onViewChanged(AdminView.bookings)),
            QuickActionCard(label: 'User Management', subLabel: 'Manage users, roles & accounts', icon: Icons.group_outlined, accentColor: const Color(0xFF8B5CF6), onTap: () => _onViewChanged(AdminView.users)),
            QuickActionCard(label: 'Admin Profile', subLabel: 'System permissions & settings', icon: Icons.person_outline, accentColor: AppColors.secondary, onTap: () => _onViewChanged(AdminView.profile)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookings(BookingProvider bookingProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Bookings', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            TextButton(
              onPressed: () => _onViewChanged(AdminView.bookings),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border), boxShadow: [AppShadows.md]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (bookingProvider.bookings.isEmpty)
                const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('No recent bookings')))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookingProvider.bookings.length > 4 ? 4 : bookingProvider.bookings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) => RecentBookingRow(booking: bookingProvider.bookings[index]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionSection(String title, List<_PermissionItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(message, style: GoogleFonts.workSans(fontSize: 18, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final String label;
  final bool isEnabled;
  const _PermissionItem({required this.label, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: isEnabled,
      onChanged: null,
      title: Text(label, style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      activeTrackColor: AppColors.primary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
