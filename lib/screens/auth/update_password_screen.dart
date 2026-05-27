import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/glass_card.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/gradient_button.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    if (password != confirm) {
      setState(() => _confirmError = 'Passwords do not match');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updatePassword(password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Welcome back.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: GlassCard(
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
                          Icons.security_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Set New Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your identity has been verified. Please choose a strong new password to secure your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      AuthInputField(
                        controller: _passwordController,
                        label: 'New Password',
                        hintText: 'At least 6 characters',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: _obscurePassword,
                        error: _passwordError,
                        onChanged: (_) => setState(() => _passwordError = null),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 20),

                      AuthInputField(
                        controller: _confirmPasswordController,
                        label: 'Confirm New Password',
                        hintText: 'Repeat your password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: _obscureConfirm,
                        error: _confirmError,
                        onChanged: (_) => setState(() => _confirmError = null),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),

                      if (authProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
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

                      const SizedBox(height: 32),

                      GradientButton(
                        label: 'Update Password',
                        isLoading: authProvider.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
