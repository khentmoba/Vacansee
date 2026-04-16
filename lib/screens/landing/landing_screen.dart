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
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                SizedBox(height: isMobile ? 40 : 60),
                // Stats
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: isMobile ? 20 : 40,
                  runSpacing: 24,
                  children: [
                    _buildStat('500+', 'Boarding Houses', isMobile),
                    _buildStat('1,200+', 'Happy Tenants', isMobile),
                    _buildStat('4.8/5', 'Average Rating', isMobile),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String number, String label, bool isMobile) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5287B2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context, bool isMobile, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 40 : 80),
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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildFeatureCard(
                Icons.search,
                'Easy Search',
                'Find the perfect boarding house with powerful filters. Search by location, price, amenities, and availability in seconds.',
                isMobile,
              ),
              _buildFeatureCard(
                Icons.check_circle_outline,
                'Quick Booking',
                'Book your ideal room with just a few clicks. Track your bookings, communicate with owners, and manage everything in one place.',
                isMobile,
              ),
              _buildFeatureCard(
                Icons.star_border,
                'Verified Reviews',
                'Read honest reviews from real tenants. Make informed decisions based on ratings, photos, and detailed feedback.',
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, bool isMobile) {
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
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 40 : 80),
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
          if (!isMobile) const SizedBox(width: 32),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 60 : 80),
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
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
                  SizedBox(
                    height: isMobile ? 12 : 0,
                    width: isMobile ? 0 : 16,
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 40 : 60),
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
                _buildFooterLink('Search Listings'),
                _buildFooterLink('How It Works'),
                _buildFooterLink('Safety Tips'),
              ], isMobile),
              _buildFooterColumn('For Owners', [
                _buildFooterLink('List Your Property'),
                _buildFooterLink('Owner Resources'),
                _buildFooterLink('Pricing'),
              ], isMobile),
              _buildFooterColumn('Company', [
                _buildFooterLink('About Us'),
                _buildFooterLink('Contact'),
                _buildFooterLink('Privacy Policy'),
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

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () {},
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
