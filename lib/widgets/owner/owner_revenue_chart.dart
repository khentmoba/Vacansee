import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final years = widget.bookings
        .map((b) => b.requestedAt.year)
        .toSet()
        .toList();
    if (!years.contains(DateTime.now().year)) {
      years.add(DateTime.now().year);
    }
    years.sort((a, b) => b.compareTo(a));

    final Map<int, double> monthlyRevenue = {};
    for (int i = 1; i <= 12; i++) {
      monthlyRevenue[i] = 0.0;
    }

    for (final booking in widget.bookings) {
      if (booking.requestedAt.year == _selectedYear &&
          (booking.status == BookingStatus.approved ||
              booking.status == BookingStatus.completed)) {
        final month = booking.requestedAt.month;
        monthlyRevenue[month] =
            (monthlyRevenue[month] ?? 0.0) + booking.monthlyRate;
      }
    }

    final totalRevenue =
        monthlyRevenue.values.fold(0.0, (sum, item) => sum + item);
    final maxVal = monthlyRevenue.values.fold(0.0, (a, b) => a > b ? a : b);
    final ceiling = maxVal == 0 ? 10000.0 : (maxVal * 1.2);

    final barData = monthlyRevenue.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Analytics',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Earned: ₱${_formatNumber(totalRevenue)}',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Year Selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      items: years
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(
                                  '$y',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedYear = val);
                        }
                      },
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Chart
            Expanded(
              child: totalRevenue == 0
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: ceiling,
                                  minY: 0,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipRoundedRadius: 8,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        final monthIndex = group.x.toInt() - 1;
                                        final months = [
                                          'Jan', 'Feb', 'Mar', 'Apr', 'May',
                                          'Jun',
                                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov',
                                          'Dec'
                                        ];
                                        return BarTooltipItem(
                                          '${months[monthIndex]}\n₱${_formatNumber(rod.toY)}',
                                          TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        );
                                      },
                                    ),
                                    touchCallback: (event, response) {
                                      setState(() {
                                        _hoveredIndex =
                                            response?.spot?.touchedBarGroupIndex;
                                      });
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            _formatCompact(value),
                                            style: GoogleFonts.openSans(
                                              fontSize: 10,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          final months = [
                                            'J', 'F', 'M', 'A', 'M', 'J',
                                            'J', 'A', 'S', 'O', 'N', 'D'
                                          ];
                                          final idx = value.toInt() - 1;
                                          if (idx < 0 || idx >= 12) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              months[idx],
                                              style: GoogleFonts.openSans(
                                                fontSize: 10,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: ceiling / 4,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: AppColors.divider,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: barData
                                      .map((entry) => BarChartGroupData(
                                            x: entry.key,
                                            barRods: [
                                              BarChartRodData(
                                                toY: entry.value,
                                                color: _hoveredIndex != null &&
                                                        _hoveredIndex ==
                                                            entry.key - 1
                                                    ? AppColors.primary
                                                    : AppColors.primary
                                                        .withValues(alpha: 0.7),
                                                width: 16,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                  show: true,
                                                  toY: ceiling,
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.05),
                                                ),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ],
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
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'No booking revenue in this period',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}K';
    }
    return val.toStringAsFixed(0);
  }

  String _formatCompact(double val) {
    if (val >= 1000000) {
      return '₱${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '₱${(val / 1000).toStringAsFixed(0)}K';
    }
    return '₱${val.toStringAsFixed(0)}';
  }
}
