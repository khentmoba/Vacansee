import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/property/property_form_components.dart';
import '../../widgets/owner/owner_top_nav_bar.dart';

class CreatePropertyScreen extends StatefulWidget {
  final PropertyModel? property;
  const CreatePropertyScreen({super.key, this.property});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _totalRoomsController = TextEditingController();
  final _availableRoomsController = TextEditingController();
  final _customAmenityController = TextEditingController();

  GenderOrientation _genderOrientation = GenderOrientation.mixed;
  List<String> _selectedAmenities = [];
  final List<XFile> _selectedImages = [];
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _nameController.text = widget.property!.name;
      _addressController.text = widget.property!.address;
      _descriptionController.text = widget.property!.description ?? '';
      _monthlyPriceController.text = widget.property!.monthlyPrice.toString();
      _totalRoomsController.text = widget.property!.totalRooms.toString();
      _availableRoomsController.text = widget.property!.availableRooms.toString();
      _genderOrientation = widget.property!.genderOrientation;
      _selectedAmenities = List.from(widget.property!.amenities);
    }
  }

  final List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Kitchen',
    'Laundry Area',
    '24/7 Security',
    'Parking',
    'Gym',
    'Swimming Pool',
    'Study Area',
    'Common Area',
  ];

  final Map<String, String?> _errors = {};
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _monthlyPriceController.dispose();
    _totalRoomsController.dispose();
    _availableRoomsController.dispose();
    _customAmenityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addCustomAmenity() {
    final text = _customAmenityController.text.trim();
    if (text.isNotEmpty && !_selectedAmenities.contains(text)) {
      setState(() {
        _selectedAmenities.add(text);
        _customAmenityController.clear();
      });
    }
  }

  void _validateAndSubmit() {
    setState(() {
      _errors['name'] = _nameController.text.isEmpty
          ? 'Property name is required'
          : null;
      _errors['address'] = _addressController.text.isEmpty
          ? 'Address is required'
          : null;
      _errors['price'] = _monthlyPriceController.text.isEmpty
          ? 'Required'
          : null;
      _errors['totalRooms'] = _totalRoomsController.text.isEmpty
          ? 'Required'
          : null;
      _errors['availableRooms'] = _availableRoomsController.text.isEmpty
          ? 'Required'
          : null;
    });

    if (_errors.values.every((e) => e == null)) {
      _createProperty();
    }
  }

  Future<void> _createProperty() async {
    final authProvider = context.read<AuthProvider>();
    final propertyProvider = context.read<PropertyProvider>();
    final storageService = StorageService();

    final monthlyPrice = int.tryParse(_monthlyPriceController.text) ?? 0;
    final totalRooms = int.tryParse(_totalRoomsController.text) ?? 0;
    final availableRooms = int.tryParse(_availableRoomsController.text) ?? 0;
    final isEditing = widget.property != null;

    setState(() => _isUploadingImages = true);

    try {
      final PropertyModel property;
      if (isEditing) {
        property = widget.property!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          monthlyPrice: monthlyPrice,
          priceRange: PriceRange(min: monthlyPrice, max: monthlyPrice),
          totalRooms: totalRooms,
          availableRooms: availableRooms,
          description: _descriptionController.text.trim(),
          genderOrientation: _genderOrientation,
          amenities: _selectedAmenities,
          lastUpdated: DateTime.now(),
        );
      } else {
        property = await propertyProvider.createPropertyWithId(
          ownerId: authProvider.user!.uid,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          lat: 0.0,
          lng: 0.0,
          genderOrientation: _genderOrientation,
          amenities: _selectedAmenities,
          priceRange: PriceRange(min: monthlyPrice, max: monthlyPrice),
          description: _descriptionController.text.trim(),
        );
        
        // Update with new fields (since createPropertyWithId might not handle them yet)
        await propertyProvider.updateProperty(property.copyWith(
          monthlyPrice: monthlyPrice,
          totalRooms: totalRooms,
          availableRooms: availableRooms,
        ));
      }

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final imageBytesList = await Future.wait(
          _selectedImages.map((xfile) => xfile.readAsBytes()),
        );

        imageUrls = await storageService.uploadPropertyImages(
          propertyId: property.propertyId,
          files: imageBytesList,
        );

        await propertyProvider.updateProperty(
          property.copyWith(images: imageUrls),
        );
      } else if (isEditing) {
        await propertyProvider.updateProperty(property);
      }

      if (mounted) {
        setState(() => _isUploadingImages = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Property updated successfully!'
                  : 'Property created successfully!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImages = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();

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
                  title: Text(widget.property != null ? 'Edit Boarding House' : 'Add New Boarding House'),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D1B16),
                  elevation: 0,
                ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb
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
                    // Title
                    Text(
                      widget.property != null ? 'Edit Boarding House' : 'Add New Boarding House',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D1B16),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in the details to create a new listing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (propertyProvider.errorMessage != null)
                      _buildGlobalError(propertyProvider),

                    // Main Form Card
                    Container(
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
                          // Property Images Section
                          const Text(
                            'Property Images',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1B16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedImages.isEmpty)
                            DashedUploadBox(onTap: _pickImage)
                          else
                            _buildImageGrid(),
                          const SizedBox(height: 40),

                          // Basic Information Section
                          const Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1B16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PremiumTextField(
                            controller: _nameController,
                            label: 'Boarding House Name *',
                            hintText: 'e.g., Sunshine Boarding House',
                            errorText: _errors['name'],
                          ),
                          const SizedBox(height: 24),
                          PremiumTextField(
                            controller: _addressController,
                            label: 'Location *',
                            hintText: 'e.g., Quezon City, Metro Manila',
                            errorText: _errors['address'],
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
                                  errorText: _errors['price'],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: PremiumTextField(
                                  controller: _totalRoomsController,
                                  label: 'Total Rooms *',
                                  hintText: '10',
                                  keyboardType: TextInputType.number,
                                  errorText: _errors['totalRooms'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: isDesktop ? constraints.maxWidth * 0.4 : double.infinity,
                            child: PremiumTextField(
                              controller: _availableRoomsController,
                              label: 'Available Rooms *',
                              hintText: '5',
                              keyboardType: TextInputType.number,
                              errorText: _errors['availableRooms'],
                            ),
                          ),
                          const SizedBox(height: 24),
                          PremiumTextField(
                            controller: _descriptionController,
                            label: 'Description *',
                            hintText: 'Describe your boarding house, its features, and what makes it special...',
                            maxLines: 5,
                          ),
                          const SizedBox(height: 40),

                          // Amenities Section
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1B16),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Quick add common amenities:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _availableAmenities.map((amenity) {
                              final isSelected = _selectedAmenities.contains(amenity);
                              return AmenityChip(
                                label: amenity,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedAmenities.remove(amenity);
                                    } else {
                                      _selectedAmenities.add(amenity);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: PremiumTextField(
                                  controller: _customAmenityController,
                                  label: '',
                                  hintText: 'Add custom amenity...',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton.icon(
                                  onPressed: _addCustomAmenity,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5287B2),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('Add'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: propertyProvider.isLoading || _isUploadingImages
                                        ? null
                                        : _validateAndSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5287B2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: propertyProvider.isLoading || _isUploadingImages
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.save_outlined),
                                    label: Text(
                                      widget.property != null ? 'Save Changes' : 'Create Listing',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      foregroundColor: const Color(0xFF1D1B16),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return InkWell(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF5287B2)),
            ),
          );
        }
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(
                      _selectedImages[index].path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlobalError(PropertyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: provider.clearError,
          ),
        ],
      ),
    );
  }
}
