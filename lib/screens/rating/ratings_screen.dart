import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: isDesktop ? 60 : 24,
          right: isDesktop ? 60 : 24,
          top: isDesktop ? 48 : 32,
          bottom: isDesktop ? 48 : 140,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Text(
              'Rate Your Experience',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your feedback to help other tenants make informed decisions',
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: AppColors.textSecondary,
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
        boxShadow: const [AppShadows.sm],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit a Review',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Boarding House Selection
          Text(
            'Select Boarding House *',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.secondaryContainer,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BookingModel>(
                    value: _selectedBooking,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    hint: Text('Choose a boarding house to review...', style: GoogleFonts.workSans(color: AppColors.textSecondary, fontSize: 14)),
                    items: bookings.map((booking) {
                      return DropdownMenuItem(
                        value: booking,
                        child: Text(booking.propertyName, style: GoogleFonts.workSans(color: AppColors.textPrimary)),
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
          Text(
            'Your Rating *',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final active = index < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  active ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 48,
                  color: active ? Colors.amber : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // Review Text
          Text(
            'Your Review *',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 6,
            style: GoogleFonts.workSans(fontSize: 14.5, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Share your experience about this boarding house...',
              hintStyle: GoogleFonts.workSans(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: AppColors.secondaryContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_charCount characters',
            style: GoogleFonts.workSans(fontSize: 12, color: AppColors.textMuted),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Submit Review',
                          style: GoogleFonts.outfit(
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
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Text(
        'You need to have an approved booking before you can submit a rating.',
        style: GoogleFonts.workSans(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreviousReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Previous Reviews',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                      Icon(Icons.rate_review_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: GoogleFonts.workSans(color: AppColors.textMuted, fontSize: 16),
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
            boxShadow: const [AppShadows.sm],
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    property.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(rating.createdAt),
                    style: GoogleFonts.workSans(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 20,
                    color: index < rating.rating ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
              if (rating.review != null) ...[
                const SizedBox(height: 16),
                Text(
                  rating.review!,
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    color: AppColors.textSecondary,
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
