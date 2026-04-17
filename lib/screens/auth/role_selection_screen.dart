import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

/// Mandatory onboarding screen shown to new users after authentication.
///
/// Blocks access to the rest of the app until the user selects a [UserRole],
/// confirms their display name, and provides a phone number.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  UserRole? _selectedRole;

  // ── lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Pre-fill display name from the Google/Auth profile if available
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  void _selectRole(UserRole role) {
    setState(() => _selectedRole = role);
  }

  Future<void> _submit() async {
    if (_selectedRole == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.completeOnboarding(
      role: _selectedRole!,
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Something went wrong.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Decorative blobs ─────────────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: _Blob(size: 280, color: colorScheme.primary, opacity: 0.06),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _Blob(size: 220, color: colorScheme.primary, opacity: 0.04),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 560,
                        minHeight: size.height * 0.6,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(colorScheme),
                            const SizedBox(height: 36),
                            _buildRoleCards(colorScheme),
                            if (_selectedRole == UserRole.owner) ...[
                              const SizedBox(height: 12),
                              _OwnerVerificationNotice(),
                            ],
                            const SizedBox(height: 32),
                            _buildProfileFields(colorScheme),
                            const SizedBox(height: 32),
                            if (authProvider.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  authProvider.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            _buildSubmitButton(authProvider, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── sub-builders ─────────────────────────────────────────────────────────

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_work_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to VacanSee',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D1B16),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tell us how you\'ll be using the app so we can tailor your experience.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildRoleCards(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            id: 'role-student',
            title: 'I\'m a Student',
            subtitle: 'Find a place to stay',
            icon: Icons.school_rounded,
            isSelected: _selectedRole == UserRole.student,
            onTap: () => _selectRole(UserRole.student),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RoleCard(
            id: 'role-owner',
            title: 'I\'m an Owner',
            subtitle: 'List my property',
            icon: Icons.business_rounded,
            isSelected: _selectedRole == UserRole.owner,
            onTap: () => _selectRole(UserRole.owner),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1B16),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('onboarding-name-field'),
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: Validators.displayName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('onboarding-phone-field'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            hintText: '09XXXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: Validators.phoneNumber,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    AuthProvider authProvider,
    ColorScheme colorScheme,
  ) {
    final isEnabled = _selectedRole != null && !authProvider.isLoading;

    return AnimatedScale(
      scale: isEnabled ? 1.0 : 0.97,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          key: const Key('onboarding-submit-btn'),
          onPressed: isEnabled ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
            elevation: isEnabled ? 3 : 0,
            shadowColor: colorScheme.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Decorative helper ────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Blob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Owner verification notice ────────────────────────────────────────────────

class _OwnerVerificationNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber[800]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Owners require admin verification before listing properties.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.amber[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Role Card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 20 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? colorScheme.primary : const Color(0xFF1D1B16),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.7)
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
