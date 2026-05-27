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
      backgroundColor: const Color(
        0xFFF0F9FF,
      ), // Light Sky Blue matching React bg-[#F0F9FF]
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final padding = isMobile ? 24.0 : 80.0;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Main Hero Container (Navbar overlayed inside)
                    _buildHeroSection(context, isMobile, padding),
                    _buildInfoSection(context, isMobile, padding),
                    _buildFeaturesMarquee(context, isMobile, padding),
                    _buildLandlordSection(context, isMobile, padding),
                    _buildFooter(context, isMobile, padding),
                  ],
                ),
              ),
              // Fixed absolute navbar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildNavbar(context, isMobile, padding),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Navbar ---
  Widget _buildNavbar(BuildContext context, bool isMobile, double padding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Logo + Title
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LogoIcon(size: 28, color: Colors.black.withValues(alpha: 0.9)),
                const SizedBox(width: 10),
                const Text(
                  'VacanSee',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Center Nav Items (Desktop only)
          if (!isMobile)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavLink(context, 'Map View', '#map-view'),
                const SizedBox(width: 32),
                _buildNavLink(context, 'Neighborhoods', '#neighborhoods'),
                const SizedBox(width: 32),
                _buildNavLink(context, 'Landlords', '#landlords'),
                const SizedBox(width: 32),
                _buildNavLink(context, 'Help', '#help'),
              ],
            ),
          // Right CTA button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InteractiveHover(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Find a Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              if (isMobile) ...[
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => _showMobileMenu(context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String label, String section) {
    return InteractiveHover(
      child: GestureDetector(
        onTap: () => _handleNavLinkTap(context, label),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151), // Slate 700
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _handleNavLinkTap(BuildContext context, String label) {
    _handleFooterLinkClick(context, label == 'Help' ? 'About Us' : label);
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF0F9FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: const Text('Map View'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleNavLinkTap(context, 'Map View');
                  },
                ),
                ListTile(
                  title: const Text('Neighborhoods'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleNavLinkTap(context, 'Neighborhoods');
                  },
                ),
                ListTile(
                  title: const Text('Landlords'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleNavLinkTap(context, 'Landlords');
                  },
                ),
                ListTile(
                  title: const Text('Help'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleNavLinkTap(context, 'Help');
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Find a Room'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Hero Section ---
  Widget _buildHeroSection(
    BuildContext context,
    bool isMobile,
    double padding,
  ) {
    return Container(
      width: double.infinity,
      height: isMobile ? null : 800,
      constraints: const BoxConstraints(minHeight: 650),
      padding: EdgeInsets.fromLTRB(padding, isMobile ? 120 : 100, padding, 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero-bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            // Soft Light Editorial Gradient Overlay matching React bg
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFFF0F9FF).withValues(alpha: 0.95),
                      const Color(0xFFF0F9FF).withValues(alpha: 0.75),
                      const Color(0xFFF0F9FF).withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 64,
                vertical: 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    'Your Next Home\nAwaits',
                    style: TextStyle(
                      fontSize: 48,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.8,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: const Text(
                      'A seamless, map-driven tracker to find the best boarding houses, dorms, and pad spaces near USTP and across Cagayan de Oro.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // CTAs
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      InteractiveHover(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(28, 12, 10, 12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start browsing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 20),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.secondary,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InteractiveHover(
                        child: GestureDetector(
                          onTap: () => _handleNavLinkTap(context, 'Map View'),
                          child: const Text(
                            'View map first',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  // Marquee container
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      padding: const EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: _buildLocationMarquee(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMarquee() {
    final List<Widget> items = [
      _buildMarqueeText(
        'USTP Campus',
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        ),
      ),
      _buildMarqueeText(
        'Limketkai Center',
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      _buildMarqueeText(
        'Divisoria',
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      _buildMarqueeText(
        'Xavier University',
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      _buildMarqueeText(
        'Liceo de Cagayan',
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      _buildMarqueeText(
        'Carmen Market',
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    ];

    return SizedBox(height: 40, child: MarqueeRow(children: items));
  }

  Widget _buildMarqueeText(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Text(
        text,
        style: style.copyWith(color: Colors.black.withValues(alpha: 0.6)),
      ),
    );
  }

  // --- Info Section ---
  Widget _buildInfoSection(
    BuildContext context,
    bool isMobile,
    double padding,
  ) {
    return Container(
      color: const Color(0xFFF0F9FF),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1 Heading and description
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Student Living.',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Find verified boarding houses that fit your budget, complete with transparent pricing, accurate amenity filters, and direct landlord contact.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildExploreMapButton(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Student Living.',
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.5,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildExploreMapButton(context),
                        ],
                      ),
                    ),
                    const SizedBox(width: 80),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Find verified boarding houses that fit your budget, complete with transparent pricing, accurate amenity filters, and direct landlord contact.',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.6,
                            color: Colors.black87,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 64),
          // 4-Column Layout Grid (Adapted to Flutter)
          isMobile
              ? Column(
                  children: [
                    _buildFocusCard(double.infinity, 360),
                    const SizedBox(height: 24),
                    _buildTextGridCard(
                      icon: Icons.map_outlined,
                      title: 'Walk to class,\nsave time.',
                      desc:
                          'View exact distances to major university gates and local transport routes.',
                    ),
                    const SizedBox(height: 24),
                    _buildTextGridCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Verified\nlistings.',
                      desc:
                          'Every pad is checked for accuracy. Say goodbye to outdated photos and hidden utility fees.',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildFocusCard(double.infinity, 380),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTextGridCard(
                        icon: Icons.map_outlined,
                        title: 'Walk to class,\nsave time.',
                        desc:
                            'View exact distances to major university gates and local transport routes.',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTextGridCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Verified\nlistings.',
                        desc:
                            'Every pad is checked for accuracy. Say goodbye to outdated photos and hidden utility fees.',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildExploreMapButton(BuildContext context) {
    return InteractiveHover(
      child: GestureDetector(
        onTap: () => _handleNavLinkTap(context, 'Map View'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 6, 8),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explore map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.secondary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusCard(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/desk-setup.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'AMENITIES FOCUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Designed for focus',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Text(
                        'Filter by essential amenities like inclusive WiFi, study areas, and curfew rules to match your academic schedule.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextGridCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Deep slate matching React UI
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // --- Features Continuous Marquee ---
  Widget _buildFeaturesMarquee(
    BuildContext context,
    bool isMobile,
    double padding,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 64),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        border: Border(
          top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.1)),
          bottom: BorderSide(color: AppColors.secondary.withValues(alpha: 0.1)),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by the amenities\nthat matter most to you.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                _buildAmenitiesMarqueeRow(),
              ],
            )
          : Row(
              children: [
                const SizedBox(
                  width: 250,
                  child: Text(
                    'Filter by the amenities\nthat matter most to you.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: _buildAmenitiesMarqueeRow()),
              ],
            ),
    );
  }

  Widget _buildAmenitiesMarqueeRow() {
    final List<Widget> items = [
      _buildMarqueeText(
        'Free High-Speed WiFi',
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      _buildMarqueeText(
        'No Curfew',
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
      _buildMarqueeText(
        'Cooking Allowed',
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      _buildMarqueeText(
        'Inclusive Utilities',
        const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      _buildMarqueeText(
        'CCTV Security',
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      _buildMarqueeText(
        'In-house Laundry',
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      _buildMarqueeText(
        'Solo Rooms',
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ];

    return SizedBox(
      height: 40,
      child: MarqueeRow(duration: const Duration(seconds: 40), children: items),
    );
  }

  // --- Landlord Section ---
  Widget _buildLandlordSection(
    BuildContext context,
    bool isMobile,
    double padding,
  ) {
    return Container(
      color: const Color(0xFFF0F9FF),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLandlordTextContent(context),
                const SizedBox(height: 48),
                _buildLandlordShowcaseCard(context, double.infinity),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildLandlordTextContent(context)),
                const SizedBox(width: 80),
                Expanded(
                  child: _buildLandlordShowcaseCard(context, double.infinity),
                ),
              ],
            ),
    );
  }

  Widget _buildLandlordTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE PLATFORM IN PRACTICE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Built for Everyone',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Whether you are a student looking for a secure place to stay or a property owner managing multiple rooms, the platform adapts to your needs.',
          style: TextStyle(fontSize: 17, height: 1.6, color: Colors.black87),
        ),
        const SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn('0%', 'Listing Fees'),
              _buildMetricColumn('100%', 'Verified Landlords'),
              _buildMetricColumn('Real-time', 'Vacancy Status'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricColumn(String mainVal, String subVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mainVal,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subVal.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLandlordShowcaseCard(BuildContext context, double width) {
    return Container(
      width: width,
      height: 560,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/property-owner.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'OWNER DASHBOARD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'For Property Owners',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fill your vacant beds faster. Showcase your property with high-quality galleries, list clear house rules, and manage tenant inquiries directly from your customized owner dashboard.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                InteractiveHover(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'List your property',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Footer ---
  Widget _buildFooter(BuildContext context, bool isMobile, double padding) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(padding, 80, padding, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterBrandColumn(),
                    const SizedBox(height: 48),
                    _buildFooterLinkGroup('For Tenants', [
                      'Search Rooms',
                      'Near USTP',
                      'Near Xavier',
                      'Student Guides',
                    ], context),
                    const SizedBox(height: 32),
                    _buildFooterLinkGroup('For Owners', [
                      'List Property',
                      'Owner Dashboard',
                      'Resource Center',
                      'Premium Listing',
                    ], context),
                    const SizedBox(height: 32),
                    _buildFooterLinkGroup('Company', [
                      'About Us',
                      'Contact Support',
                      'Privacy Policy',
                      'Terms of Service',
                    ], context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildFooterBrandColumn()),
                    const SizedBox(width: 48),
                    Expanded(
                      child: _buildFooterLinkGroup('For Tenants', [
                        'Search Rooms',
                        'Near USTP',
                        'Near Xavier',
                        'Student Guides',
                      ], context),
                    ),
                    Expanded(
                      child: _buildFooterLinkGroup('For Owners', [
                        'List Property',
                        'Owner Dashboard',
                        'Resource Center',
                        'Premium Listing',
                      ], context),
                    ),
                    Expanded(
                      child: _buildFooterLinkGroup('Company', [
                        'About Us',
                        'Contact Support',
                        'Privacy Policy',
                        'Terms of Service',
                      ], context),
                    ),
                  ],
                ),
          const SizedBox(height: 64),
          Container(
            padding: const EdgeInsets.only(top: 32),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '© ${DateTime.now().year} VacanSee. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
                if (isMobile) const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Designed for CDO Students',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      'Academic Year 2025-2026',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
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

  Widget _buildFooterBrandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoIcon(size: 32, color: AppColors.secondary),
            const SizedBox(width: 12),
            const Text(
              'VacanSee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Real-time boarding house and dorm tracker for university students in Cagayan de Oro City. Find verified spaces and connect with landlords.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinkGroup(
    String title,
    List<String> links,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InteractiveHover(
              child: GestureDetector(
                onTap: () => _handleFooterLinkClick(context, link),
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Modal Content Logic ---
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
      case 'Search Rooms':
      case 'Search Listings':
      case 'Near USTP':
      case 'Near Xavier':
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(
              Icons.payments_outlined,
              'Budget Friendly',
              'Filter listings to match your monthly budget range.',
            ),
            _buildModalFeatureItem(
              Icons.location_on_outlined,
              'Location & Proximity',
              'Find boarding houses near your university or preferred areas.',
            ),
            _buildModalFeatureItem(
              Icons.wc_outlined,
              'Gender Orientation',
              'Filter by male, female, or co-ed accommodations.',
            ),
            _buildModalFeatureItem(
              Icons.flash_on_outlined,
              'Real-time Vacancy',
              'See active room availability updated live by owners.',
            ),
          ],
        );
        break;
      case 'How It Works':
      case 'Student Guides':
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildStepItem(
              '1',
              'Browse & Filter',
              'Register and explore verified listings in CDO. Apply filters to narrow down your search.',
            ),
            _buildStepItem(
              '2',
              'Reserve a Room',
              'Select your preferred room, fill in your details, and submit a booking request.',
            ),
            _buildStepItem(
              '3',
              'Owner Approval',
              'The property owner reviews your booking. You will be notified instantly once approved.',
            ),
            _buildStepItem(
              '4',
              'Move In & Enjoy',
              'Coordinate with the owner for check-in. The room vacancy status updates automatically!',
            ),
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(
              Icons.verified_outlined,
              'Verify Listings',
              'Whenever possible, visit the property and meet the owner in person before making any payments.',
            ),
            _buildModalFeatureItem(
              Icons.receipt_long_outlined,
              'Keep Records',
              'Save receipts, screenshots of chat conversations, and payment confirmations for your safety.',
            ),
            _buildModalFeatureItem(
              Icons.gavel_outlined,
              'Understand Rules',
              'Read the boarding house policies, curfew rules, deposit terms, and utility billing guidelines carefully.',
            ),
            _buildModalFeatureItem(
              Icons.report_problem_outlined,
              'Report Suspicious Activity',
              'If a listing seems fraudulent, misleading, or inappropriate, report it to our support team immediately.',
            ),
          ],
        );
        break;
      case 'List Property':
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(
              Icons.bolt_outlined,
              'Real-Time Vacancy Updates',
              'Update your room availability status with a single click. Keep students informed.',
            ),
            _buildModalFeatureItem(
              Icons.dashboard_outlined,
              'Interactive Owner Dashboard',
              'Manage all your properties, units, and room bookings in one streamlined platform.',
            ),
            _buildModalFeatureItem(
              Icons.notifications_active_outlined,
              'Instant Booking Notifications',
              'Receive instant notifications when students request to book your rooms.',
            ),
          ],
        );
        break;
      case 'Owner Dashboard':
      case 'Resource Center':
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(
              Icons.photo_library_outlined,
              'High-Quality Listings',
              'Properties with clear photos of rooms, common areas, and amenities receive 3x more bookings.',
            ),
            _buildModalFeatureItem(
              Icons.star_rate_rounded,
              'Build Trust with Reviews',
              'Encourage your tenants to leave feedback. Higher ratings attract more verified bookings.',
            ),
            _buildModalFeatureItem(
              Icons.support_agent_outlined,
              '24/7 Support',
              'Get help from our support team to onboard your properties and verify your landlord account.',
            ),
          ],
        );
        break;
      case 'Pricing':
      case 'Premium Listing':
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Plan - ₱0 / month',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '100% free for students and property owners. No hidden transaction fees, commissions, or subscription costs.',
                          style: TextStyle(
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
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Finding accommodation near universities can be extremely frustrating, often requiring hours of walking under the sun or dealing with outdated listings. VacanSee bridges the gap by letting students filter listings by budget, location, and gender orientation, while property owners update room availability in real-time.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Target launch: Academic Year 2025-2026.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        );
        break;
      case 'Contact Support':
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        };
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Have questions, feedback, or need help verifying your account? Reach out to us directly:',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildContactInfoItem(
              Icons.email_outlined,
              'Email Support',
              'support@vacansee.ph',
            ),
            _buildContactInfoItem(
              Icons.phone_outlined,
              'Phone',
              '+63 912 345 6789',
            ),
            _buildContactInfoItem(
              Icons.location_on_outlined,
              'Location',
              'CDO City, Misamis Oriental, Philippines',
            ),
          ],
        );
        break;
      case 'Privacy Policy':
      case 'Terms of Service':
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalFeatureItem(
              Icons.lock_outline_rounded,
              'Secure Data Encryption',
              'All user credentials and personal details are encrypted and securely stored in Supabase.',
            ),
            _buildModalFeatureItem(
              Icons.supervised_user_circle_outlined,
              'Verified Profiles Only',
              'We strictly require phone and role verification to protect the community from fake listings.',
            ),
            _buildModalFeatureItem(
              Icons.visibility_off_outlined,
              'No Third-Party Sharing',
              'Your contact info and emergency details are only shared with the respective owner when booking a room.',
            ),
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: body,
              ),
            ),
            if (actionButtonText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed,
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

  Widget _buildModalFeatureItem(
    IconData icon,
    String title,
    String description,
  ) {
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

// --- Logo Painter ---
class LogoIcon extends StatelessWidget {
  final double size;
  final Color color;

  const LogoIcon({super.key, this.size = 28, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _LogoPainter(color));
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.08); // Top Roof Tip
    path.lineTo(size.width * 0.125, size.height * 0.38); // Left Eaves
    path.lineTo(size.width * 0.25, size.height * 0.38); // Left Wall Start
    path.lineTo(size.width * 0.25, size.height * 0.88); // Left Wall Bottom
    path.lineTo(size.width * 0.75, size.height * 0.88); // Right Wall Bottom
    path.lineTo(size.width * 0.75, size.height * 0.38); // Right Wall Start
    path.lineTo(size.width * 0.875, size.height * 0.38); // Right Eaves
    path.close();

    // Inner Doorway
    path.moveTo(size.width * 0.38, size.height * 0.88);
    path.lineTo(size.width * 0.38, size.height * 0.50);
    path.lineTo(size.width * 0.62, size.height * 0.50);
    path.lineTo(size.width * 0.62, size.height * 0.88);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Marquee Helper Row ---
class MarqueeRow extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;

  const MarqueeRow({
    super.key,
    required this.children,
    this.duration = const Duration(seconds: 30),
  });

  @override
  State<MarqueeRow> createState() => _MarqueeRowState();
}

class _MarqueeRowState extends State<MarqueeRow> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    if (!mounted || !_scrollController.hasClients) return;
    double maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll == 0) return;

    await _scrollController.animateTo(
      maxScroll,
      duration: widget.duration,
      curve: Curves.linear,
    );

    if (mounted) {
      _scrollController.jumpTo(0);
      _startScrolling();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doubledItems = [
      ...widget.children,
      ...widget.children,
      ...widget.children,
      ...widget.children,
    ];
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(children: doubledItems),
    );
  }
}
