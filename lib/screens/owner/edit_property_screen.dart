import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';
import '../../services/listing_service.dart';
import '../../widgets/property/property_form_components.dart';
import '../../widgets/common/confirmation_dialog.dart';

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
  late TextEditingController _newImageUrlController;

  late List<String> _images;
  late List<String> _amenities;
  late GenderOrientation _genderOrientation;
  late List<RoomModel> _rooms;
  final List<String> _deletedRoomIds = [];
  final List<String> _deletedImagePaths = [];

  bool _isSaving = false;
  int _activeSubSectionIndex = 0; // Current form tab/section index

  final List<Map<String, dynamic>> _subSections = [
    {'title': 'Basic Information', 'icon': Icons.info_outline_rounded},
    {'title': 'Pricing', 'icon': Icons.payments_outlined},
    {'title': 'Unit Features', 'icon': Icons.home_work_outlined},
    {'title': 'Facilities', 'icon': Icons.check_circle_outline_rounded},
    {'title': 'Media', 'icon': Icons.image_outlined},
    {'title': 'About', 'icon': Icons.description_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property.name);
    _addressController = TextEditingController(text: widget.property.address);
    _descriptionController = TextEditingController(text: widget.property.description ?? '');
    _monthlyPriceController = TextEditingController(text: widget.property.monthlyPrice.toString());
    _totalRoomsController = TextEditingController(text: widget.property.totalRooms.toString());
    _availableRoomsController = TextEditingController(text: widget.property.availableRooms.toString());
    _newImageUrlController = TextEditingController();

    _images = List.from(widget.property.images);
    _amenities = List.from(widget.property.amenities);
    _genderOrientation = widget.property.genderOrientation;
    _rooms = [];
    _loadRooms();

    // Listeners to trigger state rebuilds for real-time live preview update
    _nameController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _monthlyPriceController.addListener(_onFieldChanged);
    _totalRoomsController.addListener(_onFieldChanged);
    _availableRoomsController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
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
    _nameController.removeListener(_onFieldChanged);
    _addressController.removeListener(_onFieldChanged);
    _monthlyPriceController.removeListener(_onFieldChanged);
    _totalRoomsController.removeListener(_onFieldChanged);
    _availableRoomsController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _monthlyPriceController.dispose();
    _totalRoomsController.dispose();
    _availableRoomsController.dispose();
    _newImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct errors across all tabs before saving.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
        amenities: _amenities,
        genderOrientation: _genderOrientation,
        hasVacancy: availableRooms > 0,
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
          const SnackBar(
            content: Text('Property updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);
    try {
      final propertyProvider = context.read<PropertyProvider>();
      final hasBookings = await propertyProvider.hasActiveBookings(widget.property.propertyId);
      
      setState(() => _isSaving = false);

      if (hasBookings) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cannot Delete Boarding House'),
            content: const Text(
              'This boarding house has active (pending or approved) bookings. '
              'Please resolve or cancel these bookings before deleting the listing.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmationDialog(
          title: 'Delete Boarding House',
          content: 'Are you sure you want to delete "${widget.property.name}"? '
              'This will remove the listing and set all associated rooms to maintenance.',
          confirmLabel: 'Delete',
          confirmColor: AppColors.error,
          onConfirm: () async {
            setState(() => _isSaving = true);
            try {
              final success = await propertyProvider.deleteProperty(widget.property.propertyId);
              if (success) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Boarding house deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                navigator.pop();
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(propertyProvider.errorMessage ?? 'Failed to delete boarding house'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Error deleting property: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            } finally {
              if (mounted) setState(() => _isSaving = false);
            }
          },
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error checking bookings: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Top mock top bar / menu
              _buildTopHeader(isDesktop),
              const Divider(height: 1, color: AppColors.border),

              // Main Workspace Split View
              Expanded(
                child: Form(
                  key: _formKey,
                  child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build Desktop view layout with Sidebar, Content Pane, and Preview Panel
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Left Sidebar
        Container(
          width: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Listing Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _subSections.length,
                  itemBuilder: (context, index) {
                    final isSelected = _activeSubSectionIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _activeSubSectionIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _subSections[index]['icon'],
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _subSections[index]['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 2. Middle Content Form Pane
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _subSections[_activeSubSectionIndex]['title'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Edit details for this category to update your listing.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 32),
                _buildActiveTabContent(),
              ],
            ),
          ),
        ),

        // 3. Divider
        const VerticalDivider(width: 1, color: AppColors.border),

        // 4. Right Live Preview Card Pane
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AIRBNB STYLE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This is how your boarding house appears to student tenants on the VacanSee search feeds.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 420,
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _buildPreviewCard(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build Mobile View layout with horizontal categories tab & content pane
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Horizontal Scrollable Categories
        SizedBox(
          height: 52,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _subSections.length,
              itemBuilder: (context, index) {
                final isSelected = _activeSubSectionIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _activeSubSectionIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _subSections[index]['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Active Tab Form fields
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildActiveTabContent(),
          ),
        ),

        // Floating Mobile Live Preview trigger bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showMobilePreviewSheet,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Show Live Preview'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Switcher of the Form Content Pane based on selected tab index
  Widget _buildActiveTabContent() {
    return IndexedStack(
      index: _activeSubSectionIndex,
      children: [
        // 0. Basic Information
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumTextField(
              controller: _nameController,
              label: 'Property Name *',
              hintText: 'e.g. CDO Cozy Dorm',
              validator: (v) => v?.trim().isEmpty ?? true ? 'Property Name is required' : null,
            ),
            const SizedBox(height: 24),
            PremiumTextField(
              controller: _addressController,
              label: 'Location / Address *',
              hintText: 'e.g. Capistrano St., Cagayan de Oro City',
              icon: Icons.location_on_outlined,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Address is required' : null,
            ),
          ],
        ),

        // 1. Pricing
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumTextField(
              controller: _monthlyPriceController,
              label: 'Monthly Rental Price (₱) *',
              hintText: 'e.g. 3500',
              keyboardType: TextInputType.number,
              icon: Icons.payments_outlined,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Monthly price is required';
                if (int.tryParse(v!.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
          ],
        ),

        // 2. Unit Features
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    controller: _totalRoomsController,
                    label: 'Total Rooms *',
                    hintText: 'e.g. 10',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Total rooms required';
                      if (int.tryParse(v!.trim()) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: PremiumTextField(
                    controller: _availableRoomsController,
                    label: 'Available Rooms *',
                    hintText: 'e.g. 3',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Available rooms required';
                      final val = int.tryParse(v!.trim());
                      if (val == null) return 'Enter a valid number';
                      final tot = int.tryParse(_totalRoomsController.text.trim()) ?? 0;
                      if (val > tot) return 'Cannot exceed total rooms';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Gender Orientation Policy *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<GenderOrientation>(
                  value: _genderOrientation,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  items: const [
                    DropdownMenuItem(
                      value: GenderOrientation.male,
                      child: Text('Male Students Only'),
                    ),
                    DropdownMenuItem(
                      value: GenderOrientation.female,
                      child: Text('Female Students Only'),
                    ),
                    DropdownMenuItem(
                      value: GenderOrientation.mixed,
                      child: Text('Mixed Student Occupancy'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _genderOrientation = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        // 3. Facilities
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Amenities Offered',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                'WiFi',
                'Air Conditioning',
                'Kitchen',
                'Laundry',
                'Security',
                'Parking',
                'Study Area',
              ].map((amenity) {
                final isSelected = _amenities.contains(amenity);
                return AmenityChip(
                  label: amenity,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _amenities.remove(amenity);
                      } else {
                        _amenities.add(amenity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),

        // 4. Media
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Image by URL',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newImageUrlController,
                    decoration: InputDecoration(
                      hintText: 'https://images.unsplash.com/photo-...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final url = _newImageUrlController.text.trim();
                    if (url.isNotEmpty && Uri.parse(url).isAbsolute) {
                      setState(() {
                        _images.add(url);
                        _newImageUrlController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid image URL')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Listing Images Gallery',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (_images.isEmpty)
              Container(
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'No images added yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final url = _images[index];
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
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
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
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
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'COVER',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),

        // 5. About / Description
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumTextField(
              controller: _descriptionController,
              label: 'Description / About the space',
              hintText: 'Enter a comprehensive overview of the boarding house structure, amenities, guidelines, and rules.',
              maxLines: 6,
            ),
          ],
        ),
      ],
    );
  }

  // Top header representing the mockup top bar
  Widget _buildTopHeader(bool isDesktop) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Logo & Breadcrumbs
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                SizedBox(width: 12),
                Text(
                  'VacanSee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Listing / Listing details',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Central Tabs (Mocked layout style - Desktop only)
          if (isDesktop) ...[
            const Spacer(),
            _buildTopTab('Listing Details', isSelected: true),
          ],

          const Spacer(),

          // Right Save, Cancel & Delete Buttons (Desktop only)
          if (isDesktop) ...[
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _handleDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
              label: const Text(
                'Delete Listing',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],

          // Right Delete Button (Mobile only)
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: _isSaving ? null : _handleDelete,
              tooltip: 'Delete Listing',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopTab(String label, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  // Airbnb-style Live Preview Card rendering
  Widget _buildPreviewCard() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'My Boarding House';
    final address = _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'Address, CDO';
    final priceStr = _monthlyPriceController.text.trim().isNotEmpty ? _monthlyPriceController.text.trim() : '0';
    final availCount = int.tryParse(_availableRoomsController.text.trim()) ?? 0;
    final isVacant = availCount > 0;
    final coverUrl = _images.isNotEmpty ? _images.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => _buildPreviewPlaceholder(),
                        )
                      : _buildPreviewPlaceholder(),
                ),
                // Cover Image label
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Cover Image',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Vacant overlay
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVacant ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isVacant ? 'VACANT' : 'FULL',
                      style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Title and star row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 2),
                Text(
                  widget.property.averageRating > 0
                      ? widget.property.averageRating.toStringAsFixed(1)
                      : 'New',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),

        // Address
        Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),

        // Price details
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '₱$priceStr',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 14),
              ),
              const TextSpan(
                text: ' /month',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  // Opens live preview card inside bottom sheet in mobile devices
  void _showMobilePreviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Live Tenant Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 280,
                    height: 360,
                    child: _buildPreviewCard(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
