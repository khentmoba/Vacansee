import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';
import '../../services/listing_service.dart';

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
    _rooms = []; // Will fetch dynamically or pass in
    _loadRooms();
  }

  void _loadRooms() {
    final propertyProvider = context.read<PropertyProvider>();
    propertyProvider.loadRooms(widget.property.propertyId);
    // Note: We'll listen to the provider's rooms list in build or initState
  }

  void _addRoom() {
    setState(() {
      _rooms.add(
        RoomModel(
          roomId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          propertyId: widget.property.propertyId,
          status: RoomStatus.vacant,
          lastUpdated: DateTime.now(),
          capacity: 1,
        ),
      );
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Property'),
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
            TextButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.check),
              label: const Text('SAVE'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Property Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rooms',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addRoom,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Room'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_rooms.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No rooms added. Please add at least one room.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        'Room: ${room.roomId.startsWith('temp_') ? 'New Room' : room.roomId}',
                      ),
                      subtitle: Text(
                        'Status: ${room.status.name} | Rate: ₱${room.monthlyRate ?? 0}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeRoom(index),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
              const Text(
                'Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final url = _images[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _deletedImagePaths.add(url);
                              _images.removeAt(index);
                            });
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
