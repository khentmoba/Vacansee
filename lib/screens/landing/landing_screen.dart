import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/interactive_hover.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _heroTextAnim;
  late Animation<double> _heroSubAnim;
  late Animation<double> _heroCtaAnim;
  late Animation<double> _heroTrustAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _heroTextAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );
    _heroSubAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
    );
    _heroCtaAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
    );
    _heroTrustAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final padding = isMobile ? 24.0 : 80.0;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroSection(context, isMobile, padding),
                    _buildInfoSection(context, isMobile, padding),
                    _buildFeaturesMarquee(context, isMobile, padding),
                    _buildOwnerSection(context, isMobile, padding),
                    _buildCtaBanner(context, isMobile, padding),
                    _buildFooter(context, isMobile, padding),
                  ],
                ),
              ),
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
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LogoIcon(size: 28, color: AppColors.primary),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    'VacanSee',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
                  onPressed: () => _showMobileMenu(context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F9FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LogoIcon(size: 28, color: AppColors.primary),
                          const SizedBox(width: 10),
                          const Text(
                            'VacanSee',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildMobileMenuItem(ctx, 'Home', Icons.home_outlined, () {
                    Navigator.pop(ctx);
                  }),
                  _buildMobileMenuItem(
                    ctx,
                    'How It Works',
                    Icons.explore_outlined,
                    () {
                      Navigator.pop(ctx);
                      _handleFooterLinkClick(context, 'How It Works');
                    },
                  ),
                  _buildMobileMenuItem(
                    ctx,
                    'For Owners',
                    Icons.business_outlined,
                    () {
                      Navigator.pop(ctx);
                      _handleFooterLinkClick(context, 'List Property');
                    },
                  ),
                  _buildMobileMenuItem(
                    ctx,
                    'About Us',
                    Icons.info_outline_rounded,
                    () {
                      Navigator.pop(ctx);
                      _handleFooterLinkClick(context, 'About Us');
                    },
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: const Center(
                          child: Text(
                            'Find a Room',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(
    BuildContext ctx,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ],
        ),
      ),
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero-bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: const Alignment(0.6, 1.0),
                    colors: [
                      const Color(0xFFF0F9FF).withValues(alpha: 0.97),
                      const Color(0xFFF0F9FF).withValues(alpha: 0.7),
                      const Color(0xFFF0F9FF).withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
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
                  _buildAnimatedHeroText(isMobile),
                  const SizedBox(height: 24),
                  _buildAnimatedHeroSubtitle(isMobile),
                  const SizedBox(height: 40),
                  _buildHeroCtas(context, isMobile),
                  const SizedBox(height: 40),
                  _buildTrustIndicators(isMobile),
                  const Spacer(flex: 2),
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

  Widget _buildAnimatedHeroText(bool isMobile) {
    return AnimatedBuilder(
      animation: _heroTextAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _heroTextAnim.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - _heroTextAnim.value)),
            child: child,
          ),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(
          'Your Next Home\nAwaits',
          style: TextStyle(
            fontSize: isMobile ? 40 : 64,
            height: 1.08,
            fontWeight: FontWeight.w700,
            letterSpacing: -2.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeroSubtitle(bool isMobile) {
    return AnimatedBuilder(
      animation: _heroSubAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _heroSubAnim.value,
          child: Transform.translate(
            offset: Offset(0, 25 * (1.0 - _heroSubAnim.value)),
            child: child,
          ),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Text(
          'A seamless way to find verified boarding houses, dorms, and pad spaces near USTP and across Cagayan de Oro.',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            height: 1.6,
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCtas(BuildContext context, bool isMobile) {
    return AnimatedBuilder(
      animation: _heroCtaAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _heroCtaAnim.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - _heroCtaAnim.value)),
            child: child,
          ),
        );
      },
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
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
                padding: const EdgeInsets.fromLTRB(32, 14, 14, 14),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Start browsing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InteractiveHover(
            child: GestureDetector(
              onTap: () => _handleFooterLinkClick(context, 'How It Works'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'How it works',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIndicators(bool isMobile) {
    return AnimatedBuilder(
      animation: _heroTrustAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _heroTrustAnim.value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1.0 - _heroTrustAnim.value)),
            child: child,
          ),
        );
      },
      child: isMobile
          ? Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildTrustItem(Icons.people_outline, '500+', 'Students'),
                _buildTrustItem(Icons.home_outlined, '50+', 'Properties'),
                _buildTrustItem(
                  Icons.check_circle_outline,
                  '100%',
                  'Free',
                ),
              ],
            )
          : Row(
              children: [
                _buildTrustItem(Icons.people_outline, '500+', 'Students'),
                const SizedBox(width: 40),
                _buildTrustItem(Icons.home_outlined, '50+', 'Properties'),
                const SizedBox(width: 40),
                _buildTrustItem(Icons.check_circle_outline, '100%', 'Free'),
              ],
            ),
    );
  }

  Widget _buildTrustItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF0F172A).withValues(alpha: 0.6),
          ),
        ),
      ],
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
        style: style.copyWith(
          color: const Color(0xFF0F172A).withValues(alpha: 0.5),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 60 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '01 \u2014 DISCOVER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoHeading(isMobile),
                    const SizedBox(height: 24),
                    _buildInfoDescription(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildInfoHeading(isMobile)),
                    const SizedBox(width: 80),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildInfoDescription(isMobile),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 64),
          isMobile
              ? Column(
                  children: [
                    _buildFocusCard(double.infinity, 360),
                    const SizedBox(height: 24),
                    _buildTextGridCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Verified\nlistings.',
                      desc:
                          'Every pad is checked for accuracy. Say goodbye to outdated photos and hidden utility fees.',
                    ),
                    const SizedBox(height: 24),
                    _buildTextGridCard(
                      icon: Icons.sync_rounded,
                      title: 'Real-time\nvacancy.',
                      desc:
                          'See live room availability updated instantly by owners. No more wasted trips or false leads.',
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
                        icon: Icons.verified_user_outlined,
                        title: 'Verified\nlistings.',
                        desc:
                            'Every pad is checked for accuracy. Say goodbye to outdated photos and hidden utility fees.',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTextGridCard(
                        icon: Icons.sync_rounded,
                        title: 'Real-time\nvacancy.',
                        desc:
                            'See live room availability updated instantly by owners. No more wasted trips or false leads.',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildInfoHeading(bool isMobile) {
    return Text(
      'Smart Student\nLiving.',
      style: TextStyle(
        fontSize: isMobile ? 36 : 58,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: Colors.black,
        height: 1.05,
      ),
    );
  }

  Widget _buildInfoDescription(bool isMobile) {
    return Text(
      'Find verified boarding houses that fit your budget, complete with transparent pricing, accurate amenity filters, and direct property owner contact.',
      style: TextStyle(
        fontSize: isMobile ? 16 : 20,
        height: 1.6,
        color: const Color(0xFF1E293B).withValues(alpha: 0.75),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFocusCard(double width, double height) {
    return InteractiveHover(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'AMENITIES FOCUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Designed for\nfocus',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
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
      ),
    );
  }

  Widget _buildTextGridCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
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
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        border: Border(
          top: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.08),
          ),
          bottom: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '02 \u2014 AMENITIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by what\nmatters most.',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.2,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAmenitiesMarqueeRow(),
                  ],
                )
              : Row(
                  children: [
                    const SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter by what\nmatters most to you.',
                            style: TextStyle(
                              fontSize: 28,
                              height: 1.2,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Choose from essential amenities to find the perfect place that matches your lifestyle.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(child: _buildAmenitiesMarqueeRow()),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesMarqueeRow() {
    final List<Widget> items = [
      _buildAmenityChip('Free High-Speed WiFi', Icons.wifi),
      _buildAmenityChip('No Curfew', Icons.schedule),
      _buildAmenityChip('Cooking Allowed', Icons.restaurant),
      _buildAmenityChip('Inclusive Utilities', Icons.bolt),
      _buildAmenityChip('CCTV Security', Icons.security),
      _buildAmenityChip('In-house Laundry', Icons.local_laundry_service),
      _buildAmenityChip('Solo Rooms', Icons.meeting_room),
    ];

    return SizedBox(
      height: 60,
      child: MarqueeRow(
        duration: const Duration(seconds: 40),
        children: items,
      ),
    );
  }

  Widget _buildAmenityChip(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // --- Owner Section ---
  Widget _buildOwnerSection(
    BuildContext context,
    bool isMobile,
    double padding,
  ) {
    return Container(
      color: const Color(0xFFF0F9FF),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 60 : 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '03 \u2014 FOR OWNERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOwnerTextContent(context),
                    const SizedBox(height: 48),
                    _buildOwnerShowcaseCard(context, double.infinity),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildOwnerTextContent(context)),
                    const SizedBox(width: 80),
                    Expanded(
                      child: _buildOwnerShowcaseCard(context, double.infinity),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildOwnerTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Empower Your Property',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            color: Colors.black,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Whether you are a student looking for a secure place to stay or a property owner managing multiple rooms, the platform adapts to your needs.',
          style: TextStyle(
            fontSize: 17,
            height: 1.6,
            color: Color(0xFF1E293B),
          ),
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
          child: Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _buildMetricColumn('0%', 'Listing Fees'),
              _buildMetricColumn('100%', 'Verified Properties'),
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
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerShowcaseCard(BuildContext context, double width) {
    return InteractiveHover(
      child: Container(
        width: width,
        height: 560,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.1),
          ),
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
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'OWNER DASHBOARD',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'For Property Owners',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fill your vacant beds faster. Showcase your property with high-quality galleries, list clear house rules, and manage tenant inquiries directly from your customized owner dashboard.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  InteractiveHover(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'List your property',
                              style: TextStyle(
                                color: Color(0xFF0EA5E9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
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

  // --- CTA Banner ---
  Widget _buildCtaBanner(
    BuildContext context,
    bool isMobile,
    double padding,
  ) {
    return Container(
      color: const Color(0xFFF0F9FF),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 60 : 100,
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 32 : 64),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Ready to find your\nnext home?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 32 : 48,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.5,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Join thousands of students in Cagayan de Oro who found their perfect boarding house.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            InteractiveHover(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
              ? _buildMobileFooter(context)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildFooterBrandColumn(),
                    ),
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
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text(
                  '\u00a9 ${DateTime.now().year} VacanSee. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    Text(
                      'Designed for CDO Students',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                    ),
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

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterBrandColumn(),
        const SizedBox(height: 48),
        _buildMobileFooterSection('For Tenants', [
          'Search Rooms',
          'Near USTP',
          'Near Xavier',
          'Student Guides',
        ], context),
        const SizedBox(height: 32),
        _buildMobileFooterSection('For Owners', [
          'List Property',
          'Owner Dashboard',
          'Resource Center',
          'Premium Listing',
        ], context),
        const SizedBox(height: 32),
        _buildMobileFooterSection('Company', [
          'About Us',
          'Contact Support',
          'Privacy Policy',
          'Terms of Service',
        ], context),
      ],
    );
  }

  Widget _buildMobileFooterSection(
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
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: links.map((link) {
            return InteractiveHover(
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
            );
          }).toList(),
        ),
      ],
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
            'Real-time boarding house and dorm tracker for university students in Cagayan de Oro City. Find verified spaces and connect with property owners.',
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
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: anim1,
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
              'Get help from our support team to onboard your properties and manage listings.',
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
                          'Community Plan - \u20b10 / month',
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
                  Expanded(
                    child: Text(
                      'Thank you! Your message has been sent successfully.',
                    ),
                  ),
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
              'Have questions, feedback, or need help? Reach out to us directly:',
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
              Icons.visibility_off_outlined,
              'No Third-Party Sharing',
              'Your contact info and emergency details are only shared with the respective owner when booking a room.',
            ),
          ],
        );
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 24,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 24),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: body,
              ),
            ),
            if (actionButtonText != null)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                width: double.infinity,
                child: GestureDetector(
                  onTap: onActionPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    child: Center(
                      child: Text(
                        actionButtonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    path.moveTo(size.width * 0.5, size.height * 0.08);
    path.lineTo(size.width * 0.125, size.height * 0.38);
    path.lineTo(size.width * 0.25, size.height * 0.38);
    path.lineTo(size.width * 0.25, size.height * 0.88);
    path.lineTo(size.width * 0.75, size.height * 0.88);
    path.lineTo(size.width * 0.75, size.height * 0.38);
    path.lineTo(size.width * 0.875, size.height * 0.38);
    path.close();

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
