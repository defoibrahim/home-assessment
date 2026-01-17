import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../providers/market_data_provider.dart';
import '../models/market_data_model.dart';
import '../widgets/widgets.dart';

class MarketDetailScreen extends StatelessWidget {
  final String symbol;

  const MarketDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketDataProvider>(
      builder: (context, provider, child) {
        final realData = provider.getBySymbol(symbol);
        final showSkeleton = provider.isLoading;

        // Use dummy data with correct symbol during skeleton, real data otherwise
        final data = showSkeleton ? MarketData.dummyFor(symbol) : realData;

        // Show error state only when no data and not loading
        if (data == null && !showSkeleton) {
          return Scaffold(
            appBar: AppBar(title: Text(symbol)),
            body: const Center(child: Text('Market data not found')),
          );
        }

        // Fallback to dummy if somehow null during skeleton
        final displayData = data ?? MarketData.dummyFor(symbol);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SymbolAvatar(symbol: displayData.symbol, size: 24),
                const SizedBox(width: 8),
                Text(displayData.symbol),
              ],
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              AppLinearProgress(isLoading: showSkeleton),
              Expanded(
                child: SmartRefresher(
                  controller: provider.detailRefreshController,
                  physics: showSkeleton
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  onRefresh: provider.loadDetailData,
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
                          MainPriceDisplay(data: displayData),
                          const SizedBox(height: 32),
                          MarketStatsGrid(data: displayData),
                          const SizedBox(height: 32),
                          AboutSection(data: displayData),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
