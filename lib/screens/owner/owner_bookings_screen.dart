import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/booking_provider.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

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
        // Only load if the IDs have changed
        final idsChanged = _lastPropertyIds == null ||
            _lastPropertyIds!.length != ids.length ||
            !ids.every((id) => _lastPropertyIds!.contains(id));

        if (idsChanged) {
          _lastPropertyIds = ids;
          // loadOwnerBookings cancels old sub, so it's safe to call.
          // We also load the pending count for the dashboard badge.
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
      ),
      body: bookingProvider.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(bookingProvider.errorMessage!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _lastPropertyIds = null;
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : bookingProvider.isLoading && bookings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No booking requests found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _OwnerBookingCard(booking: booking);
                  },
                ),
    );
  }
}

class _OwnerBookingCard extends StatelessWidget {
  final BookingModel booking;

  const _OwnerBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    booking.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(
                      color: booking.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Property: ${booking.propertyName}'),
                Text('Room: ${booking.roomDescription}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(booking.studentEmail, style: const TextStyle(fontSize: 12)),
                    if (booking.studentPhone != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(booking.studentPhone!, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (booking.studentNotes != null && booking.studentNotes!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey[50],
              child: Text(
                'Student Note: ${booking.studentNotes}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
          if (booking.status == BookingStatus.pending)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleAction(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAction(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, bool isApprove) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Booking' : 'Decline Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isApprove
                ? 'Approving will mark the room as Occupied and notify the student.'
                : 'Declining will notify the student.'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Add a note (optional)',
                hintText: 'e.g. Please visit tomorrow...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isApprove ? 'Approve' : 'Decline',
              style: TextStyle(color: isApprove ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookingProvider = context.read<BookingProvider>();
      if (isApprove) {
        await bookingProvider.approveBooking(
          booking.bookingId,
          ownerNotes: noteController.text.trim(),
        );
      } else {
        await bookingProvider.rejectBooking(
          booking.bookingId,
          ownerNotes: noteController.text.trim(),
        );
      }
    }
  }
}
