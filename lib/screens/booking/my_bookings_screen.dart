import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
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
                return Center(child: Text('Error: ${snapshot.error}'));
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
                          const Text(
                            'My Bookings',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D1B16),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and track all your rental requests',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
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
                          _buildStatCard('Pending', pendingCount, const Color(0xFFF59E0B), Icons.hourglass_empty_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Approved', approvedCount, const Color(0xFF10B981), Icons.check_circle_outline_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Completed', completedCount, const Color(0xFF5287B2), Icons.done_all_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Total Bookings', totalCount, const Color(0xFF6B7280), Icons.bookmarks_rounded),
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
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF5287B2),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
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
              decoration: BoxDecoration(
                color: const Color(0xFFEDF5FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_outline_rounded, size: 48, color: Color(0xFF5287B2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Bookings Found',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookings fitting the status filter "$_selectedFilter" will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
                      color: const Color(0xFFF3F4F6),
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
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
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Lease details', style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showRatingDialog(context),
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: const Text('Rate Boarding House'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5287B2),
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
        gradient: LinearGradient(
          colors: [Color(0xFF5287B2), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
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
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
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
        bgColor = const Color(0xFFFFF7E6);
        textColor = const Color(0xFFD97706);
        break;
      case BookingStatus.approved:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        break;
      case BookingStatus.completed:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        break;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
      case BookingStatus.expired:
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
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
        style: TextStyle(
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF5287B2)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF4B5563),
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
