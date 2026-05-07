import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';
import '../../widgets/booking/booking_dialog.dart';
import '../booking/booking_screen.dart';
import '../../utils/transitions.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadRooms(widget.property.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final rooms = propertyProvider.rooms;
    final vacantRooms = rooms.where((r) => r.status == RoomStatus.vacant).length;
    final totalRooms = rooms.length;
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
            // Back Button
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Search'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            // Main Content Area
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Gallery, About, Amenities
                  Expanded(
                    flex: 65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGallery(),
                        const SizedBox(height: 48),
                        _buildAboutSection(),
                        const SizedBox(height: 48),
                        _buildAmenitiesSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  // Right Column: Sticky Sidebar
                  Expanded(
                    flex: 35,
                    child: _buildSidebar(vacantRooms, totalRooms, rooms),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildGallery(),
                  const SizedBox(height: 32),
                  _buildSidebar(vacantRooms, totalRooms, rooms),
                  const SizedBox(height: 32),
                  _buildAboutSection(),
                  const SizedBox(height: 32),
                  _buildAmenitiesSection(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery() {
    final images = [
      widget.property.coverImageUrl,
      // Add other images if available in your model
    ].whereType<String>().toList();

    // Fallback if no images
    if (images.isEmpty) return _buildPlaceholder();

    return Column(
      children: [
        // Main Image
        Container(
          height: 450,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: NetworkImage(images[_selectedImageIndex]),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnails
        if (images.length > 1)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedImageIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF5287B2) : Colors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
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
            'About This Property',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.property.description ?? 'No description provided.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      width: double.infinity,
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
            'Amenities',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: widget.property.amenities.map((amenity) {
              return _buildAmenityChip(amenity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    switch (amenity.toLowerCase()) {
      case 'wifi':
        icon = Icons.wifi;
        break;
      case 'air conditioning':
      case 'ac':
        icon = Icons.ac_unit_rounded;
        break;
      case 'kitchen':
        icon = Icons.restaurant_rounded;
        break;
      case 'laundry area':
      case 'laundry':
        icon = Icons.local_laundry_service_rounded;
        break;
      case '24/7 security':
      case 'security':
        icon = Icons.security_rounded;
        break;
      case 'parking':
        icon = Icons.local_parking_rounded;
        break;
      default:
        icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF5287B2)),
          const SizedBox(width: 12),
          Text(
            amenity,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D1B16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(int vacantRooms, int totalRooms, List<RoomModel> rooms) {
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
          Text(
            widget.property.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.property.address,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.property.priceRange.formatted,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5287B2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/month',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSidebarRow('Available Rooms:', '$vacantRooms / $totalRooms'),
          const SizedBox(height: 16),
          _buildSidebarRow(
            'Status:',
            vacantRooms > 0 ? 'Available' : 'Fully Occupied',
            valueColor: vacantRooms > 0 ? const Color(0xFF10B981) : Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSidebarRow('Owner:', 'Owner Name'), // Replace with actual owner name if available
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: vacantRooms > 0
                  ? () {
                      final firstVacantRoom = rooms.firstWhere(
                        (r) => r.status == RoomStatus.vacant,
                      );
                      Navigator.push(
                        context,
                        SharedAxisPageRoute(
                          page: BookingScreen(
                            property: widget.property,
                            room: firstVacantRoom,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5287B2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                vacantRooms > 0 ? 'Book Now' : 'No Rooms Available',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'You won\'t be charged yet',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1D1B16),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No Image Available', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
