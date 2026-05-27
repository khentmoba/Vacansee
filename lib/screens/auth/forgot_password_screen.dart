import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/glass_card.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/gradient_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email address');
      return;
    }
    setState(() => _emailError = null);

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendPasswordReset(email);

    if (mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _sent ? _buildSuccessView() : _buildFormView(authProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthProvider authProvider) {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "No worries! Enter your account email and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          AuthInputField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            error: _emailError,
            onChanged: (_) => setState(() => _emailError = null),
          ),

          if (authProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 28),

          GradientButton(
            label: 'Send Reset Link',
            isLoading: authProvider.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Back to Login',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Check Your Email!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a password reset link to\n${_emailController.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.6),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the link in the email to set a new password. It may take a minute to arrive.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
          ),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _sent = false;
                _emailController.clear();
              }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Use a Different Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          GradientButton(
            label: 'Back to Login',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
