import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/property/property_form_components.dart';

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
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

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
      _minPriceController.text = widget.property!.priceRange.min.toString();
      _maxPriceController.text = widget.property!.priceRange.max.toString();
      _genderOrientation = widget.property!.genderOrientation;
      _selectedAmenities = List.from(widget.property!.amenities);
    }
  }

  final List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Laundry',
    'Kitchen',
    'Parking',
    'Security',
    'Study Area',
    'Gym',
    'Pool',
    'Pet Friendly',
  ];

  final Map<String, String?> _errors = {};
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
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

  void _validateAndSubmit() {
    setState(() {
      _errors['name'] = _nameController.text.isEmpty
          ? 'Property name is required'
          : null;
      _errors['address'] = _addressController.text.isEmpty
          ? 'Address is required'
          : null;
      _errors['minPrice'] = _minPriceController.text.isEmpty
          ? 'Required'
          : null;
      _errors['maxPrice'] = _maxPriceController.text.isEmpty
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

    final minPrice = int.tryParse(_minPriceController.text) ?? 0;
    final maxPrice = int.tryParse(_maxPriceController.text) ?? 0;
    final isEditing = widget.property != null;

    setState(() => _isUploadingImages = true);

    try {
      final PropertyModel property;
      if (isEditing) {
        property = widget.property!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          priceRange: PriceRange(min: minPrice, max: maxPrice),
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
          priceRange: PriceRange(min: minPrice, max: maxPrice),
          description: _descriptionController.text.trim(),
        );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        title: Text(
          widget.property != null ? 'Edit Listing' : 'New Listing',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 700;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),

                    if (propertyProvider.errorMessage != null)
                      _buildGlobalError(propertyProvider),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildBasicInfoSection(),
                                const SizedBox(height: 24),
                                _buildAmenitiesSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildMediaSection(),
                                const SizedBox(height: 24),
                                _buildPublishCard(propertyProvider),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildBasicInfoSection(),
                          const SizedBox(height: 24),
                          _buildAmenitiesSection(),
                          const SizedBox(height: 24),
                          _buildMediaSection(),
                          const SizedBox(height: 32),
                          _buildPublishCard(propertyProvider),
                        ],
                      ),
                  ],
                ),
              );
            },
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
            'PROPERTY DETAILS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5287B2),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.property != null ? 'Edit Your Listing' : 'Add New Listing',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B16),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide accurate details to help students find their perfect home.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSectionCard(
      title: 'Basic Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          PremiumTextField(
            controller: _nameController,
            label: 'Property Name *',
            hintText: 'e.g., Sunshine Boarding House',
            errorText: _errors['name'],
          ),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _addressController,
            label: 'Address *',
            hintText: 'e.g., 123 Main St, Cagayan de Oro City',
            icon: Icons.location_on_outlined,
            errorText: _errors['address'],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  controller: _minPriceController,
                  label: 'Min Price (₱) *',
                  hintText: '3000',
                  keyboardType: TextInputType.number,
                  errorText: _errors['minPrice'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PremiumTextField(
                  controller: _maxPriceController,
                  label: 'Max Price (₱) *',
                  hintText: '8000',
                  keyboardType: TextInputType.number,
                  errorText: _errors['maxPrice'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGenderSelector(),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Tell students about your property, rules, and local vibe...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender Orientation',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1B16),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: GenderOrientation.values.map((val) {
            final isSelected = _genderOrientation == val;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(val.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _genderOrientation = val);
                },
                selectedColor: const Color(0xFF5287B2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return FormSectionCard(
      title: 'Amenities',
      icon: Icons.star_border_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
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
    );
  }

  Widget _buildMediaSection() {
    return FormSectionCard(
      title: 'Photos',
      icon: Icons.camera_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedImages.isEmpty)
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Property Photos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG up to 5MB',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF5287B2)),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedImages[index].path,
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
            ),
        ],
      ),
    );
  }

  Widget _buildPublishCard(PropertyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B16),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_outlined, color: Color(0xFF5287B2), size: 40),
          const SizedBox(height: 16),
          const Text(
            'Ready to Publish?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'By publishing, your listing will be visible to students in the area.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: provider.isLoading || _isUploadingImages
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
              child: provider.isLoading || _isUploadingImages
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.property != null ? 'Save Changes' : 'Publish Listing',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Discard Changes',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
        ],
      ),
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
