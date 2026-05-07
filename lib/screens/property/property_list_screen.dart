import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final roomProvider = context.watch<RoomProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          return CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 24,
                    vertical: isDesktop ? 60 : 32,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find Your Perfect Boarding House',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B16),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Discover comfortable and affordable boarding houses in Metro Manila',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Horizontal Filter Bar (Desktop) or Vertical (Mobile)
                      _buildFilterBar(isDesktop, propertyProvider),
                    ],
                  ),
                ),
              ),

              // Results Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 24,
                    vertical: 24,
                  ),
                  child: Text(
                    '${propertyProvider.properties.length} boarding houses found',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B16),
                    ),
                  ),
                ),
              ),

              // Property List (Grid)
              SliverPadding(
                padding: EdgeInsets.only(
                  left: isDesktop ? 60 : 24,
                  right: isDesktop ? 60 : 24,
                  bottom: 100,
                ),
                sliver: propertyProvider.isLoading
                    ? SliverToBoxAdapter(child: _buildSkeletonLoader())
                    : propertyProvider.properties.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : (constraints.maxWidth > 600 ? 2 : 1),
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.82,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = propertyProvider.properties[index];
                            final isLiveVacant = roomProvider.hasVacancyForProperty(
                              property.propertyId,
                            );

                            return _PropertyCard(
                              property: property,
                              liveVacancy: isLiveVacant,
                              lastUpdate: 'Live',
                            );
                          },
                          childCount: propertyProvider.properties.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(bool isDesktop, PropertyProvider provider) {
    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.all(24),
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
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          children: [
            // Search
            Expanded(
              flex: 3,
              child: _buildFilterField(
                label: 'Search Location or Name',
                hint: 'Search boarding houses...',
                icon: Icons.search,
                onChanged: (val) {
                  provider.setSearchQuery(val);
                  provider.loadProperties();
                },
              ),
            ),
            const SizedBox(width: 16),
            // Min Price
            Expanded(
              flex: 1,
              child: _buildFilterField(
                label: 'Min Price',
                hint: '0',
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  provider.setMinPrice(int.tryParse(val));
                  provider.loadProperties();
                },
              ),
            ),
            const SizedBox(width: 16),
            // Max Price
            Expanded(
              flex: 1,
              child: _buildFilterField(
                label: 'Max Price',
                hint: '10000',
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  provider.setMaxPrice(int.tryParse(val));
                  provider.loadProperties();
                },
              ),
            ),
            const SizedBox(width: 16),
            // Available Only Toggle
            _buildAvailableOnlyToggle(provider),
          ],
        ),
      );
    } else {
      // Mobile vertical filter stack
      return Column(
        children: [
          TextField(
            onChanged: (val) {
              provider.setSearchQuery(val);
              provider.loadProperties();
            },
            decoration: InputDecoration(
              hintText: 'Search boarding houses...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D1B16),
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildAvailableOnlyToggle(provider),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildFilterField({
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey[400]) : null,
            filled: true,
            fillColor: const Color(0xFFFBFBFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5287B2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableOnlyToggle(PropertyProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Available Only',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final propertyProvider = context.read<PropertyProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
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
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gender filter
                      const Text(
                        'Gender Orientation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFilterChip(
                            'All',
                            propertyProvider.genderFilter == null,
                            () => setState(
                              () => propertyProvider.setGenderFilter(null),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Male',
                            propertyProvider.genderFilter ==
                                GenderOrientation.male,
                            () => setState(
                              () => propertyProvider.setGenderFilter(
                                GenderOrientation.male,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Female',
                            propertyProvider.genderFilter ==
                                GenderOrientation.female,
                            () => setState(
                              () => propertyProvider.setGenderFilter(
                                GenderOrientation.female,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Mixed',
                            propertyProvider.genderFilter ==
                                GenderOrientation.mixed,
                            () => setState(
                              () => propertyProvider.setGenderFilter(
                                GenderOrientation.mixed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price range with RangeSlider
                      const Text(
                        'Price Range (₱)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setSliderState) {
                          final minPrice =
                              propertyProvider.minPrice?.toDouble() ?? 0;
                          final maxPrice =
                              propertyProvider.maxPrice?.toDouble() ?? 50000;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF5287B2,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '₱${minPrice.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF5287B2),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF5287B2,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '₱${maxPrice.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF5287B2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF5287B2),
                                  inactiveTrackColor: Colors.grey[300],
                                  thumbColor: const Color(0xFF5287B2),
                                  overlayColor: const Color(
                                    0xFF5287B2,
                                  ).withValues(alpha: 0.2),
                                  trackHeight: 6,
                                  rangeThumbShape:
                                      const RoundRangeSliderThumbShape(
                                        enabledThumbRadius: 10,
                                        elevation: 4,
                                      ),
                                  rangeTrackShape:
                                      const RoundedRectRangeSliderTrackShape(),
                                  showValueIndicator: ShowValueIndicator.never,
                                ),
                                child: RangeSlider(
                                  values: RangeValues(minPrice, maxPrice),
                                  min: 0,
                                  max: 50000,
                                  divisions: 10,
                                  onChanged: (values) {
                                    setSliderState(() {
                                      propertyProvider.setPriceRange(
                                        values.start.toInt(),
                                        values.end.toInt(),
                                      );
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₱0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    '₱25k',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    '₱50k',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            propertyProvider.loadProperties();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5287B2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        width: 200,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Address skeleton
                      Container(
                        width: 150,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price skeleton
                      Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF5287B2).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 64,
              color: const Color(0xFF5287B2).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No properties found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final isHoveredNotifier = ValueNotifier<bool>(false);
    return ValueListenableBuilder<bool>(
      valueListenable: isHoveredNotifier,
      builder: (context, isHovered, _) {
        return MouseRegion(
          onEnter: (_) => isHoveredNotifier.value = true,
          onExit: (_) => isHoveredNotifier.value = false,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              transform: Matrix4.identity()
                ..scaleByDouble(
                  isSelected ? 1.05 : (isHovered ? 1.02 : 1.0),
                  isSelected ? 1.05 : (isHovered ? 1.02 : 1.0),
                  1.0,
                  1.0,
                ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5287B2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected || isHovered
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFF5287B2,
                          ).withValues(alpha: isSelected ? 0.3 : 0.15),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool liveVacancy;
  final String? lastUpdate;

  const _PropertyCard({
    required this.property,
    required this.liveVacancy,
    this.lastUpdate,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFF5287B2).withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: _isHovered ? 24 : 10,
                  offset: Offset(0, _isHovered ? 8 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with status badge
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: widget.property.coverImageUrl != null
                            ? Image.network(
                                widget.property.coverImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, _, _) =>
                                    _buildGradientPlaceholder(),
                              )
                            : _buildGradientPlaceholder(),
                      ),
                      // Status Pill
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.liveVacancy
                                ? const Color(0xFF00D27B)
                                : const Color(0xFFFF3B30),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            widget.liveVacancy ? 'Available' : 'Full',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B16),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.property.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.property.reviewsCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.property.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.property.reviewsCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₱${widget.property.priceRange.min.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ",")}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5287B2),
                                  ),
                                ),
                                TextSpan(
                                  text: ' /month',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D95C2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5287B2).withValues(alpha: 0.3),
            const Color(0xFF5287B2).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 56,
              color: const Color(0xFF5287B2).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No Image Available',
              style: TextStyle(
                color: const Color(0xFF5287B2).withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
