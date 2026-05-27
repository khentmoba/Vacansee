import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import '../../widgets/ratings/rate_property_dialog.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final student = authProvider.user;

    if (student == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please log in',
            style: GoogleFonts.workSans(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          return StreamBuilder<List<BookingModel>>(
            stream: bookingService.getStudentBookings(student.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.workSans(color: AppColors.error),
                  ),
                );
              }

              final allBookings = snapshot.data ?? [];
              
              // Client-side stats calculation
              final pendingCount = allBookings.where((b) => b.status == BookingStatus.pending).length;
              final approvedCount = allBookings.where((b) => b.status == BookingStatus.approved).length;
              final completedCount = allBookings.where((b) => b.status == BookingStatus.completed).length;
              final totalCount = allBookings.length;

              // Filtering logic
              final filteredBookings = allBookings.where((booking) {
                if (_selectedFilter == 'All') return true;
                if (_selectedFilter == 'Pending') return booking.status == BookingStatus.pending;
                if (_selectedFilter == 'Approved') return booking.status == BookingStatus.approved;
                if (_selectedFilter == 'Completed') return booking.status == BookingStatus.completed;
                if (_selectedFilter == 'Cancelled/Rejected') {
                  return booking.status == BookingStatus.cancelled || booking.status == BookingStatus.rejected || booking.status == BookingStatus.expired;
                }
                return true;
              }).toList();

              return CustomScrollView(
                slivers: [
                  // Page Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Bookings',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and track all your rental requests',
                            style: GoogleFonts.workSans(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Dashboard Row
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
                      child: Row(
                        children: [
                          _buildStatCard('Pending', pendingCount, AppColors.warning, Icons.hourglass_empty_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Approved', approvedCount, AppColors.success, Icons.check_circle_outline_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Completed', completedCount, AppColors.primary, Icons.done_all_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Total Bookings', totalCount, AppColors.textMuted, Icons.bookmarks_rounded),
                        ],
                      ),
                    ),
                  ),

                  // Filter Pills Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: 20,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            'Pending',
                            'Approved',
                            'Completed',
                            'Cancelled/Rejected',
                          ].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  filter,
                                  style: GoogleFonts.workSans(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : AppColors.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Bookings List
                  if (filteredBookings.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: isDesktop ? 60 : 20,
                        right: isDesktop ? 60 : 20,
                        bottom: isDesktop ? 40 : 140, // clear floating bottom bar
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _BookingCard(booking: filteredBookings[index]);
                          },
                          childCount: filteredBookings.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color accentColor, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.sm],
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_outline_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookings Found',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookings fitting the status filter "$_selectedFilter" will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  String? _propertyCoverImage;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();
    _fetchCoverImage();
  }

  Future<void> _fetchCoverImage() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('properties')
          .select('images')
          .eq('id', widget.booking.propertyId)
          .maybeSingle();

      if (response != null && response['images'] != null) {
        final List<dynamic> imgs = response['images'];
        if (imgs.isNotEmpty) {
          if (mounted) {
            setState(() {
              _propertyCoverImage = imgs.first.toString();
              _loadingImage = false;
            });
            return;
          }
        }
      }
    } catch (_) {
      // Fallback silent
    }
    if (mounted) {
      setState(() {
        _loadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.sm],
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left thumbnail image or gradient initials fallback
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.background,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _loadingImage
                        ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                        : _propertyCoverImage != null
                            ? Image.network(
                                _propertyCoverImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildInitialsPlaceholder(),
                              )
                            : _buildInitialsPlaceholder(),
                  ),
                  const SizedBox(width: 16),
                  
                  // Center information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.booking.propertyName,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking.roomDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Metadata row
                        if (isDesktop)
                          Row(
                            children: [
                              _buildMetaItem(Icons.calendar_today_rounded, DateFormat('MMM d, yyyy').format(widget.booking.requestedAt)),
                              const SizedBox(width: 20),
                              _buildMetaItem(Icons.payments_outlined, '₱${widget.booking.monthlyRate}/mo'),
                              const SizedBox(width: 20),
                              _buildMetaItem(Icons.tag_rounded, widget.booking.bookingId.substring(0, 8).toUpperCase()),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildMetaItem(Icons.calendar_today_rounded, DateFormat('MMM d, yyyy').format(widget.booking.requestedAt)),
                                  const SizedBox(width: 16),
                                  _buildMetaItem(Icons.payments_outlined, '₱${widget.booking.monthlyRate}/mo'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildMetaItem(Icons.tag_rounded, widget.booking.bookingId.substring(0, 8).toUpperCase()),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Custom Info banner
              _buildInfoBanner(),

              // Quick Actions
              if (widget.booking.status == BookingStatus.approved || widget.booking.status == BookingStatus.completed) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View Lease details',
                        style: GoogleFonts.workSans(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showRatingDialog(context),
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: const Text('Rate Boarding House'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
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
      ),
    );
  }

  Widget _buildInitialsPlaceholder() {
    final initials = widget.booking.propertyName.isNotEmpty
        ? widget.booking.propertyName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : 'VB';
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.workSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = widget.booking.status;
    Color bgColor;
    Color textColor;

    switch (status) {
      case BookingStatus.pending:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        break;
      case BookingStatus.approved:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case BookingStatus.completed:
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        break;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
      case BookingStatus.expired:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        widget.booking.statusLabel,
        style: GoogleFonts.workSans(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    String message;
    if (widget.booking.status == BookingStatus.pending) {
      message = "Under owner review. Expiration checks in 48 hours.";
    } else if (widget.booking.status == BookingStatus.approved) {
      message = "Approved! Reach out to the owner to proceed with check-in.";
    } else if (widget.booking.status == BookingStatus.rejected) {
      message = "This request was rejected. Feel free to explore other listings.";
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.workSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatePropertyDialog(booking: widget.booking),
    );
  }
}
