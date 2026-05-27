import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/glass_card.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/gradient_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final Map<String, String?> _errors = {'email': null, 'password': null};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _errors['email'] =
          _emailController.text.isEmpty || !_emailController.text.contains('@')
              ? 'Please enter a valid email'
              : null;
      _errors['password'] = _passwordController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
    });

    if (_errors.values.every((e) => e == null)) {
      _handleLogin();
    }
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                    'VacanSee',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find your perfect boarding house\nin Cagayan de Oro',
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
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 32),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Login to continue finding your space',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
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
          hintText: 'Enter your password',
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
        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        GradientButton(
          label: 'LOGIN',
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
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text(
                  'Sign up here',
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
        const SizedBox(height: 20),

        Center(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF999999),
              ),
              children: [
                const TextSpan(text: 'By logging in, you agree to our '),
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
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
