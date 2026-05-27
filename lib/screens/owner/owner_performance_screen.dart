import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final occupancyRate =
        totalRooms > 0 ? (totalOccupied / totalRooms) * 100 : 0.0;

    final ownerBookings = bookingProvider.bookings;
    final approvedBookings = ownerBookings
        .where((b) =>
            b.status == BookingStatus.approved ||
            b.status == BookingStatus.completed)
        .toList();
    final totalRevenue =
        approvedBookings.fold(0.0, (sum, b) => sum + b.monthlyRate);

    final pending = ownerBookings
        .where((b) => b.status == BookingStatus.pending)
        .length;
    final approved = ownerBookings
        .where((b) => b.status == BookingStatus.approved)
        .length;
    final rejected = ownerBookings
        .where((b) => b.status == BookingStatus.rejected)
        .length;
    final completed = ownerBookings
        .where((b) => b.status == BookingStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance & Analytics',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Track occupancy, revenues, and bookings conversion metrics.',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),

            // KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 2.4 : 1.6,
                  children: [
                    _buildKpiCard(
                      'Occupancy Rate',
                      '${occupancyRate.toStringAsFixed(1)}%',
                      Icons.percent_rounded,
                      AppColors.primary,
                      progress: occupancyRate / 100,
                    ),
                    _buildKpiCard(
                      'Total Listings',
                      '$totalListings',
                      Icons.home_work_rounded,
                      AppColors.secondary,
                    ),
                    _buildKpiCard(
                      'Pending Bookings',
                      '$pendingCount',
                      Icons.pending_actions_rounded,
                      AppColors.warning,
                    ),
                    _buildKpiCard(
                      'Total Bookings',
                      '${ownerBookings.length}',
                      Icons.book_online_rounded,
                      AppColors.success,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Revenue Chart
            SizedBox(
              height: 380,
              child: OwnerRevenueChart(bookings: ownerBookings),
            ),
            const SizedBox(height: 24),

            // Breakdown panels
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: _buildBreakdownCard(
                        title: 'Bookings Status Breakdown',
                        children: [
                          _buildBreakdownRow(
                              'Completed', completed, AppColors.success),
                          _buildBreakdownRow(
                              'Approved', approved, AppColors.primary),
                          _buildBreakdownRow(
                              'Pending Action', pending, AppColors.warning),
                          _buildBreakdownRow(
                              'Rejected', rejected, AppColors.error),
                          _buildBreakdownRow(
                              'Cancelled',
                              ownerBookings
                                      .where(
                                          (b) => b.status == BookingStatus.cancelled)
                                      .length,
                              Colors.grey),
                        ],
                      ),
                    ),
                    if (isWide)
                      const SizedBox(width: 24)
                    else
                      const SizedBox(height: 24),
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: _buildBreakdownCard(
                        title: 'Room Occupancy Metrics',
                        children: [
                          _buildBreakdownRow(
                              'Occupied Rooms', totalOccupied, AppColors.primary,
                              showBar: true,
                              barValue: totalRooms > 0
                                  ? totalOccupied / totalRooms
                                  : 0.0),
                          _buildBreakdownRow(
                              'Vacant Rooms', totalAvailable, AppColors.success,
                              showBar: true,
                              barValue: totalRooms > 0
                                  ? totalAvailable / totalRooms
                                  : 0.0),
                          const Divider(
                              color: AppColors.divider, height: 24),
                          _buildBreakdownRow(
                              'Total Managed Rooms', totalRooms, Colors.black87),
                          _buildBreakdownRow(
                              'Total Revenue',
                              '₱${totalRevenue.toStringAsFixed(0)}',
                              AppColors.primary),
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

  Widget _buildKpiCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    double? progress,
  }) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          onEnter: (_) => setStateBuilder(() => isHovered = true),
          onExit: (_) => setStateBuilder(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ? color.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isHovered ? 12 : 6,
                  offset: Offset(0, isHovered ? 4 : 2),
                ),
              ],
            ),
            transform: Matrix4.translationValues(
                0.0, isHovered ? -2.0 : 0.0, 0.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (progress != null)
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: AppColors.border,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: progress != null ? 32 : 38,
                      height: progress != null ? 32 : 38,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? color.withValues(alpha: 0.15)
                            : color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ],
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
                          fontSize: 12,
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
                          fontSize: 20,
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
        );
      },
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required List<Widget> children,
  }) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          onEnter: (_) => setStateBuilder(() => isHovered = true),
          onExit: (_) => setStateBuilder(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
                width: isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isHovered ? 16 : 8,
                  offset: Offset(0, isHovered ? 6 : 4),
                ),
              ],
            ),
            transform: Matrix4.translationValues(
                0.0, isHovered ? -2.0 : 0.0, 0.0),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(
    String label,
    dynamic count,
    Color color, {
    bool showBar = false,
    double barValue = 0.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (showBar) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: barValue,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
