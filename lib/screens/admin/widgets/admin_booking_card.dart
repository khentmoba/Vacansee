import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';

class AdminBookingCard extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const AdminBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  State<AdminBookingCard> createState() => _AdminBookingCardState();
}

class _AdminBookingCardState extends State<AdminBookingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
    final dateFormat = DateFormat('MMM d, yyyy');
    final name = widget.booking.studentName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        transform: _isHovered ? Matrix4.translationValues(0, -3, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.primary.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? Colors.black.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 6) : const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 750;

                  final avatar = CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );

                  final bookingHeader = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking ID: #${widget.booking.bookingId.substring(0, 5).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );

                  final propertyBlock = _InfoBlock(
                    label: 'Property',
                    title: widget.booking.propertyName,
                    subTitle: 'Owner: ${widget.booking.ownerName ?? 'Unknown'}',
                    icon: Icons.home_work_outlined,
                  );

                  final dateBlock = _InfoBlock(
                    label: 'Booking Date',
                    title: dateFormat.format(widget.booking.requestedAt),
                    icon: Icons.calendar_today_outlined,
                  );

                  final rateBlock = _InfoBlock(
                    label: 'Monthly Rate',
                    title: currencyFormat.format(widget.booking.monthlyRate),
                    icon: Icons.payments_outlined,
                    titleColor: AppColors.primary,
                  );

                  final statusChip = _StatusChip(status: widget.booking.status);

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            avatar,
                            const SizedBox(width: 14),
                            Expanded(child: bookingHeader),
                            statusChip,
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: propertyBlock),
                            Expanded(child: rateBlock),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: dateBlock),
                            const Spacer(),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      avatar,
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: bookingHeader),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: propertyBlock),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: dateBlock),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: rateBlock),
                      const SizedBox(width: 16),
                      statusChip,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String title;
  final String? subTitle;
  final IconData icon;
  final Color? titleColor;

  const _InfoBlock({
    required this.label,
    required this.title,
    required this.icon,
    this.subTitle,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subTitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subTitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case BookingStatus.approved:
        color = AppColors.success;
        label = 'Approved';
        break;
      case BookingStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

