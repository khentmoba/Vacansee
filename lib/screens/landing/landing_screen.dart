import 'package:flutter/material.dart';
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
                _buildRoles(context, isMobile, padding),
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
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5287B2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.home_work, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'VacanSee',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1B16),
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
                    foregroundColor: const Color(0xFF1D1B16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isMobile ? 'Join' : 'Sign Up',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          // Decorative polygon top right
          if (!isMobile)
            Positioned(
              top: 0,
              right: 0,
              child: CustomPaint(
                size: const Size(400, 400),
                painter: _HeroPolygonPainter(),
              ),
            ),
          // Decorative circle bottom left
          if (!isMobile)
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF5287B2).withValues(alpha: 0.15),
                      const Color(0xFF5287B2).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: isMobile ? 40 : 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isMobile ? 40 : 72,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Find Your Perfect\n',
                        style: TextStyle(color: Color(0xFF1D1B16)),
                      ),
                      TextSpan(
                        text: 'Boarding House',
                        style: TextStyle(color: Color(0xFF5287B2)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                // Subtitle
                Text(
                  isMobile
                      ? "Discover, book, and manage boarding houses. Whether you're searching for a place to stay or managing properties, we've got you covered."
                      : "VacanSee makes it easy to discover, book, and manage\nboarding houses. Whether you're searching for a place to stay or managing\nproperties, we've got you covered.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: const Color(0xFF666666),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: isMobile ? 32 : 40),
                // Buttons
                Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5287B2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isMobile ? 12 : 0,
                      width: isMobile ? 0 : 16,
                    ),
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: OutlinedButton(
                        onPressed: () {
                          if (isMobile) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5287B2),
                          side: const BorderSide(
                            color: Color(0xFF5287B2),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isMobile ? 'Sign In' : 'Learn More',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildFeatures(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 40 : 80,
      ),
      color: const Color(0xFFF8FBFD),
      child: Column(
        children: [
          Text(
            'Why Choose VacanSee?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 42,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Everything you need to find or manage boarding houses in one place',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          if (isMobile)
            Column(
              children: [
                _buildFeatureCard(
                  Icons.search,
                  'Easy Search',
                  'Find the perfect boarding house with powerful filters. Search by location, price, amenities, and availability in seconds.',
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  Icons.check_circle_outline,
                  'Quick Booking',
                  'Book your ideal room with just a few clicks. Track your bookings, communicate with owners, and manage everything in one place.',
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  Icons.star_border,
                  'Verified Reviews',
                  'Read honest reviews from real tenants. Make informed decisions based on ratings, photos, and detailed feedback.',
                  isMobile,
                ),
              ],
            )
          else
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFeatureCard(
                    Icons.search,
                    'Easy Search',
                    'Find the perfect boarding house with powerful filters. Search by location, price, amenities, and availability in seconds.',
                    isMobile,
                  ),
                  const SizedBox(width: 24),
                  _buildFeatureCard(
                    Icons.check_circle_outline,
                    'Quick Booking',
                    'Book your ideal room with just a few clicks. Track your bookings, communicate with owners, and manage everything in one place.',
                    isMobile,
                  ),
                  const SizedBox(width: 24),
                  _buildFeatureCard(
                    Icons.star_border,
                    'Verified Reviews',
                    'Read honest reviews from real tenants. Make informed decisions based on ratings, photos, and detailed feedback.',
                    isMobile,
                  ),
                ],
              ),
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
      width: isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF5287B2).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF5287B2)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B16),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.6,
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
        vertical: isMobile ? 40 : 80,
      ),
      color: Colors.white,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 32,
        runSpacing: 32,
        children: [
          // Tenant Card
          _buildRoleCard(
            context,
            isTenant: true,
            icon: Icons.people_outline,
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
          // Owner Card
          _buildRoleCard(
            context,
            isTenant: false,
            icon: Icons.business,
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
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: isTenant ? const Color(0xFF5287B2) : const Color(0xFF1D1B16),
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
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
                    ? const Color(0xFF5287B2)
                    : const Color(0xFF1D1B16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5287B2), Color(0xFF3D6A8C)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative shapes
          if (!isMobile) ...[
            Positioned(
              top: -50,
              left: 100,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: _CTAPolygonPainter(),
              ),
            ),
            Positioned(
              bottom: -100,
              right: 50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          // Content
          Column(
            children: [
              Text(
                'Ready to Get Started?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 32 : 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Join thousands of tenants and owners using VacanSee today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF5287B2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 0, width: isMobile ? 0 : 16),
                  SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
      color: const Color(0xFF1D1B16),
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
                            color: const Color(0xFF5287B2),
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
                color: const Color(0xFF5287B2).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF5287B2).withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF5287B2), size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Plan - ₱0 / month',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D1B16)),
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
              style: TextStyle(fontSize: 15, color: Color(0xFF1D1B16), fontWeight: FontWeight.w600, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Finding accommodation near universities can be extremely frustrating, often requiring hours of walking under the sun or dealing with outdated listings. VacanSee bridges the gap by letting students filter listings by budget, location, and gender orientation, while property owners update room availability in real-time.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Target launch: Academic Year 2025-2026.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5287B2)),
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
              backgroundColor: const Color(0xFF5287B2),
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
              color: const Color(0xFF1D1B16),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF5287B2), size: 28),
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
                    backgroundColor: const Color(0xFF5287B2),
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
              color: const Color(0xFF5287B2).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF5287B2), size: 20),
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
                    color: Color(0xFF1D1B16),
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
              color: Color(0xFF1D1B16),
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
                    color: Color(0xFF1D1B16),
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
          Icon(icon, color: const Color(0xFF5287B2), size: 24),
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
                    color: Color(0xFF1D1B16),
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

class _HeroPolygonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF5287B2).withValues(alpha: 0.2),
          const Color(0xFF5287B2).withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.8)
      ..lineTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CTAPolygonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.7, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
