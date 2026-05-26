import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/interactive_hover.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          final padding = isMobile ? 24.0 : 48.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildNavbar(context, isMobile, padding),
                _buildHero(context, isMobile, padding),
                _buildFeatures(context, isMobile, padding),
                _buildFeaturedGrid(context, isMobile, padding),
                _buildRoles(context, isMobile, padding),
                _buildFAQSection(context, isMobile, padding),
                _buildCTA(context, isMobile, padding),
                _buildFooter(context, isMobile, padding),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, bool isMobile, double padding) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'VacanSee',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                // Nav buttons
                Row(
                  children: [
                    if (!isMobile) ...[
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    InteractiveHover(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 18 : 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          isMobile ? 'Join' : 'Sign Up',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A), // Deep Slate
            Color(0xFF1E3A8A), // Indigo Navy
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative glowing blurred circles in the background
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              key: const ValueKey('glow_circle_1'),
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              key: const ValueKey('glow_circle_2'),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: isMobile ? 50 : 90,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeroText(context, isMobile),
                      const SizedBox(height: 48),
                      _buildHeroMockupCard(context, true),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroText(context, isMobile),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 4,
                        child: _buildHeroMockupCard(context, false),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroText(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'AY 2025-2026 Housing Companion',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.15,
              fontFamily: 'sans-serif',
            ),
            children: [
              TextSpan(
                text: 'Find Your Perfect\n',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Boarding House',
                style: TextStyle(
                  color: AppColors.secondary,
                  shadows: [
                    Shadow(
                      color: AppColors.secondary,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Discover, reserve, and manage boarding houses in Cagayan de Oro City in real-time. Filter by budget, location, and gender preference seamlessly.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 17,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            InteractiveHover(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            InteractiveHover(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroMockupCard(BuildContext context, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/room_ocean_view.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: const Icon(Icons.home_work, color: Colors.white70, size: 40),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 6),
                      Text(
                        'AVAILABLE NOW',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Ocean View Dorms',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text('4.8', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('Lapasan, CDO (150m from USTP)', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STARTING FROM', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 0.5)),
                          SizedBox(height: 2),
                          Text('₱4,200/mo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 50 : 90,
      ),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Why Choose VacanSee?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'The absolute smoothest way to find or host student boarding houses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 54),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              InteractiveHover(
                child: _buildFeatureCard(
                  Icons.search_rounded,
                  'Smart Searching',
                  'Find listings near USTP, Xavier, or Liceo. Filter instantly by price range, amenities, and co-ed preferences.',
                  isMobile,
                ),
              ),
              InteractiveHover(
                child: _buildFeatureCard(
                  Icons.bolt_rounded,
                  'Real-Time Status',
                  'Never waste walks under the hot sun. See live vacancy updates direct from the property owners.',
                  isMobile,
                ),
              ),
              InteractiveHover(
                child: _buildFeatureCard(
                  Icons.verified_user_rounded,
                  'Trusted Landlords',
                  'We verify owner identities and property listings to protect you from housing scams and fake bookings.',
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Curated property listings grid/carousel
  Widget _buildFeaturedGrid(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 50 : 90,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Discover Your Ideal Space',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Explore high-fidelity verified boarding spaces around major CDO campuses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Filter Chips mock
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMockFilterChip('All', true),
                _buildMockFilterChip('Near USTP', false),
                _buildMockFilterChip('Near Xavier', false),
                _buildMockFilterChip('Female Only', false),
                _buildMockFilterChip('Male Only', false),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // Room grid list
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildRoomCard(
                context,
                'Vista Grand Suites',
                'assets/images/room_vista_grand.png',
                '₱3,500/mo',
                'Carmen, Cagayan de Oro',
                4.9,
                'Co-Ed',
                isMobile,
              ),
              _buildRoomCard(
                context,
                'Ocean View Dorms',
                'assets/images/room_ocean_view.png',
                '₱4,200/mo',
                'Lapasan, Cagayan de Oro',
                4.8,
                'Female Only',
                isMobile,
              ),
              _buildRoomCard(
                context,
                'Pine Hill Boarding House',
                'assets/images/room_pine_hill.png',
                '₱2,800/mo',
                'Nazareth, Cagayan de Oro',
                4.7,
                'Male Only',
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? AppColors.primary : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    String title,
    String imagePath,
    String price,
    String location,
    double rating,
    String gender,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.home_work, color: Colors.grey, size: 36),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    gender,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Space'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoles(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 50 : 90,
      ),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Two Simple Pathways',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Whether you need a place to stay or own a property, we have you covered',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 32,
            runSpacing: 32,
            children: [
              // Tenant Card
              InteractiveHover(
                child: _buildRoleCard(
                  context,
                  isTenant: true,
                  icon: Icons.people_outline_rounded,
                  title: 'For Tenants',
                  features: [
                    'Browse hundreds of verified boarding houses',
                    'Filter by price, location, and amenities',
                    'Book rooms instantly with owner approval',
                    'Leave reviews and ratings to help others',
                  ],
                  buttonText: 'Sign Up as Tenant',
                  isMobile: isMobile,
                ),
              ),
              // Owner Card
              InteractiveHover(
                child: _buildRoleCard(
                  context,
                  isTenant: false,
                  icon: Icons.business_rounded,
                  title: 'For Owners',
                  features: [
                    'List your boarding house for free',
                    'Manage all your units in one dashboard',
                    'Review and approve booking requests',
                    'Track occupancy and income analytics',
                  ],
                  buttonText: 'Sign Up as Owner',
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required bool isTenant,
    required IconData icon,
    required String title,
    required List<String> features,
    required String buttonText,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 480,
      padding: EdgeInsets.all(isMobile ? 28 : 44),
      decoration: BoxDecoration(
        color: isTenant ? AppColors.primary : AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isTenant ? AppColors.primary : AppColors.textPrimary)
                .withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 24 : 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isTenant
                    ? AppColors.primary
                    : AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Accordion FAQ Section
  Widget _buildFAQSection(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 50 : 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Got Questions?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Everything you need to know about the VacanSee community tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              _buildFAQTile(
                'How do I search for a boarding house?',
                'Once registered, you can use our advanced filtering system to search by rent cost, location proximity to major universities in CDO, and preferred room gender orientation.',
              ),
              _buildFAQTile(
                'Is VacanSee completely free?',
                'Yes, VacanSee is 100% free. There are no registration fees, platform listing fees, or tenant search subscription costs. It is built strictly for the student community.',
              ),
              _buildFAQTile(
                'How does the real-time vacancy status update?',
                'Verified property owners have direct access to a simplified vacancy toggle switch in their dashboard. When they click to update room vacancy, the listing updates instantly for all searching tenants.',
              ),
              _buildFAQTile(
                'What verification is needed for owners?',
                'To secure the community from fraudulent listings, we verify property owner accounts using valid government IDs and property proof documents before allowing any listings to go live.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Stack(
        children: [
          // Watermarked Brand Title behind
          Positioned(
            bottom: -30,
            right: -20,
            child: Text(
              'VACANSEE',
              style: TextStyle(
                fontSize: isMobile ? 80 : 120,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.05),
                letterSpacing: 2,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              Text(
                'Ready to Get Started?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 32 : 46,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Join thousands of tenants and owners using VacanSee today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InteractiveHover(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InteractiveHover(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      color: AppColors.textPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 40,
            runSpacing: 40,
            children: [
              // Brand column
              SizedBox(
                width: isMobile ? double.infinity : 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.home_work,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'VacanSee',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your trusted platform for finding\nand managing boarding houses\nin the Philippines.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              // Links columns
              _buildFooterColumn('For Tenants', [
                _buildFooterLink(context, 'Search Listings'),
                _buildFooterLink(context, 'How It Works'),
                _buildFooterLink(context, 'Safety Tips'),
              ], isMobile),
              _buildFooterColumn('For Owners', [
                _buildFooterLink(context, 'List Your Property'),
                _buildFooterLink(context, 'Owner Resources'),
                _buildFooterLink(context, 'Pricing'),
              ], isMobile),
              _buildFooterColumn('Company', [
                _buildFooterLink(context, 'About Us'),
                _buildFooterLink(context, 'Contact'),
                _buildFooterLink(context, 'Privacy Policy'),
              ], isMobile),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),
          const Text(
            '© 2026 VacanSee. All rights reserved.',
            style: TextStyle(fontSize: 14, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<Widget> links, bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFooterTitle(title),
          const SizedBox(height: 20),
          ...links,
        ],
      ),
    );
  }

  Widget _buildFooterTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () => _handleFooterLinkClick(context, text),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  void _handleFooterLinkClick(BuildContext context, String linkText) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curveValue = Curves.easeInOutCubic.transform(anim1.value);
        return Transform.scale(
          scale: 0.95 + (curveValue * 0.05),
          child: Opacity(
            opacity: anim1.value,
            child: _buildModalContent(context, linkText),
          ),
        );
      },
    );
  }

  Widget _buildModalContent(BuildContext context, String linkText) {
    String title = '';
    IconData icon = Icons.info_outline;
    Widget body = const SizedBox.shrink();
    String? actionButtonText;
    VoidCallback? onActionPressed;

    switch (linkText) {
      case 'Search Listings':
        title = 'Search Listings';
        icon = Icons.search_rounded;
        actionButtonText = 'Start Searching Now';
        onActionPressed = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Looking for a place to stay? VacanSee allows you to search and filter verified boarding houses in Cagayan de Oro City based on your preferences:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(Icons.payments_outlined, 'Budget Friendly', 'Filter listings to match your monthly budget range.'),
            _buildModalFeatureItem(Icons.location_on_outlined, 'Location & Proximity', 'Find boarding houses near your university or preferred areas.'),
            _buildModalFeatureItem(Icons.wc_outlined, 'Gender Orientation', 'Filter by male, female, or co-ed accommodations.'),
            _buildModalFeatureItem(Icons.flash_on_outlined, 'Real-time Vacancy', 'See active room availability updated live by owners.'),
          ],
        );
        break;
      case 'How It Works':
        title = 'How It Works';
        icon = Icons.help_outline_rounded;
        actionButtonText = 'Get Started';
        onActionPressed = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Finding your next boarding house has never been easier. Here is how VacanSee simplifies the process:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildStepItem('1', 'Browse & Filter', 'Register and explore verified listings in CDO. Apply filters to narrow down your search.'),
            _buildStepItem('2', 'Reserve a Room', 'Select your preferred room, fill in your details, and submit a booking request.'),
            _buildStepItem('3', 'Owner Approval', 'The property owner reviews your booking. You will be notified instantly once approved.'),
            _buildStepItem('4', 'Move In & Enjoy', 'Coordinate with the owner for check-in. The room vacancy status updates automatically!'),
          ],
        );
        break;
      case 'Safety Tips':
        title = 'Safety Tips';
        icon = Icons.shield_outlined;
        actionButtonText = 'Got It';
        onActionPressed = () => Navigator.pop(context);
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your safety is our top priority. Please keep these tips in mind during your housing search:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(Icons.verified_outlined, 'Verify Listings', 'Whenever possible, visit the property and meet the owner in person before making any payments.'),
            _buildModalFeatureItem(Icons.receipt_long_outlined, 'Keep Records', 'Save receipts, screenshots of chat conversations, and payment confirmations for your safety.'),
            _buildModalFeatureItem(Icons.gavel_outlined, 'Understand Rules', 'Read the boarding house policies, curfew rules, deposit terms, and utility billing guidelines carefully.'),
            _buildModalFeatureItem(Icons.report_problem_outlined, 'Report Suspicious Activity', 'If a listing seems fraudulent, misleading, or inappropriate, report it to our support team immediately.'),
          ],
        );
        break;
      case 'List Your Property':
        title = 'List Your Property';
        icon = Icons.add_business_outlined;
        actionButtonText = 'Sign Up as Owner';
        onActionPressed = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Connect with thousands of students in Cagayan de Oro City. List your boarding house and manage it stress-free:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(Icons.bolt_outlined, 'Real-Time Vacancy Updates', 'Update your room availability status with a single click. Keep students informed.'),
            _buildModalFeatureItem(Icons.dashboard_outlined, 'Interactive Owner Dashboard', 'Manage all your properties, units, and room bookings in one streamlined platform.'),
            _buildModalFeatureItem(Icons.notifications_active_outlined, 'Instant Booking Notifications', 'Receive instant notifications when students request to book your rooms.'),
          ],
        );
        break;
      case 'Owner Resources':
        title = 'Owner Resources';
        icon = Icons.menu_book_outlined;
        actionButtonText = 'Register Property';
        onActionPressed = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Maximize your property listings and manage vacancies efficiently with our curated guides and tips:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(Icons.photo_library_outlined, 'High-Quality Listings', 'Properties with clear photos of rooms, common areas, and amenities receive 3x more bookings.'),
            _buildModalFeatureItem(Icons.star_rate_rounded, 'Build Trust with Reviews', 'Encourage your tenants to leave feedback. Higher ratings attract more verified bookings.'),
            _buildModalFeatureItem(Icons.support_agent_outlined, '24/7 Support', 'Get help from our support team to onboard your properties and verify your landlord account.'),
          ],
        );
        break;
      case 'Pricing':
        title = 'VacanSee Pricing';
        icon = Icons.sell_outlined;
        actionButtonText = 'Start Free (Always Free)';
        onActionPressed = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Our mission is to help students find housing easily. VacanSee is completely free to use:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.primary, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Plan - ₱0 / month',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '100% free for students and property owners. No hidden transaction fees, commissions, or subscription costs.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case 'About Us':
        title = 'About VacanSee';
        icon = Icons.info_outline_rounded;
        actionButtonText = 'Join the Community';
        onActionPressed = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'VacanSee is a real-time boarding house vacancy tracker designed for university students in Cagayan de Oro City.',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Finding accommodation near universities can be extremely frustrating, often requiring hours of walking under the sun or dealing with outdated listings. VacanSee bridges the gap by letting students filter listings by budget, location, and gender orientation, while property owners update room availability in real-time.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Target launch: Academic Year 2025-2026.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        );
        break;
      case 'Contact':
        title = 'Contact Us';
        icon = Icons.email_outlined;
        actionButtonText = 'Send Message';
        onActionPressed = () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Thank you! Your message has been sent successfully.'),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Have questions, feedback, or need help verifying your account? Reach out to us directly:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildContactInfoItem(Icons.email_outlined, 'Email Support', 'support@vacansee.ph'),
            _buildContactInfoItem(Icons.phone_outlined, 'Phone', '+63 912 345 6789'),
            _buildContactInfoItem(Icons.location_on_outlined, 'Location', 'CDO City, Misamis Oriental, Philippines'),
          ],
        );
        break;
      case 'Privacy Policy':
        title = 'Privacy Policy';
        icon = Icons.privacy_tip_outlined;
        actionButtonText = 'Accept & Close';
        onActionPressed = () => Navigator.pop(context);
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We respect your privacy. Here is how we handle and protect your personal information:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(Icons.lock_outline_rounded, 'Secure Data Encryption', 'All user credentials and personal details are encrypted and securely stored in Supabase.'),
            _buildModalFeatureItem(Icons.supervised_user_circle_outlined, 'Verified Profiles Only', 'We strictly require phone and role verification to protect the community from fake listings.'),
            _buildModalFeatureItem(Icons.visibility_off_outlined, 'No Third-Party Sharing', 'Your contact info and emergency details are only shared with the respective owner when booking a room.'),
          ],
        );
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 550,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: AppColors.textPrimary,
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Body Content (scrollable if long)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: body,
              ),
            ),
            // Footer Action Button
            if (actionButtonText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    actionButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String stepNumber, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
