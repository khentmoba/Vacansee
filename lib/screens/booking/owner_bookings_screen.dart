import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  BookingStatus? _filterStatus;
  final Set<String> _selectedBookingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final propertyProvider = context.read<PropertyProvider>();

      if (authProvider.user != null) {
        propertyProvider.loadOwnerProperties(authProvider.user!.uid);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final propertyProvider = context.read<PropertyProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (propertyProvider.properties.isNotEmpty) {
      final propertyIds = propertyProvider.properties
          .map((p) => p.propertyId)
          .toList();
      bookingProvider.loadOwnerBookings(propertyIds);
      bookingProvider.loadPendingCount(propertyIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final pendingCount = bookingProvider.pendingCount;

    var bookings = bookingProvider.bookings;
    if (_filterStatus != null) {
      bookings = bookings.where((b) => b.status == _filterStatus).toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Requests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review and manage tenant booking requests for your properties',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                // Stats Cards
                Row(
                  children: [
                    _buildStatCard(
                      bookings.length.toString(),
                      'Total Bookings',
                      const Color(0xFF5287B2),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      pendingCount.toString(),
                      'Pending',
                      const Color(0xFFFFA000),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      bookings
                          .where((b) => b.status == BookingStatus.approved)
                          .length
                          .toString(),
                      'Approved',
                      const Color(0xFF22C55E),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      bookings
                          .where((b) => b.status == BookingStatus.rejected)
                          .length
                          .toString(),
                      'Rejected',
                      const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', null, bookings.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Pending',
                        BookingStatus.pending,
                        pendingCount,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Approved',
                        BookingStatus.approved,
                        bookings
                            .where((b) => b.status == BookingStatus.approved)
                            .length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Rejected',
                        BookingStatus.rejected,
                        bookings
                            .where((b) => b.status == BookingStatus.rejected)
                            .length,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bookings list
          Expanded(
            child: bookingProvider.isLoading
                ? _buildShimmerLoader()
                : bookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(
                        booking: booking,
                        isSelected: _selectedBookingIds.contains(booking.bookingId),
                        onToggleSelection: () => _toggleSelection(booking.bookingId),
                        onApprove: () => _handleApprove(booking),
                        onReject: () => _handleReject(booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, BookingStatus? status, int count) {
    final isSelected = _filterStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _filterStatus = isSelected ? null : status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5287B2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5287B2) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '($count)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No booking requests',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String bookingId) {
    setState(() {
      if (_selectedBookingIds.contains(bookingId)) {
        _selectedBookingIds.remove(bookingId);
      } else {
        _selectedBookingIds.add(bookingId);
      }
    });
  }

  Future<void> _handleApprove(BookingModel booking) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Booking?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve booking request from ${booking.studentName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g., Contact me at...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<BookingProvider>();
      final success = await provider.approveBooking(
        booking.bookingId,
        ownerNotes: notesController.text.isEmpty ? null : notesController.text,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking approved')),
        );
      }
    }
  }

  Future<void> _handleReject(BookingModel booking) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject booking request from ${booking.studentName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<BookingProvider>();
      final success = await provider.rejectBooking(
        booking.bookingId,
        ownerNotes: notesController.text.isEmpty ? null : notesController.text,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rejected')),
        );
      }
    }
  }
}

class _BookingCard extends StatefulWidget {
  final BookingModel booking;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingCard({
    required this.booking,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isPending = widget.booking.status == BookingStatus.pending;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.05),
              blurRadius: _isHovered ? 16 : 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF5287B2).withValues(alpha: 0.5)
                : _isHovered
                    ? const Color(0xFF5287B2).withValues(alpha: 0.3)
                    : Colors.transparent,
            width: widget.isSelected ? 2 : 1.5,
          ),
        ),
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _isHovered ? -4.0 : 0.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox for pending bookings
            if (isPending)
              InkWell(
                onTap: widget.onToggleSelection,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? const Color(0xFF5287B2)
                              : Colors.transparent,
                          border: Border.all(
                            color: widget.isSelected
                                ? const Color(0xFF5287B2)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: widget.isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isSelected ? 'Selected' : 'Select for batch action',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isSelected
                              ? const Color(0xFF5287B2)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with student info and status
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5287B2).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF5287B2)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.booking.studentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1B16),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Booking ID: #${widget.booking.bookingId.substring(0, 6).toUpperCase()}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPending
                              ? const Color(0xFFFEF3C7)
                              : widget.booking.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPending ? Icons.schedule : Icons.check_circle,
                              size: 14,
                              color: isPending
                                  ? const Color(0xFFD97706)
                                  : widget.booking.statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isPending ? 'Pending Review' : widget.booking.statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isPending
                                    ? const Color(0xFFD97706)
                                    : widget.booking.statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Property info
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.home_outlined,
                        'Property',
                        widget.booking.propertyName,
                        'Owner: You',
                      ),
                      const SizedBox(width: 24),
                      _buildInfoItem(
                        Icons.calendar_today_outlined,
                        'Request Date',
                        '${widget.booking.requestedAt.day} ${_getMonthName(widget.booking.requestedAt.month)} ${widget.booking.requestedAt.year}',
                        null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons for pending bookings
            if (isPending) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve Booking'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    String? subValue,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1B16),
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
