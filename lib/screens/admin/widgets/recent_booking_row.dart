import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';

class RecentBookingRow extends StatelessWidget {
  final BookingModel booking;

  const RecentBookingRow({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final name = booking.studentName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';
    final dateStr = DateFormat('MMM d, h:mm a').format(booking.requestedAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.03), width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.propertyName} • $dateStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBgColor(booking.status),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusTextColor(booking.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  booking.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusTextColor(booking.status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFEF3C7);
      case BookingStatus.approved:
        return const Color(0xFFD1FAE5);
      case BookingStatus.rejected:
        return const Color(0xFFFEE2E2);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFD97706);
      case BookingStatus.approved:
        return const Color(0xFF059669);
      case BookingStatus.rejected:
        return const Color(0xFFDC2626);
      default:
        return Colors.grey[600]!;
    }
  }
}


