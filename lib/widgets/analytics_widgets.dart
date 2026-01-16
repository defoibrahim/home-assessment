import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/analytics_model.dart';
import 'chart_badge.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = const Color(0xFF6C5CE7),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrendLineChart extends StatelessWidget {
  final TrendData trendData;
  final bool isPositive;
  final Color? overrideColor;

  const TrendLineChart({
    super.key,
    required this.trendData,
    required this.isPositive,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = overrideColor ?? (isPositive ? Colors.green : Colors.red);

    // Convert data to FlSpot
    final spots = trendData.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.priceIndex);
    }).toList();

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: color,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Theme.of(context).cardColor,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final index = touchedSpot.x.toInt();
                    if (index >= 0 && index < trendData.data.length) {
                      final item = trendData.data[index];
                      // Show date and price
                      return LineTooltipItem(
                        item.priceIndex.toStringAsFixed(2),
                        TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DominancePieChart extends StatelessWidget {
  final MarketDominance dominance;

  const DominancePieChart({super.key, required this.dominance});

  @override
  Widget build(BuildContext context) {
    // Find the largest dominance to highlight it
    final maxDominance = [dominance.btc, dominance.eth, dominance.others]
        .reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.8,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            _buildSection(
              value: dominance.btc,
              title: 'BTC',
              color: Colors.orange,
              isLarge: dominance.btc == maxDominance,
            ),
            _buildSection(
              value: dominance.eth,
              title: 'ETH',
              color: Colors.blue,
              isLarge: dominance.eth == maxDominance,
            ),
            _buildSection(
              value: dominance.others,
              title: 'Others',
              color: Colors.grey,
              isLarge: dominance.others == maxDominance,
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildSection({
    required double value,
    required String title,
    required Color color,
    bool isLarge = false,
  }) {
    final radius = isLarge ? 60.0 : 50.0;
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(1)}%',
      radius: radius,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: Skeleton.ignore(child: ChartBadge(title)),
      badgePositionPercentageOffset: .98,
    );
  }
}
