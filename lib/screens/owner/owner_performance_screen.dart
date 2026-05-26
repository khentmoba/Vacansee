import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/owner/owner_revenue_chart.dart';
import '../../models/booking_model.dart';

class OwnerPerformanceScreen extends StatelessWidget {
  const OwnerPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final totalListings = propertyProvider.properties.length;
    final pendingCount = bookingProvider.pendingCount;
    final totalOccupied = propertyProvider.totalOccupiedRooms;
    final totalAvailable = propertyProvider.totalAvailableRooms;
    final totalRooms = totalOccupied + totalAvailable;

    final occupancyRate = totalRooms > 0
        ? (totalOccupied / totalRooms) * 100
        : 0.0;

    // Filter approved or completed for total revenue
    final ownerBookings = bookingProvider.bookings;
    final approvedBookings = ownerBookings
        .where((b) =>
            b.status == BookingStatus.approved ||
            b.status == BookingStatus.completed)
        .toList();

    final totalRevenue = approvedBookings.fold(0.0, (sum, b) => sum + b.monthlyRate);

    // Bookings Status Counts
    final int pending = ownerBookings.where((b) => b.status == BookingStatus.pending).length;
    final int approved = ownerBookings.where((b) => b.status == BookingStatus.approved).length;
    final int rejected = ownerBookings.where((b) => b.status == BookingStatus.rejected).length;
    final int completed = ownerBookings.where((b) => b.status == BookingStatus.completed).length;
    final int cancelled = ownerBookings.where((b) => b.status == BookingStatus.cancelled).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Performance & Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track occupancy, revenues, and bookings conversion metrics.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // Responsive KPI Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.6 : 1.3,
                  children: [
                    _buildKpiCard(
                      'Occupancy Rate',
                      '${occupancyRate.toStringAsFixed(1)}%',
                      Icons.percent_rounded,
                      const Color(0xFF5287B2),
                    ),
                    _buildKpiCard(
                      'Total Listings',
                      '$totalListings',
                      Icons.home_work_rounded,
                      Colors.indigo,
                    ),
                    _buildKpiCard(
                      'Pending Bookings',
                      '$pendingCount',
                      Icons.pending_actions_rounded,
                      Colors.orange,
                    ),
                    _buildKpiCard(
                      'Total Bookings',
                      '${ownerBookings.length}',
                      Icons.book_online_rounded,
                      Colors.teal,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Revenue Chart card
            SizedBox(
              height: 380,
              child: OwnerRevenueChart(bookings: ownerBookings),
            ),
            const SizedBox(height: 24),

            // Two panels: Bookings Breakdown & Occupancy detail
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bookings Breakdown
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: _buildBreakdownCard(
                        title: 'Bookings Status Breakdown',
                        children: [
                          _buildBreakdownRow('Completed', completed, Colors.green),
                          _buildBreakdownRow('Approved', approved, Colors.blue),
                          _buildBreakdownRow('Pending Action', pending, Colors.orange),
                          _buildBreakdownRow('Rejected', rejected, Colors.red),
                          _buildBreakdownRow('Cancelled', cancelled, Colors.grey),
                        ],
                      ),
                    ),
                    if (isWide) const SizedBox(width: 24) else const SizedBox(height: 24),
                    // Occupancy Detail card
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: _buildBreakdownCard(
                        title: 'Room Occupancy Metrics',
                        children: [
                          _buildBreakdownRow('Occupied Rooms', totalOccupied, const Color(0xFF5287B2)),
                          _buildBreakdownRow('Vacant / Available Rooms', totalAvailable, Colors.teal),
                          _buildBreakdownRow('Total Managed Rooms', totalRooms, Colors.black87),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          _buildBreakdownRow('Total Verified Revenue', '₱${totalRevenue.toStringAsFixed(0)}', const Color(0xFF5287B2)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, dynamic count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
