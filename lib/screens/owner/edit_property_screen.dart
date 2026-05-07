import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';
import '../../services/listing_service.dart';
import '../../widgets/property/property_form_components.dart';
import '../../widgets/owner/owner_top_nav_bar.dart';

class EditPropertyScreen extends StatefulWidget {
  final PropertyModel property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _monthlyPriceController;
  late TextEditingController _totalRoomsController;
  late TextEditingController _availableRoomsController;

  late List<String> _images;
  late List<RoomModel> _rooms;
  final List<String> _deletedRoomIds = [];
  final List<String> _deletedImagePaths = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property.name);
    _addressController = TextEditingController(text: widget.property.address);
    _descriptionController = TextEditingController(text: widget.property.description ?? '');
    _monthlyPriceController = TextEditingController(text: widget.property.monthlyPrice.toString());
    _totalRoomsController = TextEditingController(text: widget.property.totalRooms.toString());
    _availableRoomsController = TextEditingController(text: widget.property.availableRooms.toString());
    _images = List.from(widget.property.images);
    _rooms = [];
    _loadRooms();
  }

  void _loadRooms() {
    final propertyProvider = context.read<PropertyProvider>();
    propertyProvider.loadRooms(widget.property.propertyId).then((_) {
      if (mounted) {
        setState(() {
          _rooms = List.from(propertyProvider.rooms);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _monthlyPriceController.dispose();
    _totalRoomsController.dispose();
    _availableRoomsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final listingService = ListingService();
      final monthlyPrice = int.tryParse(_monthlyPriceController.text) ?? 0;
      final totalRooms = int.tryParse(_totalRoomsController.text) ?? 0;
      final availableRooms = int.tryParse(_availableRoomsController.text) ?? 0;

      final updatedProperty = widget.property.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        monthlyPrice: monthlyPrice,
        priceRange: PriceRange(min: monthlyPrice, max: monthlyPrice),
        totalRooms: totalRooms,
        availableRooms: availableRooms,
        images: _images,
        lastUpdated: DateTime.now(),
      );

      await listingService.updatePropertyListing(
        property: updatedProperty,
        rooms: _rooms,
        deletedRoomIds: _deletedRoomIds,
        deletedImagePaths: _deletedImagePaths,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FBFD),
          appBar: isDesktop
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(80),
                  child: OwnerTopNavBar(currentRoute: ''),
                )
              : AppBar(
                  title: const Text('Edit Property'),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D1B16),
                  elevation: 0,
                ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildBasicDetailsSection(isDesktop),
                      const SizedBox(height: 24),
                      _buildRoomsSection(),
                      const SizedBox(height: 24),
                      _buildImagesSection(),
                      const SizedBox(height: 40),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 18, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Property Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B16),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep your property details and room availability up to date.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicDetailsSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          PremiumTextField(
            controller: _nameController,
            label: 'Property Name *',
            hintText: 'Enter name',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          PremiumTextField(
            controller: _addressController,
            label: 'Location *',
            hintText: 'Enter address',
            icon: Icons.location_on_outlined,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  controller: _monthlyPriceController,
                  label: 'Monthly Price (₱) *',
                  hintText: '5000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumTextField(
                  controller: _totalRoomsController,
                  label: 'Total Rooms *',
                  hintText: '10',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isDesktop ? 400 : double.infinity,
            child: PremiumTextField(
              controller: _availableRoomsController,
              label: 'Available Rooms *',
              hintText: '5',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 24),
          PremiumTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Enter description',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Specific Rooms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {}, // Room management is secondary for now
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Room Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Optional: Add detailed information for individual rooms.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (_rooms.isEmpty)
            _buildEmptyRoomsState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                return RoomListItem(
                  room: _rooms[index],
                  onEdit: () {},
                  onDelete: () {},
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyRoomsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.bed_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'Only simple counts are being used',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property Images',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              if (index == _images.length) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF5287B2)),
                );
              }
              final url = _images[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _deletedImagePaths.add(url);
                          _images.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5287B2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text(
                'Save All Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: const Color(0xFF1D1B16),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
