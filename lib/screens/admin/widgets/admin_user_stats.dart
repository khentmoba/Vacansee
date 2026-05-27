import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminUserStats extends StatelessWidget {
  final int total;
  final int tenants;
  final int owners;
  final int admins;

  const AdminUserStats({
    super.key,
    required this.total,
    required this.tenants,
    required this.owners,
    required this.admins,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.2 : 1.4,
          children: [
            _UserStatCard(
              label: 'Total Users',
              value: total,
              icon: Icons.person_outline,
              iconColor: AppColors.primary,
            ),
            _UserStatCard(
              label: 'Tenants',
              value: tenants,
              icon: Icons.person_search_outlined,
              iconColor: AppColors.success,
            ),
            _UserStatCard(
              label: 'Owners',
              value: owners,
              icon: Icons.home_work_outlined,
              iconColor: AppColors.secondary,
            ),
            _UserStatCard(
              label: 'Admins',
              value: admins,
              icon: Icons.admin_panel_settings_outlined,
              iconColor: const Color(0xFF8B5CF6),
            ),
          ],
        );
      },
    );
  }
}

class _UserStatCard extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;

  const _UserStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_UserStatCard> createState() => _UserStatCardState();
}

class _UserStatCardState extends State<_UserStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -4, 0)) : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? widget.iconColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? widget.iconColor.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isHovered ? widget.iconColor.withValues(alpha: 0.15) : widget.iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutExpo,
                  tween: Tween<double>(begin: 0, end: widget.value.toDouble()),
                  builder: (context, val, child) {
                    return Text(
                      val.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

