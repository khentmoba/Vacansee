import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFF0F9FF),
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _buildOrb(280, AppColors.primary.withValues(alpha: 0.10)),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _buildOrb(220, AppColors.secondary.withValues(alpha: 0.10)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: -60,
            child: _buildOrb(160, AppColors.primary.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.6,
            child: _buildOrb(100, AppColors.secondary.withValues(alpha: 0.08)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
