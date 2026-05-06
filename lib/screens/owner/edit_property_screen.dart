import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';
import '../../services/listing_service.dart';
import '../../widgets/property/property_form_components.dart';
import 'widgets/room_details_dialog.dart';

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
    _descriptionController = TextEditingController(
      text: widget.property.description,
    );
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

  Future<void> _addRoom() async {
    final room = await showDialog<RoomModel>(
      context: context,
      builder: (context) => RoomDetailsDialog(
        propertyId: widget.property.propertyId,
      ),
    );

    if (room != null) {
      setState(() => _rooms.add(room));
    }
  }

  Future<void> _editRoom(int index) async {
    final room = await showDialog<RoomModel>(
      context: context,
      builder: (context) => RoomDetailsDialog(
        propertyId: widget.property.propertyId,
        initialRoom: _rooms[index],
      ),
    );

    if (room != null) {
      setState(() => _rooms[index] = room);
    }
  }

  void _removeRoom(int index) {
    setState(() {
      final roomId = _rooms[index].roomId;
      if (!roomId.startsWith('temp_')) {
        _deletedRoomIds.add(roomId);
      }
      _rooms.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final listingService = ListingService();
      final updatedProperty = widget.property.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        images: _images,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        title: const Text(
          'Edit Property',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'SAVE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF5287B2),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildBasicDetailsSection(),
                  const SizedBox(height: 24),
                  _buildRoomsSection(),
                  const SizedBox(height: 24),
                  _buildImagesSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF5287B2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'MANAGEMENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5287B2),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
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

  Widget _buildBasicDetailsSection() {
    return FormSectionCard(
      title: 'Basic Details',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          PremiumTextField(
            controller: _nameController,
            label: 'Property Name',
            hintText: 'Enter name',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _addressController,
            label: 'Address',
            hintText: 'Enter address',
            icon: Icons.location_on_outlined,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Enter description',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsSection() {
    return FormSectionCard(
      title: 'Rooms',
      icon: Icons.bed_outlined,
      trailing: ElevatedButton.icon(
        onPressed: _addRoom,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Room'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5287B2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_rooms.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Icons.bed_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text(
                    'No rooms added yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                return RoomListItem(
                  room: _rooms[index],
                  onEdit: () => _editRoom(index),
                  onDelete: () => _removeRoom(index),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return FormSectionCard(
      title: 'Property Images',
      icon: Icons.camera_alt_outlined,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final url = _images[index];
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
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
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (index == 0)
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5287B2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Cover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
