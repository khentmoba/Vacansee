import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/property_model.dart';

class AdminPropertyCard extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final bool? liveVacancy;

  const AdminPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.liveVacancy,
  });

  @override
  State<AdminPropertyCard> createState() => _AdminPropertyCardState();
}

class _AdminPropertyCardState extends State<AdminPropertyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasLiveVacancy = widget.liveVacancy ?? widget.property.hasVacancy;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOutCubic,
            transform: _isHovered ? Matrix4.translationValues(0.0, -6.0, 0.0) : Matrix4.identity(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedScale(
                            scale: _isHovered ? 1.06 : 1.0,
                            duration: AppDurations.slow,
                            curve: Curves.easeOutCubic,
                            child: widget.property.coverImageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.property.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(color: Colors.grey[100]),
                                    errorWidget: (context, url, error) => _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0x66000000)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        // Admin status badge (top-left)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildStatusBadge(widget.property.status),
                        ),
                        // Availability pill (bottom-right)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: hasLiveVacancy ? AppGradients.successGradient : AppGradients.dangerGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [AppShadows.sm],
                            ),
                            child: Text(
                              hasLiveVacancy ? 'VACANT' : 'FULL',
                              style: GoogleFonts.workSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.property.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          widget.property.averageRating > 0
                              ? widget.property.averageRating.toStringAsFixed(1)
                              : 'New',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  widget.property.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.workSans(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Owner: ${widget.property.ownerName ?? "Unknown"}',
                      style: GoogleFonts.workSans(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₱${widget.property.monthlyPrice > 0 ? widget.property.monthlyPrice : widget.property.priceRange.min}',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      TextSpan(
                        text: ' /month',
                        style: GoogleFonts.workSans(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PropertyStatus status) {
    Color color;
    String label;
    switch (status) {
      case PropertyStatus.pending:
        color = AppColors.warning;
        label = 'PENDING';
        break;
      case PropertyStatus.verified:
        color = AppColors.success;
        label = 'VERIFIED';
        break;
      case PropertyStatus.rejected:
        color = AppColors.error;
        label = 'REJECTED';
        break;
      case PropertyStatus.deleted:
        color = AppColors.textMuted;
        label = 'DELETED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppShadows.sm],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.workSans(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}
