import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';
import 'widgets/rejection_dialog.dart';

class AdminPropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const AdminPropertyDetailScreen({super.key, required this.property});

  @override
  State<AdminPropertyDetailScreen> createState() => _AdminPropertyDetailScreenState();
}

class _AdminPropertyDetailScreenState extends State<AdminPropertyDetailScreen> {
  int _selectedImageIndex = 0;
  final PageController _mobilePageController = PageController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PropertyProvider>();
      provider.loadRooms(widget.property.propertyId);
      provider.loadPropertyReviews(widget.property.propertyId);
    });
  }

  @override
  void dispose() {
    _mobilePageController.dispose();
    super.dispose();
  }

  void _shareListing() {
    Clipboard.setData(ClipboardData(text: 'https://vacansee.com/property/${widget.property.propertyId}')).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Row(
              children: [Icon(Icons.link_rounded, color: Colors.white), SizedBox(width: 12), Text('Listing link copied!', style: TextStyle(fontWeight: FontWeight.w600))],
            ),
          ),
        );
      }
    });
  }

  Future<void> _approveProperty() async {
    setState(() => _isProcessing = true);
    try {
      await context.read<PropertyProvider>().moderateProperty(propertyId: widget.property.propertyId, status: PropertyStatus.verified);
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property approved'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _rejectProperty() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => const RejectionDialog(),
    );
    if (reason == null || !mounted) return;
    setState(() => _isProcessing = true);
    try {
      await context.read<PropertyProvider>().moderateProperty(propertyId: widget.property.propertyId, status: PropertyStatus.rejected, reason: reason);
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property rejected'), backgroundColor: AppColors.warning));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteProperty() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing? This action can be undone by restoring the property.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isProcessing = true);
    try {
      await context.read<PropertyProvider>().deleteProperty(widget.property.propertyId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted'), backgroundColor: AppColors.warning));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final rooms = propertyProvider.rooms;
    final vacantRooms = rooms.where((r) => r.status == RoomStatus.vacant).length;
    final totalRooms = rooms.length;
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Back to Listings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              titleSpacing: 0,
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: isDesktop ? 60 : 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdminBanner(),
                  if (!isDesktop) _buildMobileGallery(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24, vertical: isDesktop ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop) ...[
                          _buildTitleHeader(),
                          const SizedBox(height: 24),
                          _buildDesktopGallery(),
                          const SizedBox(height: 32),
                        ] else ...[
                          _buildMobileTitleHeader(),
                        ],
                        const SizedBox(height: 16),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 65, child: _buildMainContent(propertyProvider, rooms)),
                              const SizedBox(width: 60),
                              Expanded(flex: 35, child: _buildAdminSidebar(vacantRooms, totalRooms, rooms)),
                            ],
                          )
                        else
                          _buildMainContent(propertyProvider, rooms),
                        const Divider(height: 60, thickness: 1, color: AppColors.border),
                        _buildReviewsSection(propertyProvider),
                        const Divider(height: 60, thickness: 1, color: AppColors.border),
                        _buildHostProfileCard(),
                        const Divider(height: 60, thickness: 1, color: AppColors.border),
                        _buildThingsToKnow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isDesktop) _buildMobileAdminBar(vacantRooms, totalRooms, rooms),
        ],
      ),
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Text('Admin View — Manage this listing',
              style: GoogleFonts.workSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const Spacer(),
          _buildStatusPill(widget.property.status),
        ],
      ),
    );
  }

  Widget _buildStatusPill(PropertyStatus status) {
    Color color;
    String label;
    switch (status) {
      case PropertyStatus.pending:
        color = AppColors.warning; label = 'PENDING'; break;
      case PropertyStatus.verified:
        color = AppColors.success; label = 'VERIFIED'; break;
      case PropertyStatus.rejected:
        color = AppColors.error; label = 'REJECTED'; break;
      case PropertyStatus.deleted:
        color = AppColors.textMuted; label = 'DELETED'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100), border: Border.all(color: color, width: 1)),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _buildMainContent(PropertyProvider propertyProvider, List<RoomModel> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHostHeader(),
        const Divider(height: 48, thickness: 1, color: AppColors.border),
        _buildKeyHighlights(propertyProvider),
        const Divider(height: 48, thickness: 1, color: AppColors.border),
        _buildAboutSection(),
        const Divider(height: 48, thickness: 1, color: AppColors.border),
        _buildRoomsSection(rooms),
        const Divider(height: 48, thickness: 1, color: AppColors.border),
        _buildAmenitiesSection(),
      ],
    );
  }

  Widget _buildTitleHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.property.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.6)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.star_rounded, size: 18, color: Colors.amber[700]),
              const SizedBox(width: 4),
              Text(widget.property.averageRating > 0 ? widget.property.averageRating.toStringAsFixed(1) : 'New',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              Text('· ${widget.property.reviewsCount} reviews',
                  style: const TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline)),
              const SizedBox(width: 8), const Text('·'), const SizedBox(width: 8),
              Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 4), const Text('Verified Listing', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(width: 8), const Text('·'), const SizedBox(width: 8),
              Expanded(child: Text(widget.property.address, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline))),
            ]),
          ]),
        ),
        TextButton.icon(
          onPressed: _shareListing,
          icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.textPrimary),
          label: const Text('Share', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }

  Widget _buildMobileTitleHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.property.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
      const SizedBox(height: 8),
      Row(children: [
        Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
        const SizedBox(width: 4),
        Text(widget.property.averageRating > 0 ? widget.property.averageRating.toStringAsFixed(1) : 'New',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(width: 4),
        Text('(${widget.property.reviewsCount} reviews)', style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 6), const Text('·'), const SizedBox(width: 6),
        Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
        const SizedBox(width: 2), const Text('Verified', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 6),
      Text(widget.property.address, style: const TextStyle(color: AppColors.textSecondary)),
    ]);
  }

  Widget _buildDesktopGallery() {
    final allImages = widget.property.images;
    if (allImages.isEmpty) return _buildPlaceholder();
    if (allImages.length == 1) {
      return ClipRRect(borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(imageUrl: allImages[0], height: 400, width: double.infinity, fit: BoxFit.contain,
            placeholder: (context, url) => _buildShimmerBox(height: 400), errorWidget: (context, url, error) => _buildPlaceholder()));
    }
    if (allImages.length >= 5) {
      return Container(height: 420, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias,
        child: Row(children: [
          Expanded(flex: 2, child: GestureDetector(onTap: () => setState(() => _selectedImageIndex = 0),
              child: CachedNetworkImage(imageUrl: allImages[0], height: double.infinity, fit: BoxFit.cover,
                  placeholder: (context, url) => _buildShimmerBox(), errorWidget: (context, url, error) => const Icon(Icons.broken_image)))),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Column(children: [
            Expanded(child: Row(children: [
              Expanded(child: CachedNetworkImage(imageUrl: allImages[1], height: double.infinity, fit: BoxFit.cover, placeholder: (context, url) => _buildShimmerBox())),
              const SizedBox(width: 8),
              Expanded(child: CachedNetworkImage(imageUrl: allImages[2], height: double.infinity, fit: BoxFit.cover, placeholder: (context, url) => _buildShimmerBox())),
            ])),
            const SizedBox(height: 8),
            Expanded(child: Row(children: [
              Expanded(child: CachedNetworkImage(imageUrl: allImages[3], height: double.infinity, fit: BoxFit.cover, placeholder: (context, url) => _buildShimmerBox())),
              const SizedBox(width: 8),
              Expanded(child: Stack(children: [
                Positioned.fill(child: CachedNetworkImage(imageUrl: allImages[4], fit: BoxFit.cover, placeholder: (context, url) => _buildShimmerBox())),
                Positioned(bottom: 16, right: 16,
                    child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.grid_view_rounded, size: 16, color: AppColors.textPrimary),
                        label: const Text('Show all photos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 2, side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
              ])),
            ])),
          ])),
        ]),
      );
    }
    return SizedBox(height: 300,
        child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: allImages.length, itemBuilder: (context, index) {
          return Container(width: 400, margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: allImages[index], fit: BoxFit.cover,
                      placeholder: (context, url) => _buildShimmerBox(), errorWidget: (context, url, error) => const Icon(Icons.image))));
        }));
  }

  Widget _buildMobileGallery() {
    final allImages = widget.property.images.isNotEmpty ? widget.property.images : [widget.property.coverImageUrl ?? ''];
    return Stack(children: [
      SizedBox(height: 280,
        child: PageView.builder(controller: _mobilePageController, itemCount: allImages.length,
            onPageChanged: (index) => setState(() => _selectedImageIndex = index),
            itemBuilder: (context, index) {
              final imgUrl = allImages[index];
              if (imgUrl.isEmpty) return Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.home_work_rounded, size: 64, color: Colors.grey)));
              return CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.contain,
                  placeholder: (context, url) => _buildShimmerBox(height: 280),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 48)));
            }),
      ),
      Positioned(top: MediaQuery.of(context).padding.top + 10, left: 16,
          child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)))),
      Positioned(top: MediaQuery.of(context).padding.top + 10, right: 16,
          child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary), onPressed: _shareListing))),
      if (allImages.length > 1)
        Positioned(bottom: 16, right: 16,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(4)),
                child: Text('${_selectedImageIndex + 1} / ${allImages.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
    ]);
  }

  Widget _buildHostHeader() {
    final ownerInit = widget.property.ownerName?.isNotEmpty == true ? widget.property.ownerName![0].toUpperCase() : 'O';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Boarding House hosted by ${widget.property.ownerName ?? "Owner"}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text('${widget.property.availableRooms} vacant rooms · ${widget.property.totalRooms} total rooms · Gender: ${widget.property.genderOrientation.name.toUpperCase()}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ]),
      ),
      const SizedBox(width: 16),
      Stack(children: [
        CircleAvatar(radius: 28, backgroundColor: AppColors.primaryContainer,
            child: Text(ownerInit, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))),
        Positioned(bottom: 0, right: 0,
            child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.verified_rounded, size: 18, color: AppColors.primary))),
      ]),
    ]);
  }

  Widget _buildKeyHighlights(PropertyProvider provider) {
    final timeStr = provider.getTimeSinceLastUpdate(widget.property.propertyId) ?? 'Updated recently';
    return Column(children: [
      _buildHighlightItem(Icons.bolt_rounded, 'Real-time Vacancy Updates', 'This property updates room availability directly. Last checked: $timeStr.'),
      const SizedBox(height: 24),
      _buildHighlightItem(Icons.gpp_good_rounded, 'Verified by VacanSee', 'VacanSee representatives verified this boarding house spec, location, and owner identity.'),
      const SizedBox(height: 24),
      _buildHighlightItem(Icons.wc_rounded, 'Gender Policy: ${widget.property.genderOrientation.name}', 'This house strictly houses ${widget.property.genderOrientation.name} students.'),
    ]);
  }

  Widget _buildHighlightItem(IconData icon, String title, String subtitle) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 28, color: AppColors.primary),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
      ])),
    ]);
  }

  Widget _buildAboutSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('About this space', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      Text(
        widget.property.description?.isNotEmpty == true
            ? widget.property.description!
            : 'Welcome to ${widget.property.name}! This verified boarding house provides convenient lodging for students in Cagayan de Oro City.',
        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6),
      ),
    ]);
  }

  Widget _buildRoomsSection(List<RoomModel> rooms) {
    if (rooms.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Where you'll sleep / Rooms", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      SizedBox(height: 170,
        child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: rooms.length, itemBuilder: (context, index) {
          final room = rooms[index];
          final isVacant = room.status == RoomStatus.vacant;
          return Container(width: 220, margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Icon(Icons.bed_rounded, color: isVacant ? AppColors.primary : Colors.grey),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isVacant ? AppColors.primaryContainer : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(isVacant ? 'VACANT' : 'OCCUPIED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isVacant ? AppColors.primary : Colors.red))),
              ]),
              const Spacer(),
              Text(room.description?.isNotEmpty == true ? room.description! : 'Standard Student Room',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Capacity: ${room.capacity} students', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Text('₱${room.monthlyRate}/month', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
            ]),
          );
        }),
      ),
    ]);
  }

  Widget _buildAmenitiesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('What this place offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 20),
      Wrap(spacing: 16, runSpacing: 16, children: widget.property.amenities.map((amenity) => _buildAmenityItem(amenity)).toList()),
    ]);
  }

  Widget _buildAmenityItem(String amenity) {
    IconData icon;
    switch (amenity.toLowerCase()) {
      case 'wifi': icon = Icons.wifi; break;
      case 'air conditioning': case 'ac': icon = Icons.ac_unit_rounded; break;
      case 'kitchen': icon = Icons.restaurant_rounded; break;
      case 'laundry': case 'laundry area': icon = Icons.local_laundry_service_rounded; break;
      case 'security': case '24/7 security': icon = Icons.security_rounded; break;
      case 'parking': icon = Icons.local_parking_rounded; break;
      case 'study area': icon = Icons.menu_book_rounded; break;
      default: icon = Icons.check_circle_outline_rounded;
    }
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(width: 16),
          Text(amenity, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        ]));
  }

  Widget _buildAdminSidebar(int vacantRooms, int totalRooms, List<RoomModel> rooms) {
    final status = widget.property.status;
    final isPending = status == PropertyStatus.pending;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.shield_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Admin Actions', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 20),
        _buildSidebarRow('Status', _statusLabel(widget.property.status), valueColor: _statusColor(widget.property.status)),
        const SizedBox(height: 12),
        _buildSidebarRow('Owner', widget.property.ownerName ?? 'Unknown'),
        const SizedBox(height: 12),
        _buildSidebarRow('Gender', widget.property.genderOrientation.name.toUpperCase()),
        const SizedBox(height: 12),
        _buildSidebarRow('Vacant Rooms', '$vacantRooms / $totalRooms'),
        const Divider(height: 28, thickness: 1, color: AppColors.border),
        if (isPending) ...[
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _approveProperty,
              icon: _isProcessing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_rounded),
              label: const Text('Approve Listing', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _rejectProperty,
              icon: const Icon(Icons.cancel_rounded),
              label: const Text('Reject Listing', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const Divider(height: 28, thickness: 1, color: AppColors.border),
        ],
        if (status == PropertyStatus.verified || status == PropertyStatus.rejected) ...[
          SizedBox(width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _deleteProperty,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete Listing', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
        if (widget.property.rejectionReason != null) ...[
          const Divider(height: 28, thickness: 1, color: AppColors.border),
          const Text('Rejection Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withValues(alpha: 0.2))),
            child: Text(widget.property.rejectionReason!, style: const TextStyle(fontSize: 13, color: Colors.red, height: 1.4)),
          ),
        ],
      ]),
    );
  }

  Widget _buildSidebarRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textPrimary)),
    ]);
  }

  String _statusLabel(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.pending: return 'Pending';
      case PropertyStatus.verified: return 'Verified';
      case PropertyStatus.rejected: return 'Rejected';
      case PropertyStatus.deleted: return 'Deleted';
    }
  }

  Color _statusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.pending: return AppColors.warning;
      case PropertyStatus.verified: return AppColors.success;
      case PropertyStatus.rejected: return AppColors.error;
      case PropertyStatus.deleted: return AppColors.textMuted;
    }
  }

  Widget _buildMobileAdminBar(int vacantRooms, int totalRooms, List<RoomModel> rooms) {
    final status = widget.property.status;
    final isPending = status == PropertyStatus.pending;

    return Positioned(bottom: 0, left: 0, right: 0,
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _buildStatusPill(status),
                const SizedBox(width: 12),
                Text('$vacantRooms/$totalRooms vacant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: vacantRooms > 0 ? AppColors.success : AppColors.error)),
              ]),
            ]),
            if (isPending)
              Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _approveProperty,
                    icon: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check, size: 18),
                    label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12))),
                ),
                const SizedBox(width: 8),
                SizedBox(height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _rejectProperty,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12))),
                ),
              ]),
          ]),
        ]),
      ),
    );
  }

  Widget _buildReviewsSection(PropertyProvider provider) {
    if (provider.isLoadingReviews) {
      return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 200, height: 24, color: Colors.white),
          const SizedBox(height: 20),
          Row(children: [CircleAvatar(radius: 20, backgroundColor: Colors.white), const SizedBox(width: 12), Container(width: 150, height: 16, color: Colors.white)]),
        ]));
    }
    final reviews = provider.propertyReviews;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.star_rounded, size: 24, color: Colors.amber[700]),
        const SizedBox(width: 8),
        Text(widget.property.averageRating > 0 ? widget.property.averageRating.toStringAsFixed(1) : 'No reviews yet',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        if (widget.property.reviewsCount > 0) ...[
          const SizedBox(width: 8),
          Text('· ${widget.property.reviewsCount} reviews', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ]),
      const SizedBox(height: 24),
      if (reviews.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No reviews have been left for this property yet.', style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5)))
      else
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: reviews.length > 4 ? 4 : reviews.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.of(context).size.width >= 1000 ? 2 : 1, crossAxisSpacing: 48, mainAxisSpacing: 32, mainAxisExtent: 140),
          itemBuilder: (context, index) {
            final reviewData = reviews[index];
            final studentName = reviewData['users']?['display_name'] ?? 'Tenant';
            final reviewText = reviewData['review'] ?? 'Great place to stay!';
            final ratingVal = reviewData['rating'] as int? ?? 5;
            final createdAtStr = reviewData['created_at'] != null ? DateFormat('MMMM yyyy').format(DateTime.parse(reviewData['created_at'])) : 'May 2026';
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.primaryContainer,
                    child: Text(studentName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(createdAtStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 12),
              Row(children: List.generate(5, (starIdx) => Icon(starIdx < ratingVal ? Icons.star_rounded : Icons.star_border_rounded, size: 14, color: starIdx < ratingVal ? Colors.amber[700] : Colors.grey[300]))),
              const SizedBox(height: 8),
              Expanded(child: Text(reviewText, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4))),
            ]);
          }),
    ]);
  }

  Widget _buildHostProfileCard() {
    final ownerInit = widget.property.ownerName?.isNotEmpty == true ? widget.property.ownerName![0].toUpperCase() : 'O';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Meet your host', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 24),
      Container(width: double.infinity, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: const Color(0xFFF9FBFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 140, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
              child: Column(children: [
                Stack(children: [
                  CircleAvatar(radius: 36, backgroundColor: AppColors.primaryContainer, child: Text(ownerInit, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary))),
                  Positioned(bottom: 0, right: 0,
                      child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.verified_rounded, size: 20, color: AppColors.primary))),
                ]),
                const SizedBox(height: 12),
                Text(widget.property.ownerName ?? 'Property Owner', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Host', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(width: 32),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Host Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _buildHostStatRow(Icons.star_rounded, 'Rating: ${widget.property.averageRating > 0 ? widget.property.averageRating.toStringAsFixed(1) : "New"}'),
              const SizedBox(height: 12),
              _buildHostStatRow(Icons.rate_review_rounded, 'Reviews: ${widget.property.reviewsCount} reviews'),
              const SizedBox(height: 12),
              _buildHostStatRow(Icons.wc_rounded, 'Gender Policy: ${widget.property.genderOrientation.name.toUpperCase()}'),
            ])),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildHostStatRow(IconData icon, String label) {
    return Row(children: [Icon(icon, size: 20, color: AppColors.textPrimary), const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary))]);
  }

  Widget _buildThingsToKnow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Things to know', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 24),
      MediaQuery.of(context).size.width >= 1000
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _buildThingsToKnowCol('House rules', ['Check-in: After 2:00 PM', 'Checkout: Before 12:00 PM', 'Curfew hours: 10:00 PM', 'Visitors allowed in common areas only'])),
              const SizedBox(width: 32),
              Expanded(child: _buildThingsToKnowCol('Safety & property', ['CCTV installed in hallway & common areas', 'First aid kit available in lobby', 'Fire extinguisher on every floor', 'Emergency exit layout posted'])),
              const SizedBox(width: 32),
              Expanded(child: _buildThingsToKnowCol('Cancellation policy', ['Free cancellation for first 24 hours', 'Deposit refundable up to 7 days before check-in', 'Non-refundable if cancelled on check-in day'])),
            ])
          : Column(children: [
              _buildThingsToKnowCol('House rules', ['Check-in: After 2:00 PM', 'Checkout: Before 12:00 PM', 'Curfew hours: 10:00 PM', 'Visitors allowed in common areas only']),
              const SizedBox(height: 24),
              _buildThingsToKnowCol('Safety & property', ['CCTV installed in hallway & common areas', 'First aid kit available in lobby', 'Fire extinguisher on every floor', 'Emergency exit layout posted']),
              const SizedBox(height: 24),
              _buildThingsToKnowCol('Cancellation policy', ['Free cancellation for first 24 hours', 'Deposit refundable up to 7 days before check-in', 'Non-refundable if cancelled on check-in day']),
            ]),
    ]);
  }

  Widget _buildThingsToKnowCol(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(item, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)))]))),
    ]);
  }

  Widget _buildPlaceholder() {
    return Container(height: 300, width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.home_work_rounded, size: 64, color: Colors.grey),
        SizedBox(height: 12),
        Text('No Images Available', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
      ])));
  }

  Widget _buildShimmerBox({double height = double.infinity}) {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
      child: Container(height: height, width: double.infinity, color: Colors.white));
  }
}
