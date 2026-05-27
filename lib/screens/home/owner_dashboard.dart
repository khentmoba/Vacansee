import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';
import '../owner/owner_bookings_screen.dart';
import '../owner/edit_property_screen.dart';
import '../property/create_property_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/notifications/notification_badge.dart';
import '../owner/owner_profile_screen.dart';
import '../../core/utils/fade_page_route.dart';
import '../../widgets/owner/owner_side_nav.dart';
import '../../widgets/owner/owner_revenue_chart.dart';
import '../../widgets/owner/owner_recent_booking_requests.dart';
import '../../widgets/owner/owner_promo_card.dart';
import '../owner/owner_performance_screen.dart';
import '../owner/owner_payments_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;
  final List<String> _mobileTitles = ['Dashboard', 'Bookings', 'Profile'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context
            .read<PropertyProvider>()
            .loadOwnerProperties(authProvider.user!.uid)
            .then((_) {
          if (!mounted) return;
          final propertyProvider = context.read<PropertyProvider>();
          propertyProvider.subscribeToOwnerProperties(authProvider.user!.uid);
          propertyProvider.subscribeToVacancyUpdates();
          final propertyIds =
              propertyProvider.properties.map((p) => p.propertyId).toList();
          if (propertyIds.isNotEmpty) {
            final bookingProvider = context.read<BookingProvider>();
            bookingProvider.loadOwnerBookings(propertyIds);
            bookingProvider.loadPendingCount(propertyIds);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final properties = propertyProvider.properties;
    final pendingCount = bookingProvider.pendingCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                OwnerSideNav(
                  selectedIndex: _currentIndex,
                  pendingBookingsCount: pendingCount,
                  onIndexChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  onLogout: () => authProvider.signOut(),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: _buildDesktopScreen(
                      _currentIndex,
                      authProvider,
                      propertyProvider,
                      bookingProvider,
                      properties,
                      pendingCount,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              _mobileTitles[_currentIndex],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              NotificationBadge(
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => authProvider.signOut(),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.navyDark,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMobileNavItem(
                        Icons.dashboard_rounded, 'Home', 0),
                    _buildMobileNavItem(
                        Icons.calendar_today_rounded, 'Bookings', 1),
                    _buildMobileNavItem(
                        Icons.person_rounded, 'Profile', 2),
                  ],
                ),
              ),
            ),
          ),
          body: _currentIndex == 1
              ? const OwnerBookingsScreen(showAppBar: false)
              : _currentIndex == 2
                  ? const OwnerProfileScreen(showAppBar: false)
                  : propertyProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : properties.isEmpty
                          ? _buildEmptyState(context)
                          : SingleChildScrollView(
                              child: Center(
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1200),
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 32,
                                    bottom: 140,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildMobileStatsGrid(
                                          propertyProvider,
                                          pendingCount,
                                          properties),
                                      const SizedBox(height: 32),
                                      if (pendingCount > 0)
                                        _buildMobilePendingBanner(
                                            pendingCount),
                                      const SizedBox(height: 40),
                                      _buildSectionHeader(
                                        'My Boarding Houses',
                                        '${properties.length} Active Listings',
                                        onAdd: () {
                                          Navigator.push(
                                            context,
                                            FadePageRoute(
                                              child:
                                                  const CreatePropertyScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 0.75,
                                        ),
                                        itemCount: properties.length,
                                        itemBuilder: (context, index) {
                                          final p = properties[index];
                                          return _buildPropertyCard(
                                            p,
                                            totalRooms: propertyProvider.getTotalRoomsForProperty(p.propertyId),
                                            occupiedRooms: propertyProvider.getOccupiedRoomsForProperty(p.propertyId),
                                            liveVacancy: propertyProvider.hasLiveVacancy(p.propertyId),
                                          );
                                        },
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

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    VoidCallback? onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (onAdd != null)
          IconButton.filled(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopScreen(
    int index,
    AuthProvider authProvider,
    PropertyProvider propertyProvider,
    BookingProvider bookingProvider,
    List<PropertyModel> properties,
    int pendingCount,
  ) {
    switch (index) {
      case 0:
        return _buildDesktopDashboardHome(
          authProvider,
          propertyProvider,
          bookingProvider,
          properties,
          pendingCount,
        );
      case 1:
        return _buildDesktopPropertiesGrid(
            authProvider, propertyProvider, properties);
      case 2:
        return const OwnerBookingsScreen(showAppBar: false);
      case 3:
        return const OwnerPerformanceScreen();
      case 4:
        return const OwnerPaymentsScreen();
      case 5:
        return const OwnerProfileScreen(showAppBar: false);
      default:
        return _buildComingSoonScreen('Screen');
    }
  }

  Widget _buildDesktopDashboardHome(
    AuthProvider authProvider,
    PropertyProvider propertyProvider,
    BookingProvider bookingProvider,
    List<PropertyModel> properties,
    int pendingCount,
  ) {
    final displayName = authProvider.user?.displayName ?? 'Owner';
    final firstName = displayName.split(' ').first;

    final hour = DateTime.now().hour;
    String greeting = 'Welcome back';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    final sortedProperties = List<PropertyModel>.from(properties)
      ..sort((a, b) {
        final aOccupied = propertyProvider.getOccupiedRoomsForProperty(a.propertyId);
        final bOccupied = propertyProvider.getOccupiedRoomsForProperty(b.propertyId);
        return bOccupied.compareTo(aOccupied);
      });
    final topProperties = sortedProperties.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $firstName',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here is your boarding house activity overview for today.',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    FadePageRoute(
                      child: const CreatePropertyScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Listing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // KPI Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.3,
            children: [
              _buildStatCard(
                Icons.home_work_rounded,
                properties.length.toString(),
                'Active Listings',
                AppColors.primary,
                true,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildStatCard(
                Icons.pending_actions_rounded,
                pendingCount.toString(),
                'Pending Requests',
                AppColors.warning,
                true,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildStatCard(
                Icons.check_circle_rounded,
                propertyProvider.totalOccupiedRooms.toString(),
                'Occupied Rooms',
                AppColors.success,
                true,
                onTap: () => setState(() => _currentIndex = 4),
              ),
              _buildStatCard(
                Icons.home_outlined,
                propertyProvider.totalAvailableRooms.toString(),
                'Available Rooms',
                AppColors.secondary,
                true,
                onTap: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Revenue Chart + Recent Bookings
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 380,
                  child:
                      OwnerRevenueChart(bookings: bookingProvider.bookings),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 380,
                  child: OwnerRecentBookingRequests(
                    bookings: bookingProvider.bookings,
                    onViewAll: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Top Performing Properties
          Text(
            'Top Performing Properties',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9,
                children: [
                  ...topProperties.map((p) => _buildPropertyCard(
                    p,
                    totalRooms: propertyProvider.getTotalRoomsForProperty(p.propertyId),
                    occupiedRooms: propertyProvider.getOccupiedRoomsForProperty(p.propertyId),
                    liveVacancy: propertyProvider.hasLiveVacancy(p.propertyId),
                  )),
                  if (topProperties.length < 3)
                    ...List.generate(
                      3 - topProperties.length,
                      (index) => _buildEmptyPropertySlot(),
                    ),
                  const OwnerPromoCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPropertiesGrid(
    AuthProvider authProvider,
    PropertyProvider propertyProvider,
    List<PropertyModel> properties,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'My Boarding Houses',
            'You have ${properties.length} active listings listed on VacanSee.',
            onAdd: () {
              Navigator.push(
                context,
                FadePageRoute(
                  child: const CreatePropertyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          if (properties.isEmpty)
            _buildEmptyState(context)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.95,
              ),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final p = properties[index];
                return _buildPropertyCard(
                  p,
                  totalRooms: propertyProvider.getTotalRoomsForProperty(p.propertyId),
                  occupiedRooms: propertyProvider.getOccupiedRoomsForProperty(p.propertyId),
                  liveVacancy: propertyProvider.hasLiveVacancy(p.propertyId),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildComingSoonScreen(String screenName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.construction_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            screenName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are currently building this screen for you.',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPropertySlot() {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_rounded,
              color: AppColors.primary.withValues(alpha: 0.15),
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'No Listing Available',
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return _AnimatedNavItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      onTap: () => setState(() => _currentIndex = index),
    );
  }

  Widget _buildMobileStatsGrid(
    PropertyProvider propertyProvider,
    int pendingCount,
    List<PropertyModel> properties,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          Icons.home_rounded,
          properties.length.toString(),
          'Total Listings',
          AppColors.primary,
          false,
          onTap: () => setState(() => _currentIndex = 1),
        ),
        _buildStatCard(
          Icons.check_circle_rounded,
          propertyProvider.totalOccupiedRooms.toString(),
          'Occupied Rooms',
          AppColors.success,
          false,
          onTap: () {},
        ),
        _buildStatCard(
          Icons.home_outlined,
          propertyProvider.totalAvailableRooms.toString(),
          'Available Rooms',
          AppColors.secondary,
          false,
          onTap: () {},
        ),
        _buildStatCard(
          Icons.calendar_today_rounded,
          pendingCount.toString(),
          'Pending Requests',
          AppColors.warning,
          false,
          onTap: () => setState(() => _currentIndex = 1),
        ),
      ],
    );
  }

  Widget _buildMobilePendingBanner(int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.secondary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount Pending Request${pendingCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review and respond to booking requests',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentIndex = 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Review',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDesktop, {
    VoidCallback? onTap,
  }) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          onEnter: (_) => setStateBuilder(() => isHovered = true),
          onExit: (_) => setStateBuilder(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 14,
                vertical: isDesktop ? 16 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHovered
                      ? color.withValues(alpha: 0.5)
                      : AppColors.border,
                  width: isHovered ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered
                        ? color.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isHovered ? 16 : 8,
                    offset: Offset(0, isHovered ? 6 : 2),
                  ),
                ],
              ),
              transform: Matrix4.translationValues(
                  0.0, isHovered ? -2.0 : 0.0, 0.0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isDesktop ? 12 : 10),
                    decoration: BoxDecoration(
                      gradient: isHovered
                          ? LinearGradient(
                              colors: [color, color.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.1),
                                color.withValues(alpha: 0.05)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isHovered ? Colors.white : color,
                      size: isDesktop ? 22 : 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.openSans(
                            fontSize: isDesktop ? 13 : 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
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
      },
    );
  }

  Widget _buildPropertyCard(
    PropertyModel property, {
    int totalRooms = 0,
    int occupiedRooms = 0,
    bool liveVacancy = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final occupancyPercent = totalRooms > 0
        ? (occupiedRooms / totalRooms)
        : 0.0;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          onEnter: (_) => setStateBuilder(() => isHovered = true),
          onExit: (_) => setStateBuilder(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                FadePageRoute(
                  child: EditPropertyScreen(property: property),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                  0.0, isHovered ? -4.0 : 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedScale(
                              scale: isHovered ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              child: property.coverImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: property.coverImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child:
                                            Container(color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: AppColors.background,
                                        child: const Icon(
                                          Icons.home_work_outlined,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.background,
                                      child: Center(
                                        child: Icon(
                                          Icons.home_work_rounded,
                                          size: 40,
                                          color: AppColors.primary
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          // Gradient scrim overlay on hover
                          if (isHovered)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.3),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          // Edit badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  if (isHovered)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                    ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_rounded,
                                      size: 11,
                                      color: AppColors.textPrimary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Availability pill
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: liveVacancy
                                    ? AppColors.success
                                    : AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                liveVacancy ? 'VACANT' : 'FULL',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 15, color: Colors.amber[700]),
                          const SizedBox(width: 2),
                          Text(
                            property.averageRating > 0
                                ? property.averageRating.toStringAsFixed(1)
                                : 'New',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price + Occupancy bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₱${property.monthlyPrice}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: ' /mo',
                              style: GoogleFonts.openSans(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop)
                        Text(
                          '$occupiedRooms/$totalRooms rooms',
                          style: GoogleFonts.openSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  if (isDesktop && totalRooms > 0) ...[
                    const SizedBox(height: 8),
                    // Occupancy progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancyPercent,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          occupancyPercent > 0.8
                              ? AppColors.error
                              : occupancyPercent > 0.5
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.secondary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Properties Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start by adding your first boarding house listing to manage vacancies',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePropertyScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Add Your First Property',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
        ],
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
    if (widget.isSelected) return AppColors.primary;
    if (isHovered) return AppColors.primary.withValues(alpha: 0.15);
    return Colors.transparent;
  }

  Color get iconColor {
    if (widget.isSelected) return Colors.white;
    if (isHovered) return AppColors.primary;
    return Colors.white.withValues(alpha: 0.6);
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
            horizontal: widget.isSelected ? 18 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: iconColor, size: 22),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
