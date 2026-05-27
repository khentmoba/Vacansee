import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: Colors.grey[700],
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Status:',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(width: 16),
            _FilterChip(
              label: 'All',
              count: totalCount,
              isSelected: selectedStatus == null,
              onTap: () => onStatusChanged(null),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Pending',
              count: pendingCount,
              isSelected: selectedStatus == BookingStatus.pending,
              onTap: () => onStatusChanged(BookingStatus.pending),
              activeColor: AppColors.warning,
              dotColor: AppColors.warning,
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Approved',
              count: approvedCount,
              isSelected: selectedStatus == BookingStatus.approved,
              onTap: () => onStatusChanged(BookingStatus.approved),
              activeColor: AppColors.success,
              dotColor: AppColors.success,
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Rejected',
              count: rejectedCount,
              isSelected: selectedStatus == BookingStatus.rejected,
              onTap: () => onStatusChanged(BookingStatus.rejected),
              activeColor: AppColors.error,
              dotColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color? dotColor;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    this.dotColor,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.activeColor.withValues(alpha: 0.1);
    final activeBorder = widget.activeColor;
    final activeText = widget.activeColor;

    final inactiveBg = Colors.white;
    final inactiveBorder = Colors.black.withValues(alpha: 0.06);
    final inactiveText = Colors.grey[700]!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? activeBg
              : (_isHovered ? Colors.grey[50] : inactiveBg),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: widget.isSelected
                ? activeBorder
                : (_isHovered ? Colors.grey[300]! : inactiveBorder),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.dotColor != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected ? activeText : inactiveText,
                    fontWeight: widget.isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.activeColor.withValues(alpha: 0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected ? activeText : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
