import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class OwnerPaymentsScreen extends StatefulWidget {
  const OwnerPaymentsScreen({super.key});

  @override
  State<OwnerPaymentsScreen> createState() => _OwnerPaymentsScreenState();
}

class _OwnerPaymentsScreenState extends State<OwnerPaymentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final revenueBookings = bookingProvider.bookings
        .where((b) =>
            b.status == BookingStatus.approved ||
            b.status == BookingStatus.completed)
        .toList();

    final filteredBookings = revenueBookings.where((b) {
      final query = _searchQuery.toLowerCase();
      return b.studentName.toLowerCase().contains(query) ||
          b.propertyName.toLowerCase().contains(query);
    }).toList();

    final totalMonthlyEarnings =
        filteredBookings.fold(0.0, (sum, b) => sum + b.monthlyRate);
    final approvedCount =
        revenueBookings.where((b) => b.status == BookingStatus.approved).length;
    final completedCount = revenueBookings
        .where((b) => b.status == BookingStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments & Revenue',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage, search and track monthly rates and booking payments.',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF Export feature is coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text(
                    'Export PDF',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 3.5 : 4.5,
                  children: [
                    _buildSummaryCard(
                      Icons.account_balance_wallet_rounded,
                      'Estimated Monthly Revenue',
                      '₱${_formatNumber(totalMonthlyEarnings)}',
                      AppColors.primary,
                    ),
                    _buildSummaryCard(
                      Icons.check_circle_rounded,
                      'Approved Bookings',
                      '$approvedCount',
                      AppColors.success,
                    ),
                    _buildSummaryCard(
                      Icons.done_all_rounded,
                      'Completed Bookings',
                      '$completedCount',
                      AppColors.secondary,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Search
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by student name or property name...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textMuted),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Revenue Table
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: filteredBookings.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          return _buildMobileListView(filteredBookings);
                        }
                        return _buildDesktopTable(filteredBookings);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<BookingModel> bookings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 48,
        columns: [
          DataColumn(
            label: Text(
              'Tenant',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Property / Room',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Start Date',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13),
            ),
          ),
          DataColumn(
            numeric: true,
            label: Text(
              'Rate',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13),
            ),
          ),
        ],
        rows: bookings.map((booking) {
          final dateStr =
              DateFormat('MMM dd, yyyy').format(booking.requestedAt);
          return DataRow(
            cells: [
              DataCell(Text(
                booking.studentName,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13),
              )),
              DataCell(Text(
                '${booking.propertyName} (${booking.roomDescription})',
                style: GoogleFonts.openSans(
                    color: AppColors.textSecondary, fontSize: 13),
              )),
              DataCell(Text(
                dateStr,
                style: GoogleFonts.openSans(
                    color: AppColors.textMuted, fontSize: 13),
              )),
              DataCell(Text(
                '₱${NumberFormat('#,###').format(booking.monthlyRate)}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 13),
              )),
              DataCell(Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: booking.statusColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  booking.statusLabel,
                  style: GoogleFonts.poppins(
                    color: booking.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileListView(List<BookingModel> bookings) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const Divider(
        color: AppColors.divider,
        height: 24,
      ),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final dateStr =
            DateFormat('MMM dd, yyyy').format(booking.requestedAt);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.studentName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${booking.propertyName} • $dateStr',
                    style: GoogleFonts.openSans(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${NumberFormat('#,###').format(booking.monthlyRate)}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: booking.statusColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: GoogleFonts.poppins(
                      color: booking.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'No matching payment records found',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}K';
    }
    return val.toStringAsFixed(0);
  }
}
