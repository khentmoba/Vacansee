import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';

class OwnerRecentBookingRequests extends StatelessWidget {
  final List<BookingModel> bookings;
  final VoidCallback onViewAll;

  const OwnerRecentBookingRequests({
    super.key,
    required this.bookings,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Sort and take top 5 recent requests
    final sortedBookings = List<BookingModel>.from(bookings)
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    final recentBookings = sortedBookings.take(5).toList();

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Booking Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5287B2),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'View All',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content List
            if (recentBookings.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_online_rounded,
                        size: 40,
                        color: const Color(0xFF5287B2).withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No booking requests yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: recentBookings.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFFF1F5F9),
                    height: 24,
                  ),
                  itemBuilder: (context, index) {
                    final booking = recentBookings[index];
                    final studentName = booking.studentName;
                    final initials = studentName.isNotEmpty
                        ? studentName
                            .trim()
                            .split(' ')
                            .map((l) => l.isNotEmpty ? l[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                        : '?';

                    final dateStr = DateFormat('MMM dd, yyyy').format(booking.requestedAt);

                    return Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF5287B2).withValues(alpha: 0.1),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Color(0xFF5287B2),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Middle details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${booking.propertyName} • ${booking.roomDescription}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rate: ₱${booking.monthlyRate}/mo • $dateStr',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF5287B2),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: booking.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
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
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
