import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../providers/analytics_provider.dart';
import '../models/analytics_model.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/app_progress.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load data on first build if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      // Check if data is missing and not currently loading to avoid multiple fetches
      if (provider.overview == null && !provider.isLoading) {
        provider.loadData();
      }
    });

    return Consumer<AnalyticsProvider>(
      builder: (context, provider, _) {
        if (provider.error != null && provider.overview == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show skeleton if we are loading OR if we have no data yet (and no error)
        final showSkeleton = provider.isLoading || provider.overview == null;

        final overview =
            showSkeleton ? AnalyticsOverview.dummy : provider.overview;
        final trends = showSkeleton ? TrendData.dummy : provider.trendData;

        // If we have no data and not loading/error, just return empty
        if (overview == null) return const SizedBox.shrink();

        return Column(
          children: [
            AppLinearProgress(isLoading: provider.isLoading),
            Expanded(
              child: SmartRefresher(
                controller: provider.refreshController,
                physics: showSkeleton
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                onRefresh: provider.loadData,
                header: const WaterDropMaterialHeader(
                  backgroundColor: Color(0xFF6C5CE7),
                  color: Colors.black,
                ),
                child: Skeletonizer(
                  enabled: showSkeleton,
                  child: SingleChildScrollView(
                    physics: null,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Stats
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            StatCard(
                              label: 'Market Cap',
                              value: overview.totalMarketCap.formatAsCurrency(),
                              icon: Icons.pie_chart,
                            ),
                            StatCard(
                              label: '24h Volume',
                              value: overview.totalVolume24h.formatAsCurrency(),
                              icon: Icons.bar_chart,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Market Dominance
                        const Text(
                          'Market Dominance',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DominancePieChart(dominance: overview.dominance),

                        const SizedBox(height: 24),

                        // Market Trends
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Market Trends',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            // Timeframe Toggle
                            DropdownButton<String>(
                              value: provider.selectedTimeframe,
                              items: AppConstants.timeframes.map((e) {
                                return DropdownMenuItem(
                                    value: e, child: Text(e));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) provider.setTimeframe(val);
                                // Hover: (String?) -> void
                              },
                              underline: Container(), // Remove underline
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (trends != null) ...[
                          Text(
                            'Volatility: ${trends.summary.volatility.toStringAsFixed(2)}%',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          TrendLineChart(
                            trendData: trends,
                            isPositive: trends.summary.change >= 0,
                            overrideColor: showSkeleton ? Colors.grey : null,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Top Movers
                        const Text(
                          'Top Movers (24h)',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _MoverTile(
                          title: 'Top Gainer',
                          mover: overview.topGainer,
                          isGainer: true,
                        ),
                        const SizedBox(height: 8),
                        _MoverTile(
                          title: 'Top Loser',
                          mover: overview.topLoser,
                          isGainer: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MoverTile extends StatelessWidget {
  final String title;
  final MarketMover mover;
  final bool isGainer;

  const _MoverTile({
    required this.title,
    required this.mover,
    required this.isGainer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isGainer ? Colors.green : Colors.red;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          child: Icon(
            isGainer ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(title),
        subtitle: Text(mover.symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              mover.price.formatAsCurrency(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${isGainer ? '+' : ''}${mover.change}%',
              style: TextStyle(
                color: isGainer ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
