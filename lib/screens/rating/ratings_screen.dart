import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/rating_model.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../services/booking_service.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  BookingModel? _selectedBooking;
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _reviewController.addListener(() {
      setState(() {
        _charCount = _reviewController.text.length;
      });
    });

    // Subscribe to student ratings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<PropertyProvider>().subscribeToStudentRatings(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedBooking == null || _rating == 0) return;

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final propertyProvider = context.read<PropertyProvider>();

    try {
      final success = await propertyProvider.submitRating(
        bookingId: _selectedBooking!.bookingId,
        propertyId: _selectedBooking!.propertyId,
        studentId: authProvider.user!.uid,
        rating: _rating,
        review: _reviewController.text.trim().isNotEmpty ? _reviewController.text.trim() : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        setState(() {
          _selectedBooking = null;
          _rating = 0;
          _reviewController.clear();
        });
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 60 : 24,
          vertical: isDesktop ? 48 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            const Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your feedback to help other tenants make informed decisions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),

            // Main Content
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: _buildSubmitSection()),
                  const SizedBox(width: 48),
                  Expanded(flex: 5, child: _buildPreviousReviewsSection()),
                ],
              )
            else
              Column(
                children: [
                  _buildSubmitSection(),
                  const SizedBox(height: 48),
                  _buildPreviousReviewsSection(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitSection() {
    final authProvider = context.watch<AuthProvider>();
    final bookingService = BookingService();

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
            'Submit a Review',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 32),

          // Boarding House Selection
          const Text(
            'Select Boarding House *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<BookingModel>>(
            stream: bookingService.getStudentBookings(authProvider.user!.uid),
            builder: (context, snapshot) {
              final bookings = snapshot.data
                      ?.where((b) =>
                          b.status == BookingStatus.approved ||
                          b.status == BookingStatus.completed)
                      .toList() ??
                  [];

              if (bookings.isEmpty) {
                return _buildNoApprovedBookingsBanner();
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFBFBFB),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BookingModel>(
                    value: _selectedBooking,
                    isExpanded: true,
                    hint: const Text('Choose a boarding house to review...'),
                    items: bookings.map((booking) {
                      return DropdownMenuItem(
                        value: booking,
                        child: Text(booking.propertyName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedBooking = value);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Rating
          const Text(
            'Your Rating *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 48,
                  color: index < _rating ? const Color(0xFFFFB800) : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // Review Text
          const Text(
            'Your Review *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Share your experience about this boarding house...',
              filled: true,
              fillColor: const Color(0xFFFBFBFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF5287B2)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_charCount characters',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_selectedBooking == null || _rating == 0 || _isSubmitting)
                  ? null
                  : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5287B2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send_rounded, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoApprovedBookingsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE58F)),
      ),
      child: Text(
        'You need to have an approved booking before you can submit a rating.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.amber[900],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreviousReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Previous Reviews',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B16),
          ),
        ),
        const SizedBox(height: 32),
        Consumer<PropertyProvider>(
          builder: (context, provider, child) {
            final reviews = provider.studentRatings;

            if (reviews.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(reviews[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(RatingModel rating) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, child) {
        // Find property in the current list if available
        final property = propertyProvider.properties.firstWhere(
          (p) => p.propertyId == rating.propertyId,
          orElse: () => PropertyModel(
            propertyId: rating.propertyId,
            ownerId: '',
            name: 'Boarding House', // Fallback name
            address: '',
            lat: 0,
            lng: 0,
            genderOrientation: GenderOrientation.mixed,
            amenities: [],
            priceRange: PriceRange(min: 0, max: 0),
            status: PropertyStatus.verified,
            lastUpdated: DateTime.now(),
          ),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B16),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(rating.createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 20,
                    color: index < rating.rating ? const Color(0xFFFFB800) : Colors.grey[300],
                  );
                }),
              ),
              if (rating.review != null) ...[
                const SizedBox(height: 16),
                Text(
                  rating.review!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
