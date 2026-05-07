import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';
import '../owner/owner_bookings_screen.dart';
import '../owner/edit_property_screen.dart';
import '../property/create_property_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/notifications/notification_badge.dart';
import '../../widgets/owner/owner_top_nav_bar.dart';
import '../../core/utils/fade_page_route.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<PropertyProvider>().loadOwnerProperties(authProvider.user!.uid).then((_) {
          if (!mounted) return;
          final propertyProvider = context.read<PropertyProvider>();
          final propertyIds = propertyProvider.properties
              .map((p) => p.propertyId)
              .toList();
          if (propertyIds.isNotEmpty) {
            context.read<BookingProvider>().loadPendingCount(propertyIds);
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

        return Scaffold(
          backgroundColor: const Color(0xFFF8FBFD),
          appBar: isDesktop
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(80),
                  child: OwnerTopNavBar(currentRoute: 'Dashboard'),
                )
              : AppBar(
                  title: const Text('Owner Dashboard'),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D1B16),
                  elevation: 0,
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
          body: propertyProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : properties.isEmpty
                  ? _buildEmptyState(context)
                  : SingleChildScrollView(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 40 : 20,
                            vertical: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              const Text(
                                'Owner Dashboard',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D1B16),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manage your boarding house listings and booking requests',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Owner Verification Alert Banner
                              if (!(authProvider.user?.isVerified ?? false))
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.pending_actions_rounded,
                                        color: Colors.orange[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Account Verification Pending',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[800],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'An admin will review your account shortly. You can browse the dashboard, but publishing listings is locked until verified.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[700],
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Stats Cards
                              Row(
                                children: [
                                  _buildStatCard(
                                    Icons.home_rounded,
                                    properties
                                        .where((p) => p.status != PropertyStatus.deleted)
                                        .length
                                        .toString(),
                                    'Total Listings',
                                    const Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildStatCard(
                                    Icons.check_circle_rounded,
                                    propertyProvider.totalOccupiedRooms.toString(),
                                    'Occupied Rooms',
                                    const Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildStatCard(
                                    Icons.home_outlined,
                                    propertyProvider.totalAvailableRooms.toString(),
                                    'Available Rooms',
                                    const Color(0xFF8B5CF6),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildStatCard(
                                    Icons.calendar_today_rounded,
                                    pendingCount.toString(),
                                    'Pending Requests',
                                    const Color(0xFFF59E0B),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Pending Requests Banner
                              if (pendingCount > 0)
                                Container(
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
                                              'You have $pendingCount pending booking request${pendingCount > 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Review and respond to booking requests to keep your tenants updated',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: const Color(0xFFB45309),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            FadePageRoute(
                                              child: const OwnerBookingsScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD97706),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 18,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Review Now',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 40),
                              // My Boarding Houses Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'My Boarding Houses',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D1B16),
                                    ),
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5287B2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      disabledBackgroundColor:
                                          const Color(0xFF5287B2).withValues(alpha: 0.4),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 20),
                                    label: Text(
                                      (authProvider.user?.isVerified ?? false)
                                          ? 'Add New Listing'
                                          : 'Verification Required',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
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
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 3 : 2,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: isDesktop ? 0.9 : 0.75,
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

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: property.coverImageUrl != null
                      ? Image.network(
                          property.coverImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.home_work_rounded,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                ),
                // Edit Button Overlay
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        FadePageRoute(
                          child: EditPropertyScreen(property: property),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B16),
                        ),
                      ),
                    ),
                  ),
                ),
                // Available Badge Overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: property.hasVacancy
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      property.hasVacancy ? 'Available' : 'Full',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B16),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF5287B2).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 80,
              color: const Color(0xFF5287B2).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Properties Yet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              (context.read<AuthProvider>().user?.isVerified ?? false)
                  ? 'Start by adding your first boarding house listing to manage vacancies'
                  : 'Your account is pending verification. Once approved, you can add listings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              disabledBackgroundColor:
                  const Color(0xFF5287B2).withValues(alpha: 0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              (context.read<AuthProvider>().user?.isVerified ?? false)
                  ? 'Add Your First Property'
                  : 'Verification Required',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
