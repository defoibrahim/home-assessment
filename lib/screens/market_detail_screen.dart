import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/market_data_provider.dart';
import '../widgets/widgets.dart';

class MarketDetailScreen extends StatelessWidget {
  final String symbol;

  const MarketDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MarketDataProvider>(
        builder: (context, provider, child) {
          final data = provider.getBySymbol(symbol);

          if (data == null) {
            return const Center(child: Text('Market data not found'));
          }

          return Column(
            children: [
              AppLinearProgress(isLoading: provider.isLoading),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    MarketDetailAppBar(data: data),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MainPriceDisplay(data: data),
                            const SizedBox(height: 32),
                            MarketStatsGrid(data: data),
                            const SizedBox(height: 32),
                            AboutSection(data: data),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
