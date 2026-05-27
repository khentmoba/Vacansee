import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/glass_card.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/gradient_button.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  UserRole? _selectedRole;

  final Map<String, String?> _errors = {
    'firstName': null,
    'lastName': null,
    'contact': null,
    'email': null,
    'password': null,
    'role': null,
    'terms': null,
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _errors['firstName'] =
          _firstNameController.text.isEmpty ? 'Required' : null;
      _errors['lastName'] =
          _lastNameController.text.isEmpty ? 'Required' : null;
      _errors['contact'] =
          _contactController.text.isEmpty ? 'Required' : null;
      _errors['email'] =
          _emailController.text.isEmpty || !_emailController.text.contains('@')
              ? 'Please enter a valid email'
              : null;
      _errors['password'] = _passwordController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
      _errors['role'] =
          _selectedRole == null ? 'Please select a role' : null;
      _errors['terms'] =
          !_agreedToTerms ? 'You must agree to the terms' : null;
    });

    if (_errors.values.every((e) => e == null)) {
      _handleRegister();
    }
  }

  Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: '${_firstNameController.text} ${_lastNameController.text}',
      role: _selectedRole!,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              EmailVerificationScreen(email: _emailController.text.trim()),
        ),
      );
    } else if (!success && mounted) {
      final error = authProvider.errorMessage;
      if (error != null && error.toLowerCase().contains('already in use')) {
        setState(() {
          _errors['email'] = 'This email is already in use.';
        });
      }
    }
  }

  void _clearError(String field) {
    setState(() {
      _errors[field] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      body: AuthBackground(
        child: isMobile
            ? _buildMobileLayout(authProvider)
            : _buildDesktopLayout(authProvider),
      ),
    );
  }

  Widget _buildDesktopLayout(AuthProvider authProvider) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.home_work_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Join VacanSee',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create your account and start\nfinding your perfect space',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _buildForm(authProvider),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AuthProvider authProvider) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.home_work_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'VacanSee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fill in your details to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildForm(authProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (authProvider.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                  onPressed: authProvider.clearError,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        Row(
          children: [
            Expanded(
              child: AuthInputField(
                controller: _firstNameController,
                label: 'First Name',
                hintText: 'Juan',
                prefixIcon: Icons.person_outline,
                error: _errors['firstName'],
                onChanged: (_) => _clearError('firstName'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthInputField(
                controller: _lastNameController,
                label: 'Last Name',
                hintText: 'Dela Cruz',
                prefixIcon: Icons.person_outline,
                error: _errors['lastName'],
                onChanged: (_) => _clearError('lastName'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        AuthInputField(
          controller: _contactController,
          label: 'Contact Number',
          hintText: '+63 912 345 6789',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          error: _errors['contact'],
          onChanged: (_) => _clearError('contact'),
        ),
        const SizedBox(height: 20),

        AuthInputField(
          controller: _emailController,
          label: 'Email',
          hintText: 'you@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          error: _errors['email'],
          onChanged: (_) => _clearError('email'),
        ),
        const SizedBox(height: 20),

        AuthInputField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'At least 6 characters',
          prefixIcon: Icons.lock_outlined,
          obscureText: _obscurePassword,
          error: _errors['password'],
          onChanged: (_) => _clearError('password'),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 24),

        _buildLabel('I am a:'),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _errors['role'] != null
                  ? AppColors.error
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.student;
                      _clearError('role');
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _selectedRole == UserRole.student
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 18,
                          color: _selectedRole == UserRole.student
                              ? Colors.white
                              : const Color(0xFF7A7A7A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tenant',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _selectedRole == UserRole.student
                                ? Colors.white
                                : const Color(0xFF7A7A7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.owner;
                      _clearError('role');
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _selectedRole == UserRole.owner
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 18,
                          color: _selectedRole == UserRole.owner
                              ? Colors.white
                              : const Color(0xFF7A7A7A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _selectedRole == UserRole.owner
                                ? Colors.white
                                : const Color(0xFF7A7A7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errors['role'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Row(
              children: [
                Icon(Icons.info_rounded, size: 13, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  _errors['role']!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _agreedToTerms,
                  onChanged: (v) {
                    setState(() {
                      _agreedToTerms = v ?? false;
                      _clearError('terms');
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: BorderSide(
                    color: _errors['terms'] != null
                        ? AppColors.error
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                  children: [
                    const TextSpan(
                      text: 'By creating an account, you agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_errors['terms'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 34),
            child: Row(
              children: [
                Icon(Icons.info_rounded, size: 13, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  _errors['terms']!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 28),

        GradientButton(
          label: 'SIGN UP',
          isLoading: authProvider.isLoading,
          onPressed: _validateAndSubmit,
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[200])),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[200])),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: authProvider.isLoading
                ? null
                : authProvider.signInWithGoogle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google_logo.png',
                  height: 22,
                  width: 22,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text(
                  'Login here',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
