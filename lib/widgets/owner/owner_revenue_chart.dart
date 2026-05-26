import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/booking_model.dart';

class OwnerRevenueChart extends StatefulWidget {
  final List<BookingModel> bookings;

  const OwnerRevenueChart({
    super.key,
    required this.bookings,
  });

  @override
  State<OwnerRevenueChart> createState() => _OwnerRevenueChartState();
}

class _OwnerRevenueChartState extends State<OwnerRevenueChart> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    // Get unique years from bookings to populate dropdown
    final years = widget.bookings
        .map((b) => b.requestedAt.year)
        .toSet()
        .toList();
    if (!years.contains(DateTime.now().year)) {
      years.add(DateTime.now().year);
    }
    years.sort((a, b) => b.compareTo(a));

    // Calculate revenue map for the selected year
    final Map<int, double> monthlyRevenue = {};
    for (int i = 1; i <= 12; i++) {
      monthlyRevenue[i] = 0.0;
    }

    for (final booking in widget.bookings) {
      if (booking.requestedAt.year == _selectedYear &&
          (booking.status == BookingStatus.approved ||
              booking.status == BookingStatus.completed)) {
        final month = booking.requestedAt.month;
        monthlyRevenue[month] = (monthlyRevenue[month] ?? 0.0) + booking.monthlyRate;
      }
    }

    final totalRevenue = monthlyRevenue.values.fold(0.0, (sum, item) => sum + item);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenue Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Earned: ₱${totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Dropdown Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      items: years
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(
                                  '$y',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedYear = val;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Custom Painted Chart Area
            Expanded(
              child: monthlyRevenue.values.every((v) => v == 0)
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _BarChartPainter(
                            monthlyRevenue: monthlyRevenue,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: const Color(0xFF5287B2).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'No booking revenue in this period',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Map<int, double> monthlyRevenue;

  _BarChartPainter({required this.monthlyRevenue});

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPadding = 30;
    const double leftPadding = 50;
    const double topPadding = 10;
    const double rightPadding = 10;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    final double maxVal = monthlyRevenue.values.fold(0.0, max);
    final double limitVal = maxVal == 0 ? 1000 : maxVal * 1.15; // Give headroom

    // Paints
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final barPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF5287B2), // Brand Blue
          const Color(0xFF3B82F6), // Accent Blue
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(
        Rect.fromLTWH(0, topPadding, size.width, chartHeight),
      );

    // Text Style for Axis Labels
    const textStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // Draw Y gridlines and labels
    const int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final double val = (limitVal / gridLines) * i;
      final double y = size.height - bottomPadding - (chartHeight / gridLines) * i;

      // Draw grid line (skip the baseline at 0 to avoid overlapping)
      if (i > 0) {
        canvas.drawLine(
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          gridPaint,
        );
      }

      // Draw Y label
      final String label = _formatPeso(val);
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 10, y - textPainter.height / 2),
      );
    }

    // Draw X labels and Bars
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final double barWidth = (chartWidth / 12) * 0.55;
    final double spaceBetween = (chartWidth / 12);

    for (int i = 0; i < 12; i++) {
      final monthIndex = i + 1;
      final double val = monthlyRevenue[monthIndex] ?? 0.0;
      final double barHeight = (val / limitVal) * chartHeight;

      final double centerX = leftPadding + (spaceBetween * i) + (spaceBetween / 2);
      final double xLeft = centerX - barWidth / 2;
      final double yTop = size.height - bottomPadding - barHeight;

      // Draw bar if height > 0
      if (barHeight > 0) {
        final RRect rrect = RRect.fromRectAndCorners(
          Rect.fromLTWH(xLeft, yTop, barWidth, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        canvas.drawRRect(rrect, barPaint);
      }

      // Draw X axis label
      final String label = months[i];
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, size.height - bottomPadding + 8),
      );
    }
  }

  String _formatPeso(double val) {
    if (val >= 1000000) {
      return '₱${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '₱${(val / 1000).toStringAsFixed(0)}K';
    }
    return '₱${val.toStringAsFixed(0)}';
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.monthlyRevenue != monthlyRevenue;
  }
}
