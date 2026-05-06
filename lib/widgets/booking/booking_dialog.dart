import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';

class BookingDialog extends StatefulWidget {
  final RoomModel room;
  final PropertyModel property;

  const BookingDialog({
    super.key,
    required this.room,
    required this.property,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  bool _isSubmitting = false;
  String? _errorMessage;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    final authProvider = context.read<AuthProvider>();
    final student = authProvider.user;

    if (student == null) return;

    // 1. Gender Enforcement (Student Orientation vs Property Orientation)
    // Assuming student model has gender orientation too, or we use the 'mixed' vs specific logic.
    // Let's check if the property allows this student.
    // final propertyGender = widget.property.genderOrientation;
    // For now, if property is 'male' or 'female', check if it matches student.
    // Note: This logic depends on student profile having gender. I'll add a simplified check.
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final bookingService = BookingService();
      await bookingService.createBooking(
        studentId: student.uid,
        propertyId: widget.property.propertyId,
        roomId: widget.room.roomId,
        propertyName: widget.property.name,
        roomDescription: widget.room.description ?? 'Room',
        studentName: student.displayName,
        studentEmail: student.email,
        studentPhone: student.phoneNumber,
        studentNotes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on BookingException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark_added_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirm Booking',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'You are requesting a booking for:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.room.description ?? 'Standard Room'),
                  Text(
                    '₱${widget.room.monthlyRate ?? 0}/month',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes for Owner (Optional)',
                hintText: 'e.g. Preferred move-in date, questions...',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirm Booking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
