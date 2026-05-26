import 'package:flutter/material.dart';
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

    // Get all approved and completed bookings as revenue lines
    final revenueBookings = bookingProvider.bookings.where((b) =>
        b.status == BookingStatus.approved ||
        b.status == BookingStatus.completed).toList();

    // Filter by student or property name search query
    final filteredBookings = revenueBookings.where((b) {
      final query = _searchQuery.toLowerCase();
      return b.studentName.toLowerCase().contains(query) ||
          b.propertyName.toLowerCase().contains(query);
    }).toList();

    // Total monthly earnings from approved bookings
    final totalMonthlyEarnings = filteredBookings.fold(0.0, (sum, b) => sum + b.monthlyRate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Payments & Revenue',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage, search and track monthly rates and booking payments.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF Export feature is coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5287B2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5287B2).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF5287B2),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Monthly Revenue',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${totalMonthlyEarnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar & Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by student name or property name...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Revenue Listings Table/Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: filteredBookings.isEmpty
                  ? _buildEmptyState()
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Tenant',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Property / Room',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Start Date',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Rate',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                        rows: filteredBookings.map((booking) {
                          final dateStr = DateFormat('MMM dd, yyyy').format(booking.requestedAt);

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  booking.studentName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${booking.propertyName} (${booking.roomDescription})',
                                  style: const TextStyle(color: Color(0xFF475569)),
                                ),
                              ),
                              DataCell(
                                Text(
                                  dateStr,
                                  style: const TextStyle(color: Color(0xFF64748B)),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₱${booking.monthlyRate}/mo',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5287B2)),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: booking.statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    booking.statusLabel,
                                    style: TextStyle(
                                      color: booking.statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
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
              color: const Color(0xFF5287B2).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'No matching payment records found',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
