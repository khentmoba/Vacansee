import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';

class AdminBookingFilterBar extends StatelessWidget {
  final BookingStatus? selectedStatus;
  final Function(BookingStatus?) onStatusChanged;
  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  const AdminBookingFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            'Filter by Status:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          _FilterChip(
            label: 'All ($totalCount)',
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Pending ($pendingCount)',
            isSelected: selectedStatus == BookingStatus.pending,
            onTap: () => onStatusChanged(BookingStatus.pending),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Approved ($approvedCount)',
            isSelected: selectedStatus == BookingStatus.approved,
            onTap: () => onStatusChanged(BookingStatus.approved),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Rejected ($rejectedCount)',
            isSelected: selectedStatus == BookingStatus.rejected,
            onTap: () => onStatusChanged(BookingStatus.rejected),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF5287B2) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
