import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';

class RecentBookingRow extends StatelessWidget {
  final BookingModel booking;

  const RecentBookingRow({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  booking.propertyName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusBgColor(booking.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getStatusTextColor(booking.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFFF9C4);
      case BookingStatus.approved:
        return const Color(0xFFE8F5E9);
      case BookingStatus.rejected:
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFBC02D);
      case BookingStatus.approved:
        return const Color(0xFF4CAF50);
      case BookingStatus.rejected:
        return const Color(0xFFE57373);
      default:
        return Colors.grey[600]!;
    }
  }
}
