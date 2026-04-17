import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';
import '../booking/owner_bookings_screen.dart';
import '../owner/edit_property_screen.dart';
import '../property/create_property_screen.dart';
import '../../widgets/common/confirmation_dialog.dart';

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
      final propertyProvider = context.read<PropertyProvider>();
      final bookingProvider = context.read<BookingProvider>();
      if (authProvider.user != null) {
        propertyProvider.loadOwnerProperties(authProvider.user!.uid);
        final propertyIds = propertyProvider.properties
            .map((p) => p.propertyId)
            .toList();
        bookingProvider.loadPendingCount(propertyIds);
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
        actions: [
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Owner Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Manage your boarding house listings and booking requests',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      // Verification Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (authProvider.user?.isVerified ?? false)
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (authProvider.user?.isVerified ?? false)
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (authProvider.user?.isVerified ?? false)
                                  ? Icons.verified_rounded
                                  : Icons.pending_actions_rounded,
                              size: 14,
                              color: (authProvider.user?.isVerified ?? false)
                                  ? const Color(0xFF10B981)
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (authProvider.user?.isVerified ?? false)
                                  ? 'Verified Owner'
                                  : 'Verification Pending',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: (authProvider.user?.isVerified ?? false)
                                    ? const Color(0xFF10B981)
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Cards
                  Row(
                    children: [
                      _buildStatCard(
                        Icons.home_outlined,
                        properties
                            .where((p) => p.status != PropertyStatus.deleted)
                            .length
                            .toString(),
                        'Total Listings',
                        const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.bed_outlined,
                        properties
                            .fold<int>(
                              0,
                              (sum, p) => sum + (p.hasVacancy ? 1 : 0),
                            )
                            .toString(),
                        'Available Rooms',
                        const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.calendar_today_outlined,
                        pendingCount.toString(),
                        'Pending Requests',
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Pending Requests Banner
                  if (pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You have $pendingCount pending booking request${pendingCount > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Review and respond to booking requests to keep your tenants updated',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFFA16207),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OwnerBookingsScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Review Now'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePropertyScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5287B2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add New Listing'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Property Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                    top: Radius.circular(12),
                  ),
                  child: property.coverImageUrl != null
                      ? Image.network(
                          property.coverImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.home_work,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditPropertyScreen(property: property),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Color(0xFF1D1B16),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1B16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Delete Button
                Positioned(
                  top: 8,
                  left: 70, // Positioned next to Edit
                  child: GestureDetector(
                    onTap: () async {
                      final provider = context.read<PropertyProvider>();
                      final hasBookings =
                          await provider.hasActiveBookings(property.propertyId);

                      if (!mounted) return;

                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete Listing',
                          content: hasBookings
                              ? 'WARNING: This property has active or pending bookings. Deleting it will hide it from new students, but existing bookings will remain in the system. Are you sure you want to proceed?'
                              : 'Are you sure you want to delete "${property.name}"? This listing will no longer be visible to students.',
                          onConfirm: () async {
                            final success = await provider.deleteProperty(
                              property.propertyId,
                            );

                            if (mounted && success) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Listing deleted'),
                                  duration: const Duration(seconds: 5),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      provider.restoreProperty(
                                        property.propertyId,
                                      );
                                    },
                                  ),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ?? 'Deletion failed',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                // Available/Full badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: property.hasVacancy
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.hasVacancy ? 'Available' : 'Full',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Status Badge (Pending/Verified/Deleted)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        property.status,
                      ).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(property.status),
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property.status.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B16),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF5287B2).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 64,
              color: const Color(0xFF5287B2).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Properties Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start by adding your first boarding house listing',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePropertyScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5287B2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Property'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.verified:
        return const Color(0xFF10B981);
      case PropertyStatus.pending:
        return Colors.orange;
      case PropertyStatus.deleted:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.verified:
        return Icons.verified_rounded;
      case PropertyStatus.pending:
        return Icons.pending_actions_rounded;
      case PropertyStatus.deleted:
        return Icons.delete_forever_rounded;
    }
  }
}
