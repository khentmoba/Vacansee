import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import '../../widgets/ratings/rate_property_dialog.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final student = authProvider.user;

    if (student == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          return CustomScrollView(
            slivers: [
              // Page Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 24,
                    vertical: isDesktop ? 48 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Bookings',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track the status of your booking requests',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bookings List
              StreamBuilder<List<BookingModel>>(
                stream: bookingService.getStudentBookings(student.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }

                  final bookings = snapshot.data ?? [];

                  if (bookings.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.only(
                      left: isDesktop ? 60 : 24,
                      right: isDesktop ? 60 : 24,
                      bottom: isDesktop ? 40 : 140,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _BookingCard(booking: bookings[index]);
                        },
                        childCount: bookings.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text('Your requested rooms will appear here'),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title and Status
                Row(
                  children: [
                    Text(
                      booking.propertyName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D1B16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 24),

                // Details Grid
                Row(
                  children: [
                    _buildDetailItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Booking Date',
                      value: DateFormat('MMMM d, yyyy').format(booking.requestedAt),
                    ),
                    _buildDetailItem(
                      icon: Icons.payments_outlined,
                      label: 'Monthly Rate',
                      value: '₱${booking.roomDescription.contains('₱') ? booking.roomDescription.split('₱')[1].split(' ')[0] : '5,500'}', // Fallback for demo or parse from model
                    ),
                    _buildDetailItem(
                      icon: Icons.location_on_outlined,
                      label: 'Booking ID',
                      value: '#${booking.bookingId.substring(0, 5).toUpperCase()}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Info Banner
          _buildInfoBanner(),

          // Actions (if needed)
          if (booking.status == BookingStatus.approved || booking.status == BookingStatus.completed)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showRatingDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5287B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Rate Property',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (booking.status) {
      case BookingStatus.pending:
        bgColor = const Color(0xFFFFF7E6);
        textColor = const Color(0xFFB8860B);
        icon = Icons.access_time_rounded;
        break;
      case BookingStatus.approved:
        bgColor = const Color(0xFFE6F9F0);
        textColor = const Color(0xFF00D27B);
        icon = Icons.check_circle_rounded;
        break;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        bgColor = const Color(0xFFFFEBEA);
        textColor = const Color(0xFFFF3B30);
        icon = Icons.cancel_rounded;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            booking.statusLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1B16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    String message;
    if (booking.status == BookingStatus.pending) {
      message = "Your booking request is being reviewed by the owner. You'll receive a notification once they respond.";
    } else if (booking.status == BookingStatus.approved) {
      message = "Your booking has been approved! You can now proceed with the next steps or visit the property.";
    } else if (booking.status == BookingStatus.rejected) {
      message = "Unfortunately, your booking request was not accepted. You can try exploring other available boarding houses.";
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4A7EBB),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatePropertyDialog(booking: booking),
    );
  }
}
