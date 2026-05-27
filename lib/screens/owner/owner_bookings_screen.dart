import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/booking_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/owner/owner_top_nav_bar.dart';

class OwnerBookingsScreen extends StatefulWidget {
  final bool showAppBar;
  const OwnerBookingsScreen({super.key, this.showAppBar = true});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  List<String>? _lastPropertyIds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (authProvider.user != null) {
      final ids = propertyProvider.properties
          .where((p) => p.ownerId == authProvider.user!.uid)
          .map((p) => p.propertyId)
          .toList();

      if (ids.isNotEmpty) {
        final idsChanged = _lastPropertyIds == null ||
            _lastPropertyIds!.length != ids.length ||
            !ids.every((id) => _lastPropertyIds!.contains(id));

        if (idsChanged) {
          _lastPropertyIds = ids;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            bookingProvider.loadOwnerBookings(ids);
            bookingProvider.loadPendingCount(ids);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.bookings;

    final pendingBookings = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();
    final processedBookings = bookings
        .where((b) => b.status != BookingStatus.pending)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        final content = Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: bookingProvider.errorMessage != null
                ? _buildErrorState(bookingProvider)
                : bookingProvider.isLoading && bookings.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: isDesktop ? 0 : 20,
                          right: isDesktop ? 0 : 20,
                          top: 32,
                          bottom: isDesktop ? 32 : 140,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildSectionTitle(
                              'Pending Requests',
                              badgeText:
                                  pendingBookings.isNotEmpty
                                      ? '${pendingBookings.length} Awaiting Response'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            if (pendingBookings.isEmpty)
                              _buildEmptyState('No pending requests')
                            else
                              ...pendingBookings.map(
                                (b) => _OwnerBookingCard(
                                    booking: b, isPending: true),
                              ),
                            const SizedBox(height: 48),
                            _buildSectionTitle('Processed Requests'),
                            const SizedBox(height: 16),
                            if (processedBookings.isEmpty)
                              _buildEmptyState('No processed requests yet')
                            else
                              ...processedBookings.map(
                                (b) => _OwnerBookingCard(
                                    booking: b, isPending: false),
                              ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
          ),
        );

        if (!widget.showAppBar) {
          return content;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: isDesktop
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(72),
                  child:
                      OwnerTopNavBar(currentRoute: 'Booking Requests'),
                )
              : AppBar(
                  title: const Text('Booking Requests'),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                ),
          body: content,
        );
      },
    );
  }

  Widget _buildHeader() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (!isDesktop) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Requests',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review and manage tenant booking requests for your properties',
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String? badgeText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (badgeText != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.poppins(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.openSans(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BookingProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(provider.errorMessage!),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _lastPropertyIds = null),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _OwnerBookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isPending;

  const _OwnerBookingCard({
    required this.booking,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPending) return _buildProcessedCard(context);
    return _buildPendingCard(context);
  }

  Widget _buildPendingCard(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          onEnter: (_) => setStateBuilder(() => isHovered = true),
          onExit: (_) => setStateBuilder(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: AppColors.warning,
                  width: 4,
                ),
                top: BorderSide(
                  color: isHovered
                      ? AppColors.border.withValues(alpha: 0.8)
                      : AppColors.border,
                ),
                right: BorderSide(
                  color: isHovered
                      ? AppColors.border.withValues(alpha: 0.8)
                      : AppColors.border,
                ),
                bottom: BorderSide(
                  color: isHovered
                      ? AppColors.border.withValues(alpha: 0.8)
                      : AppColors.border,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? Colors.black.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isHovered ? 16 : 8,
                  offset: Offset(0, isHovered ? 6 : 2),
                ),
              ],
            ),
            transform: Matrix4.translationValues(
                0.0, isHovered ? -2.0 : 0.0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            AppColors.warning.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.warning,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.studentName,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Request #${booking.bookingId.substring(0, 5).toUpperCase()}',
                              style: GoogleFonts.openSans(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.warning
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'Pending Review',
                          style: GoogleFonts.poppins(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 16),
                  // Info grid
                  if (isMobile)
                    Column(
                      children: [
                        _buildInfoRow(
                          Icons.home_outlined,
                          'Property',
                          booking.propertyName,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Requested',
                          DateFormat('MMM d, yyyy')
                              .format(booking.requestedAt),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.payments_outlined,
                          'Monthly Rate',
                          '₱${NumberFormat('#,###').format(booking.monthlyRate != 0 ? booking.monthlyRate : 5500)}',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoLinkRow(
                          Icons.person_search_outlined,
                          'Tenant Info',
                          'View Details',
                          onTap: () =>
                              _showTenantDetailsDialog(context),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        _buildInfoItem(
                          Icons.home_outlined,
                          'Property',
                          booking.propertyName,
                        ),
                        _buildInfoItem(
                          Icons.calendar_today_outlined,
                          'Request Date',
                          DateFormat('MMM d, yyyy')
                              .format(booking.requestedAt),
                        ),
                        _buildInfoItem(
                          Icons.payments_outlined,
                          'Monthly Rate',
                          '₱${NumberFormat('#,###').format(booking.monthlyRate != 0 ? booking.monthlyRate : 5500)}',
                        ),
                        _buildInfoItem(
                          Icons.person_search_outlined,
                          'Tenant Info',
                          'View Details',
                          isLink: true,
                          onTap: () =>
                              _showTenantDetailsDialog(context),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _handleAction(context, false),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(
                                color: AppColors.error),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _handleAction(context, true),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessedCard(BuildContext context) {
    final status = booking.status;
    bool isHovered = false;

    IconData statusIcon;
    Color badgeBgColor;
    Color badgeTextColor;
    Color borderColor;

    switch (status) {
      case BookingStatus.approved:
        statusIcon = Icons.check_circle;
        badgeBgColor = const Color(0xFFECFDF5);
        badgeTextColor = AppColors.success;
        borderColor = AppColors.success;
        break;
      case BookingStatus.completed:
        statusIcon = Icons.done_all;
        badgeBgColor = const Color(0xFFEFF6FF);
        badgeTextColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case BookingStatus.rejected:
        statusIcon = Icons.cancel;
        badgeBgColor = const Color(0xFFFEF2F2);
        badgeTextColor = AppColors.error;
        borderColor = AppColors.error;
        break;
      case BookingStatus.cancelled:
        statusIcon = Icons.cancel_outlined;
        badgeBgColor = const Color(0xFFF3F4F6);
        badgeTextColor = const Color(0xFF6B7280);
        borderColor = const Color(0xFF6B7280);
        break;
      case BookingStatus.expired:
        statusIcon = Icons.history;
        badgeBgColor = const Color(0xFFFFFBEB);
        badgeTextColor = AppColors.warning;
        borderColor = AppColors.warning;
        break;
      default:
        statusIcon = Icons.help_outline;
        badgeBgColor = const Color(0xFFF3F4F6);
        badgeTextColor = const Color(0xFF6B7280);
        borderColor = const Color(0xFF6B7280);
    }

    final propertyProvider = context.watch<PropertyProvider>();
    final roomStatus =
        propertyProvider.getRoomStatusFromCache(booking.roomId);

    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          onEnter: (_) => setStateBuilder(() => isHovered = true),
          onExit: (_) => setStateBuilder(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: borderColor, width: 3),
                top: BorderSide(
                  color: isHovered
                      ? AppColors.border.withValues(alpha: 0.8)
                      : AppColors.border,
                ),
                right: BorderSide(
                  color: isHovered
                      ? AppColors.border.withValues(alpha: 0.8)
                      : AppColors.border,
                ),
                bottom: BorderSide(
                  color: isHovered
                      ? AppColors.border.withValues(alpha: 0.8)
                      : AppColors.border,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? Colors.black.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isHovered ? 12 : 6,
                  offset: Offset(0, isHovered ? 4 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: badgeBgColor,
                      child: Icon(statusIcon,
                          color: badgeTextColor, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.studentName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.propertyName,
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 11,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, yyyy')
                                    .format(booking.requestedAt),
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Icon(Icons.payments_outlined,
                                  size: 11,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '₱${NumberFormat('#,###').format(booking.monthlyRate != 0 ? booking.monthlyRate : 5500)}/mo',
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: badgeTextColor
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        booking.statusLabel,
                        style: GoogleFonts.poppins(
                          color: badgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (status == BookingStatus.approved) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (roomStatus != RoomStatus.occupied)
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 12),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _handleCheckIn(context),
                            icon: const Icon(
                                Icons.login_rounded, size: 15),
                            label: const Text('Check-In'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: const BorderSide(
                                  color: AppColors.success),
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _handleCheckOut(context),
                        icon: const Icon(
                            Icons.logout_rounded, size: 15),
                        label: Text(
                          roomStatus == RoomStatus.occupied
                              ? 'Complete Stay'
                              : 'Complete Stay (Check-Out)',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoLinkRow(IconData icon, String label,
      String value, {VoidCallback? onTap}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onTap,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isLink
                    ? AppColors.primary
                    : AppColors.textPrimary,
                decoration:
                    isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTenantDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Tenant Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', booking.studentEmail),
            if (booking.studentPhone != null)
              _buildDetailRow(
                  'Phone', booking.studentPhone!),
            if (booking.studentNotes != null)
              _buildDetailRow(
                  'Notes', booking.studentNotes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.openSans(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
      BuildContext context, bool isApprove) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isApprove ? 'Approve Booking' : 'Reject Request',
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isApprove
              ? 'Are you sure you want to approve this booking? This will notify the student.'
              : 'Are you sure you want to reject this request?',
          style: GoogleFonts.openSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: GoogleFonts.poppins(
                color: isApprove
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      if (isApprove) {
        await bookingProvider
            .approveBooking(booking.bookingId);
      } else {
        await bookingProvider
            .rejectBooking(booking.bookingId);
      }
    }
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Check-In',
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to mark this student as checked in? This will set the room status to Occupied.',
          style: GoogleFonts.openSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Check-In',
              style: GoogleFonts.poppins(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      final propertyProvider =
          context.read<PropertyProvider>();

      final success =
          await bookingProvider.checkInBooking(booking.bookingId);
      if (success && context.mounted) {
        await propertyProvider.updateRoomStatus(
          booking.propertyId,
          booking.roomId,
          RoomStatus.occupied,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Student checked in successfully.')),
          );
        }
      } else if (context.mounted &&
          bookingProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(bookingProvider.errorMessage!)),
        );
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Check-Out',
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to complete this booking stay? This will set the room status back to Vacant.',
          style: GoogleFonts.openSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Complete Stay',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      final propertyProvider =
          context.read<PropertyProvider>();

      final success = await bookingProvider
          .completeBooking(booking.bookingId);
      if (success && context.mounted) {
        await propertyProvider.updateRoomStatus(
          booking.propertyId,
          booking.roomId,
          RoomStatus.vacant,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Booking stay completed successfully.')),
          );
        }
      } else if (context.mounted &&
          bookingProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(bookingProvider.errorMessage!)),
        );
      }
    }
  }
}
