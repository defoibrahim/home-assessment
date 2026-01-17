import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/portfolio_model.dart';
import '../utils/extensions.dart';
import 'chart_badge.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioOverview overview;

  const PortfolioSummaryCard({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              overview.totalValue.formatAsCurrency(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        overview.totalPnl >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${overview.totalPnl >= 0 ? '+' : ''}${overview.totalPnl.formatAsCurrency()} (${overview.totalPnlPercent}%)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

class AssetListTile extends StatelessWidget {
  final PortfolioHolding holding;

  const AssetListTile({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final isPositive = holding.pnl >= 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark
              ? primaryColor.withValues(alpha: 0.2)
              : primaryColor.withValues(alpha: 0.1),
          child: Text(
            holding.symbol.split('/')[0].substring(0, 1),
            style: TextStyle(
                color: isDark ? Colors.white : primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(holding.symbol,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${holding.quantity} Coins'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              holding.currentPrice.formatAsCurrency(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${isPositive ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllocationPieChart extends StatelessWidget {
  final List<PortfolioHolding> holdings;

  const AllocationPieChart({super.key, required this.holdings});

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) return const SizedBox.shrink();

    // Take top 4 holdings, group others
    final sortedHoldings = List.of(holdings)
      ..sort((a, b) => b.allocation.compareTo(a.allocation));

    final topHoldings = sortedHoldings.take(4).toList();
    final otherAllocation =
        sortedHoldings.skip(4).fold(0.0, (sum, item) => sum + item.allocation);

    return AspectRatio(
      aspectRatio: 1.8,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            ...topHoldings.map((h) {
              return PieChartSectionData(
                color: _getColorForSymbol(h.symbol),
                value: h.allocation,
                title: '${h.allocation}%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                badgeWidget:
                    Skeleton.ignore(child: ChartBadge(h.symbol.split('/')[0])),
                badgePositionPercentageOffset: .98,
              );
            }),
            if (otherAllocation > 0)
              PieChartSectionData(
                color: Colors.grey,
                value: otherAllocation,
                title: '${otherAllocation.toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSymbol(String symbol) {
    if (symbol.contains('BTC')) return Colors.orange;
    if (symbol.contains('ETH')) return Colors.blue;
    if (symbol.contains('SOL')) return Colors.purple;
    if (symbol.contains('ADA')) return Colors.blueAccent;
    return Colors.teal;
  }
}
