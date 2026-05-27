import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/booking_provider.dart';
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
        final idsChanged =
            _lastPropertyIds == null ||
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

                        // Pending Requests Section
                        _buildSectionTitle(
                          'Pending Requests',
                          badgeText: pendingBookings.isNotEmpty
                              ? '${pendingBookings.length} Awaiting Response'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (pendingBookings.isEmpty)
                          _buildEmptyState('No pending requests')
                        else
                          ...pendingBookings.map(
                            (b) =>
                                _OwnerBookingCard(booking: b, isPending: true),
                          ),

                        const SizedBox(height: 48),

                        // Processed Requests Section
                        _buildSectionTitle('Processed Requests'),
                        const SizedBox(height: 16),
                        if (processedBookings.isEmpty)
                          _buildEmptyState('No processed requests yet')
                        else
                          ...processedBookings.map(
                            (b) =>
                                _OwnerBookingCard(booking: b, isPending: false),
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
          backgroundColor: const Color(0xFFF8FBFD),
          appBar: isDesktop
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(80),
                  child: OwnerTopNavBar(currentRoute: 'Booking Requests'),
                )
              : AppBar(
                  title: const Text('Booking Requests'),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D1B16),
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
        const Text(
          'Booking Requests',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B16),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review and manage tenant booking requests for your properties',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B16),
          ),
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Color(0xFFD97706),
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
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
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
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

  const _OwnerBookingCard({required this.booking, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (!isPending) return _buildProcessedCard(context);
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHovered ? const Color(0xFF5287B2).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
                width: isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered 
                      ? const Color(0xFF5287B2).withValues(alpha: 0.08) 
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isHovered ? 20 : 12,
                  offset: Offset(0, isHovered ? 8 : 4),
                ),
              ],
            ),
            transform: Matrix4.translationValues(0.0, isHovered ? -3.0 : 0.0, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Info Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF5287B2).withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF5287B2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.studentName,
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1D1B16),
                                  ),
                                ),
                                Text(
                                  'Booking Request #${booking.bookingId.substring(0, 5).toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 13,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Pending Review',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      const SizedBox(height: 20),
                      // Info Grid/Row
                      if (isMobile)
                        Column(
                          children: [
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.home_outlined,
                                  'Property',
                                  booking.propertyName,
                                ),
                                _buildInfoItem(
                                  Icons.calendar_today_outlined,
                                  'Requested',
                                  DateFormat('MMM d, yyyy').format(booking.requestedAt),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
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
                                  onTap: () => _showTenantDetails(context),
                                ),
                              ],
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
                              DateFormat('MMM d, yyyy').format(booking.requestedAt),
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
                              onTap: () => _showTenantDetails(context),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Premium rounded buttons side-by-side inside card padding
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleAction(context, false),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject Request'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleAction(context, true),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve Booking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

    switch (status) {
      case BookingStatus.approved:
        statusIcon = Icons.check_circle;
        badgeBgColor = const Color(0xFFECFDF5);
        badgeTextColor = const Color(0xFF10B981);
        break;
      case BookingStatus.completed:
        statusIcon = Icons.done_all;
        badgeBgColor = const Color(0xFFEFF6FF);
        badgeTextColor = const Color(0xFF3B82F6);
        break;
      case BookingStatus.rejected:
        statusIcon = Icons.cancel;
        badgeBgColor = const Color(0xFFFEF2F2);
        badgeTextColor = const Color(0xFFEF4444);
        break;
      case BookingStatus.cancelled:
        statusIcon = Icons.cancel_outlined;
        badgeBgColor = const Color(0xFFF3F4F6);
        badgeTextColor = const Color(0xFF6B7280);
        break;
      case BookingStatus.expired:
        statusIcon = Icons.history;
        badgeBgColor = const Color(0xFFFFFBEB);
        badgeTextColor = const Color(0xFFD97706);
        break;
      default:
        statusIcon = Icons.help_outline;
        badgeBgColor = const Color(0xFFF3F4F6);
        badgeTextColor = const Color(0xFF6B7280);
    }

    final propertyProvider = context.watch<PropertyProvider>();
    final roomStatus = propertyProvider.getRoomStatusFromCache(booking.roomId);

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
              border: Border.all(
                color: isHovered ? const Color(0xFF5287B2).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
                width: isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered 
                      ? const Color(0xFF5287B2).withValues(alpha: 0.06) 
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isHovered ? 16 : 8,
                  offset: Offset(0, isHovered ? 6 : 4),
                ),
              ],
            ),
            transform: Matrix4.translationValues(0.0, isHovered ? -2.0 : 0.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: badgeBgColor,
                      child: Icon(statusIcon, color: badgeTextColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.studentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1B16),
                            ),
                          ),
                          Text(
                            booking.propertyName,
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, yyyy').format(booking.requestedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.payments_outlined,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '₱${NumberFormat('#,###').format(booking.monthlyRate != 0 ? booking.monthlyRate : 5500)}/month',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.statusLabel,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (status == BookingStatus.approved) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (roomStatus != RoomStatus.occupied)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: OutlinedButton.icon(
                            onPressed: () => _handleCheckIn(context),
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: const Text('Check-In Student'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () => _handleCheckOut(context),
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text('Complete Stay (Check-Out)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
              Icon(icon, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLink
                    ? const Color(0xFF5287B2)
                    : const Color(0xFF1D1B16),
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTenantDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tenant Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', booking.studentEmail),
            if (booking.studentPhone != null)
              _buildDetailRow('Phone', booking.studentPhone!),
            if (booking.studentNotes != null)
              _buildDetailRow('Notes', booking.studentNotes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, bool isApprove) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Booking' : 'Reject Request'),
        content: Text(
          isApprove
              ? 'Are you sure you want to approve this booking? This will notify the student.'
              : 'Are you sure you want to reject this request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: TextStyle(color: isApprove ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      if (isApprove) {
        await bookingProvider.approveBooking(booking.bookingId);
      } else {
        await bookingProvider.rejectBooking(booking.bookingId);
      }
    }
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Student Check-In'),
        content: const Text(
          'Are you sure you want to mark this student as checked in? This will set the room status to Occupied.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Check-In',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      final propertyProvider = context.read<PropertyProvider>();

      final success = await bookingProvider.checkInBooking(booking.bookingId);
      if (success && context.mounted) {
        await propertyProvider.updateRoomStatus(
          booking.propertyId,
          booking.roomId,
          RoomStatus.occupied,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student checked in successfully.')),
          );
        }
      } else if (context.mounted && bookingProvider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(bookingProvider.errorMessage!)));
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Check-Out / Complete Stay'),
        content: const Text(
          'Are you sure you want to complete this booking stay? This will set the room status back to Vacant and mark the booking as Completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Complete Stay',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      final propertyProvider = context.read<PropertyProvider>();

      final success = await bookingProvider.completeBooking(booking.bookingId);
      if (success && context.mounted) {
        await propertyProvider.updateRoomStatus(
          booking.propertyId,
          booking.roomId,
          RoomStatus.vacant,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking stay completed successfully.'),
            ),
          );
        }
      } else if (context.mounted && bookingProvider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(bookingProvider.errorMessage!)));
      }
    }
  }
}
