import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/glass_card.dart';
import '../../widgets/auth/gradient_button.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
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
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Verify your email',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(
                              text: 'We have sent a verification link to\n',
                            ),
                            TextSpan(
                              text: email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '.\nPlease check your inbox to continue.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      GradientButton(
                        label: 'BACK TO LOGIN',
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the email? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification email resent!'),
                                ),
                              );
                            },
                            child: const Text(
                              'Resend Link',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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
          ),
        ),
      ),
    );
  }
}
