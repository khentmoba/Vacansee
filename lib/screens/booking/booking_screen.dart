import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import 'booking_success_screen.dart';

class BookingScreen extends StatefulWidget {
  final PropertyModel property;
  final RoomModel? room;

  const BookingScreen({super.key, required this.property, this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  int _selectedDuration = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5287B2),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D1B16),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a move-in date')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final student = authProvider.user;

    try {
      final bookingService = BookingService();
      await bookingService.createBooking(
        studentId: student!.uid,
        propertyId: widget.property.propertyId,
        roomId: widget.room?.roomId,
        propertyName: widget.property.name,
        roomDescription: widget.room?.description ?? 'Room',
        studentName: _nameController.text.trim(),
        studentEmail: _emailController.text.trim(),
        studentPhone: _phoneController.text.trim(),
        studentGender: student.gender ?? '',
        propertyGenderOrientation: widget.property.genderOrientation.name,
        studentNotes: _notesController.text.trim(),
        moveInDate: _selectedDate,
        durationMonths: _selectedDuration,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingSuccessScreen(propertyName: widget.property.name),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit booking: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D1B16)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Request',
          style: TextStyle(
            color: Color(0xFF1D1B16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 60 : 24,
          vertical: isDesktop ? 48 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Booking',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 48),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildInformationForm()),
                  const SizedBox(width: 48),
                  Expanded(flex: 4, child: _buildBookingSummary()),
                ],
              )
            else
              Column(
                children: [
                  _buildInformationForm(),
                  const SizedBox(height: 32),
                  _buildBookingSummary(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 32),

            _buildInputField(
              label: 'Full Name *',
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 24),

            _buildInputField(
              label: 'Email Address *',
              controller: _emailController,
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            _buildInputField(
              label: 'Phone Number *',
              controller: _phoneController,
              hint: '09XX XXX XXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Move-in Date
            const Text(
              'Move-in Date *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                hintText: 'mm/dd/yyyy',
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                filled: true,
                fillColor: const Color(0xFFFBFBFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Duration
            const Text(
              'Duration (Months) *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedDuration,
                  isExpanded: true,
                  items: [1, 3, 6, 12].map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text('$value Month${value > 1 ? 's' : ''}'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDuration = value!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInputField(
              label: 'Special Requests (Optional)',
              controller: _notesController,
              hint: 'Any special requests or questions for the owner...',
              maxLines: 4,
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Booking Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: const Color(0xFFFBFBFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5287B2)),
            ),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    final double monthlyRate = widget.room?.monthlyRate?.toDouble() ?? widget.property.monthlyPrice.toDouble();
    final double total = monthlyRate * _selectedDuration;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 32),

          // Property Info
          if (widget.property.coverImageUrl != null)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(widget.property.coverImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            widget.property.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.property.address,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Price Details
          _buildSummaryRow(
            'Monthly Rate:',
            '₱${NumberFormat('#,###').format(monthlyRate)}',
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Duration:',
            '$_selectedDuration Month${_selectedDuration > 1 ? 's' : ''}',
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₱${NumberFormat('#,###').format(total)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5287B2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Note Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE58F)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.amber[900],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Note: This is a booking request. Payment will be processed after owner approval.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B16),
          ),
        ),
      ],
    );
  }
}
