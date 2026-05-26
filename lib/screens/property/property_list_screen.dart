import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../models/property_model.dart';
import '../../providers/providers.dart';
import 'property_detail_screen.dart';
import '../../utils/transitions.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  int _selectedCategoryIndex = 0;
  final Set<String> _favoritedPropertyIds = {};
  
  // Custom Search Pill controllers
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  GenderOrientation? _selectedGender;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All Houses', 'icon': Icons.home_work_outlined},
    {'label': 'Study Areas', 'icon': Icons.menu_book_rounded},
    {'label': 'With WiFi', 'icon': Icons.wifi_rounded},
    {'label': 'Aircon Rooms', 'icon': Icons.ac_unit_rounded},
    {'label': 'Ladies Only', 'icon': Icons.female_rounded},
    {'label': 'Men Only', 'icon': Icons.male_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties();
      context.read<RoomProvider>().subscribeToVacancies();
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index, PropertyProvider provider) {
    setState(() {
      _selectedCategoryIndex = index;
    });

    provider.clearFilters();

    // Apply filter based on category index
    switch (index) {
      case 0: // All
        break;
      case 1: // Study Areas
        provider.toggleAmenity('Study Area');
        break;
      case 2: // WiFi
        provider.toggleAmenity('WiFi');
        break;
      case 3: // AC
        provider.toggleAmenity('Air Conditioning');
        break;
      case 4: // Female only
        provider.setGenderFilter(GenderOrientation.female);
        break;
      case 5: // Male only
        provider.setGenderFilter(GenderOrientation.male);
        break;
    }
    provider.loadProperties();
  }

  void _applyPillSearch(PropertyProvider provider) {
    if (_locationController.text.isNotEmpty) {
      provider.setSearchQuery(_locationController.text);
    } else {
      provider.setSearchQuery(null);
    }

    if (_priceController.text.isNotEmpty) {
      final maxVal = int.tryParse(_priceController.text);
      provider.setMaxPrice(maxVal);
    } else {
      provider.setMaxPrice(null);
    }

    provider.setGenderFilter(_selectedGender);
    provider.loadProperties();
  }

  void _clearSearchFields(PropertyProvider provider) {
    setState(() {
      _locationController.clear();
      _priceController.clear();
      _selectedGender = null;
      _selectedCategoryIndex = 0;
    });
    provider.clearFilters();
    provider.loadProperties();
  }

  bool _isSearchActive(PropertyProvider provider) {
    return provider.searchQuery != null || 
           provider.maxPrice != null || 
           (provider.genderFilter != null && _selectedCategoryIndex == 0) || 
           provider.selectedAmenities.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final properties = propertyProvider.properties;
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              // 1. Search Bar Header & Categories Tabs Bar
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
                  ),
                  padding: EdgeInsets.only(
                    top: isDesktop ? 24 : 16,
                    bottom: 8,
                  ),
                  child: Column(
                    children: [
                      // Floating Search Pill
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24),
                        child: _buildSearchPill(isDesktop, propertyProvider),
                      ),
                      const SizedBox(height: 24),
                      // Horizontal Categories bar
                      _buildCategoriesBar(propertyProvider),
                    ],
                  ),
                ),
              ),

              // 2. Main Listing Body
              if (propertyProvider.isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 60 : 24,
                      vertical: 40,
                    ),
                    child: _buildSkeletonLoader(isDesktop),
                  ),
                )
              else if (properties.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: _buildEmptyState(),
                  ),
                )
              else if (_isSearchActive(propertyProvider))
                // Active Search State: Show results in a clean grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 24,
                    vertical: 32,
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Search Results (${properties.length} found)',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              TextButton(
                                onPressed: () => _clearSearchFields(propertyProvider),
                                child: const Text('Clear All Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 4 : (constraints.maxWidth > 600 ? 2 : 1),
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 32,
                          childAspectRatio: 0.76,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final property = properties[index];
                          final isLiveVacant = roomProvider.hasVacancyForProperty(property.propertyId);
                          final isFavorited = _favoritedPropertyIds.contains(property.propertyId);

                          return _PropertyCard(
                            property: property,
                            liveVacancy: isLiveVacant,
                            isFavorited: isFavorited,
                            onFavoriteToggle: () {
                              setState(() {
                                if (isFavorited) {
                                  _favoritedPropertyIds.remove(property.propertyId);
                                } else {
                                  _favoritedPropertyIds.add(property.propertyId);
                                }
                              });
                            },
                          );
                        }, childCount: properties.length),
                      ),
                    ],
                  ),
                )
              else
                // Default State: Show Airbnb carousels
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 24,
                    vertical: 32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Section 1: Top Rated (4.5+ Stars)
                      _buildSectionHeader('Student Favorites (4.5+ ★)'),
                      _buildPropertyCarousel(
                        properties.where((p) => p.averageRating >= 4.5 || p.reviewsCount >= 2).toList(),
                        roomProvider,
                      ),
                      const SizedBox(height: 48),

                      // Section 2: Budget-Friendly (Under ₱4,000)
                      _buildSectionHeader('Budget-Friendly Choices (Under ₱4,000)'),
                      _buildPropertyCarousel(
                        properties.where((p) => p.priceRange.min <= 4000).toList(),
                        roomProvider,
                      ),
                      const SizedBox(height: 48),

                      // Section 3: Ladies Dormitories
                      _buildSectionHeader('Ladies Dormitories & Boarding Houses'),
                      _buildPropertyCarousel(
                        properties.where((p) => p.genderOrientation == GenderOrientation.female).toList(),
                        roomProvider,
                      ),
                      const SizedBox(height: 48),

                      // Section 4: All Boarding Houses Grid
                      _buildSectionHeader('All Boarding Houses'),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: properties.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 4 : (constraints.maxWidth > 600 ? 2 : 1),
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 32,
                          childAspectRatio: 0.76,
                        ),
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          final isLiveVacant = roomProvider.hasVacancyForProperty(property.propertyId);
                          final isFavorited = _favoritedPropertyIds.contains(property.propertyId);

                          return _PropertyCard(
                            property: property,
                            liveVacancy: isLiveVacant,
                            isFavorited: isFavorited,
                            onFavoriteToggle: () {
                              setState(() {
                                if (isFavorited) {
                                  _favoritedPropertyIds.remove(property.propertyId);
                                } else {
                                  _favoritedPropertyIds.add(property.propertyId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Row(
            children: [
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCarousel(List<PropertyModel> carouselProps, RoomProvider roomProvider) {
    if (carouselProps.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('No boarding houses fit this category right now.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: carouselProps.length,
        itemBuilder: (context, index) {
          final property = carouselProps[index];
          final isLiveVacant = roomProvider.hasVacancyForProperty(property.propertyId);
          final isFavorited = _favoritedPropertyIds.contains(property.propertyId);

          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 20),
            child: _PropertyCard(
              property: property,
              liveVacancy: isLiveVacant,
              isFavorited: isFavorited,
              onFavoriteToggle: () {
                setState(() {
                  if (isFavorited) {
                    _favoritedPropertyIds.remove(property.propertyId);
                  } else {
                    _favoritedPropertyIds.add(property.propertyId);
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchPill(bool isDesktop, PropertyProvider provider) {
    if (isDesktop) {
      return Center(
        child: Container(
          width: 820,
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(33),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              // Location Column
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Where', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      TextField(
                        controller: _locationController,
                        onSubmitted: (_) => _applyPillSearch(provider),
                        decoration: const InputDecoration(
                          hintText: 'Search destinations',
                          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              // Budget Column
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Budget', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _applyPillSearch(provider),
                        decoration: const InputDecoration(
                          hintText: 'Add max price',
                          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              // Who/Gender Column
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Who', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<GenderOrientation>(
                          value: _selectedGender,
                          isDense: true,
                          hint: const Text('Add guests', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                          icon: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Any Gender')),
                            DropdownMenuItem(value: GenderOrientation.male, child: Text('Male Only')),
                            DropdownMenuItem(value: GenderOrientation.female, child: Text('Female Only')),
                            DropdownMenuItem(value: GenderOrientation.mixed, child: Text('Mixed Orientation')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedGender = val;
                            });
                            _applyPillSearch(provider);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Clear action if active
              if (_isSearchActive(provider))
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _clearSearchFields(provider),
                ),
              // Search Button
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                    onPressed: () => _applyPillSearch(provider),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobile Search Bar triggers bottom sheet filter
      return GestureDetector(
        onTap: () => _showFilterSheet(context),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationController.text.isNotEmpty 
                          ? 'Where to: ${_locationController.text}' 
                          : 'Where to?',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_priceController.text.isNotEmpty ? "Max ₱${_priceController.text}" : "Any budget"} · ${_selectedGender != null ? _selectedGender!.name.toUpperCase() : "Any gender"}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Filter tune icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCategoriesBar(PropertyProvider provider) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          return InkWell(
            onTap: () => _onCategorySelected(index, provider),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.only(right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'],
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: 24,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final propertyProvider = context.read<PropertyProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
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
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _locationController.clear();
                                _priceController.clear();
                                _selectedGender = null;
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Location text search
                      const Text(
                        'Where to?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Search locations e.g. Lapasan, Nazareth',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Max price input
                      const Text(
                        'Maximum Monthly Budget (₱)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 4000',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Gender Orientation
                      const Text(
                        'Gender Orientation Policy',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSheetFilterChip('All Genders', _selectedGender == null, () {
                            setState(() => _selectedGender = null);
                          }),
                          _buildSheetFilterChip('Male Only', _selectedGender == GenderOrientation.male, () {
                            setState(() => _selectedGender = GenderOrientation.male);
                          }),
                          _buildSheetFilterChip('Female Only', _selectedGender == GenderOrientation.female, () {
                            setState(() => _selectedGender = GenderOrientation.female);
                          }),
                          _buildSheetFilterChip('Mixed Genders', _selectedGender == GenderOrientation.mixed, () {
                            setState(() => _selectedGender = GenderOrientation.mixed);
                          }),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            _applyPillSearch(propertyProvider);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Apply Filter Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSheetFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onTap(),
      checkmarkColor: Colors.white,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildSkeletonLoader(bool isDesktop) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 1,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_work_outlined, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No boarding houses fit your choices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text('Try adjusting your budget, location search, or gender policy.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool liveVacancy;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const _PropertyCard({
    required this.property,
    required this.liveVacancy,
    required this.isFavorited,
    required this.onFavoriteToggle,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasFavoriteBadge = widget.property.averageRating >= 4.5;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            SharedAxisPageRoute(
              page: PropertyDetailScreen(property: widget.property),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Overlays
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: widget.property.coverImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.property.coverImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    // "Student Favorite" Pill
                    if (hasFavoriteBadge)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Text(
                            'Guest favorite',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    // Heart Icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: widget.onFavoriteToggle,
                        child: Icon(
                          widget.isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: widget.isFavorited ? Colors.red : Colors.white,
                          size: 24,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ),
                    // Availability Pill
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.liveVacancy ? AppColors.success : AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.liveVacancy ? 'VACANT' : 'FULL',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title & Stars Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.property.name,
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
            const SizedBox(height: 3),
            // Address details
            Text(
              widget.property.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            // Price Tag
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '₱${widget.property.monthlyPrice > 0 ? widget.property.monthlyPrice : widget.property.priceRange.min}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 14.5),
                  ),
                  const TextSpan(
                    text: ' /month',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
