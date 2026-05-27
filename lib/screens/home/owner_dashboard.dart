import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
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

// Import New Redesigned Widgets/Screens
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
  int _currentIndex = 0; // Shared index mapped according to desktop/mobile layouts
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
              final propertyIds = propertyProvider.properties
                  .map((p) => p.propertyId)
                  .toList();
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
                // Sidebar Navigation
                OwnerSideNav(
                  selectedIndex: _currentIndex,
                  pendingBookingsCount: pendingCount,
                  onIndexChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  onLogout: () => authProvider.signOut(),
                ),

                // Main Content Screen mapping
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

        // Mobile View remains unchanged structure-wise, styled elegantly
        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_mobileTitles[_currentIndex]),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.95),
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
                  children: [
                    _buildMobileNavItem(Icons.dashboard_rounded, 'Home', 0),
                    _buildMobileNavItem(Icons.calendar_today_rounded, 'Bookings', 1),
                    _buildMobileNavItem(Icons.person_rounded, 'Profile', 2),
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
                      constraints: const BoxConstraints(maxWidth: 1200),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 32,
                        bottom: 140,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Cards
                          _buildMobileStatsGrid(propertyProvider, pendingCount, properties),
                          const SizedBox(height: 32),
                          // Pending Requests Banner
                          if (pendingCount > 0)
                            _buildMobilePendingBanner(pendingCount),
                          const SizedBox(height: 40),
                          // Header for boarding houses
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My Boarding Houses',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D1B16),
                                      ),
                                    ),
                                    Text(
                                      '${properties.length} Active Listings',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filled(
                                onPressed: (authProvider.user?.isVerified ?? false)
                                    ? () {
                                        Navigator.push(
                                          context,
                                          FadePageRoute(
                                            child: const CreatePropertyScreen(),
                                          ),
                                        );
                                      }
                                    : null,
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
                          ),
                          const SizedBox(height: 16),
                          // Property Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: properties.length,
                            itemBuilder: (context, index) {
                              final property = properties[index];
                              return _buildPropertyCard(property);
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

  // Desktop Screen Selector
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
        return _buildDesktopPropertiesGrid(authProvider, propertyProvider, properties);
      case 2:
        return const OwnerBookingsScreen(showAppBar: false);
      case 3:
        return _buildComingSoonScreen('Direct Messages');
      case 4:
        return const OwnerPerformanceScreen();
      case 5:
        return const OwnerPaymentsScreen();
      case 6:
        return const OwnerProfileScreen(showAppBar: false);
      default:
        return _buildComingSoonScreen('Screen');
    }
  }

  // RentEasy inspired Desktop Dashboard Home
  Widget _buildDesktopDashboardHome(
    AuthProvider authProvider,
    PropertyProvider propertyProvider,
    BookingProvider bookingProvider,
    List<PropertyModel> properties,
    int pendingCount,
  ) {
    final displayName = authProvider.user?.displayName ?? 'Owner';
    final firstName = displayName.split(' ').first;

    // Greeting Message based on time of day
    final hour = DateTime.now().hour;
    String greeting = 'Welcome back';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    // Top Performing Properties calculation
    final sortedProperties = List<PropertyModel>.from(properties)
      ..sort((a, b) {
        final aOccupied = a.totalRooms - a.availableRooms;
        final bOccupied = b.totalRooms - b.availableRooms;
        return bOccupied.compareTo(aOccupied);
      });
    final topProperties = sortedProperties.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Greetings and Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $firstName! 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Here is your boarding house activity overview for today.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: (authProvider.user?.isVerified ?? false)
                    ? () {
                        Navigator.push(
                          context,
                          FadePageRoute(
                            child: const CreatePropertyScreen(),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Listing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 4 KPI Cards Grid
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
                const Color(0xFF5287B2),
                true,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildStatCard(
                Icons.pending_actions_rounded,
                pendingCount.toString(),
                'Pending Requests',
                Colors.orangeAccent,
                true,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildStatCard(
                Icons.check_circle_rounded,
                propertyProvider.totalOccupiedRooms.toString(),
                'Occupied Rooms',
                const Color(0xFF10B981),
                true,
                onTap: () => setState(() => _currentIndex = 4),
              ),
              _buildStatCard(
                Icons.home_outlined,
                propertyProvider.totalAvailableRooms.toString(),
                'Available Rooms',
                Colors.indigo,
                true,
                onTap: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Row for Revenue Chart and Recent Booking Requests
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Bar Chart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 380,
                  child: OwnerRevenueChart(bookings: bookingProvider.bookings),
                ),
              ),
              const SizedBox(width: 24),
              // Recent Booking Requests
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 380,
                  child: OwnerRecentBookingRequests(
                    bookings: bookingProvider.bookings,
                    onViewAll: () {
                      setState(() {
                        _currentIndex = 2; // Switch to Booking Requests tab
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Top Performing Properties & Promo card Grid
          const Text(
            'Top Performing Properties',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
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
                  ...topProperties.map((p) => _buildPropertyCard(p)),
                  // Fallback empty slots if there are fewer than 3 properties
                  if (topProperties.length < 3)
                    ...List.generate(
                      3 - topProperties.length,
                      (index) => _buildEmptyPropertySlot(),
                    ),
                  // 4th cell is always the promo card
                  const OwnerPromoCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Original Listings view, but tailored for Desktop main body
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Boarding Houses',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You have ${properties.length} active listings listed on VacanSee.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: (authProvider.user?.isVerified ?? false)
                    ? () {
                        Navigator.push(
                          context,
                          FadePageRoute(
                            child: const CreatePropertyScreen(),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Boarding House'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
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
                return _buildPropertyCard(properties[index]);
              },
            ),
        ],
      ),
    );
  }

  // Placeholder Screen
  Widget _buildComingSoonScreen(String screenName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: const Color(0xFF5287B2).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '$screenName Coming Soon',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We are currently building this screen for you.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPropertySlot() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_rounded,
              color: const Color(0xFF5287B2).withValues(alpha: 0.2),
              size: 40,
            ),
            const SizedBox(height: 8),
            const Text(
              'No Listing Available',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Utilities for Mobile View
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
          const Color(0xFF3B82F6),
          false,
          onTap: () => setState(() => _currentIndex = 1),
        ),
        _buildStatCard(
          Icons.check_circle_rounded,
          propertyProvider.totalOccupiedRooms.toString(),
          'Occupied Rooms',
          const Color(0xFF10B981),
          false,
          onTap: () {},
        ),
        _buildStatCard(
          Icons.home_outlined,
          propertyProvider.totalAvailableRooms.toString(),
          'Available Rooms',
          const Color(0xFF8B5CF6),
          false,
          onTap: () {},
        ),
        _buildStatCard(
          Icons.calendar_today_rounded,
          pendingCount.toString(),
          'Pending Requests',
          const Color(0xFFF59E0B),
          false,
          onTap: () => setState(() => _currentIndex = 1),
        ),
      ],
    );
  }

  Widget _buildMobilePendingBanner(int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFEF3C7),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have $pendingCount pending request${pendingCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review and respond to booking requests',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentIndex = 1); // switch to bookings tab on mobile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Review',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widgets
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
                  color: isHovered ? color.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                  width: isHovered ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered 
                        ? color.withValues(alpha: 0.1) 
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: isHovered ? 12 : 6,
                    offset: Offset(0, isHovered ? 4 : 2),
                  ),
                ],
              ),
              transform: Matrix4.translationValues(0.0, isHovered ? -2.0 : 0.0, 0.0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isDesktop ? 12 : 10),
                    decoration: BoxDecoration(
                      color: isHovered 
                          ? color.withValues(alpha: 0.15) 
                          : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon, 
                      color: color, 
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
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: isDesktop ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
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

  Widget _buildPropertyCard(PropertyModel property) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final occupiedRooms = property.totalRooms - property.availableRooms;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Overlays
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
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: const Color(0xFFF8FAFC),
                                      child: const Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFFF8FAFC),
                                    child: Center(
                                      child: Icon(
                                        Icons.home_work_rounded,
                                        size: 40,
                                        color: const Color(0xFF5287B2).withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Edit Button Overlay (Top Left)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_rounded, size: 12, color: AppColors.textPrimary),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Availability Pill (Bottom Right)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: property.hasVacancy ? AppColors.success : AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              property.hasVacancy ? 'VACANT' : 'FULL',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title & Stars Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          property.averageRating > 0
                              ? property.averageRating.toStringAsFixed(1)
                              : 'New',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Address details
                Text(
                  property.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                // Price Tag & Occupancy Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₱${property.monthlyPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                            ),
                          ),
                          const TextSpan(
                            text: ' /month',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop)
                      Text(
                        'Rooms: $occupiedRooms/${property.totalRooms}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF5287B2).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_work_outlined,
              size: 64,
              color: Color(0xFF5287B2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Properties Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              (context.read<AuthProvider>().user?.isVerified ?? false)
                  ? 'Start by adding your first boarding house listing to manage vacancies'
                  : 'Your account is pending verification. Once approved, you can add listings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: (context.read<AuthProvider>().user?.isVerified ?? false)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePropertyScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5287B2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Your First Property',
              style: TextStyle(fontWeight: FontWeight.bold),
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
    if (widget.isSelected) return const Color(0xFF5287B2);
    if (isHovered) return const Color(0xFF5287B2).withValues(alpha: 0.15);
    return Colors.transparent;
  }

  Color get iconColor {
    if (widget.isSelected) return Colors.white;
    if (isHovered) return const Color(0xFF5287B2);
    return Colors.white.withValues(alpha: 0.65);
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
              Icon(widget.icon, color: iconColor, size: 22),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
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
