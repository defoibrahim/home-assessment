import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/portfolio_model.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/portfolio_widgets.dart';
import '../widgets/app_progress.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PortfolioProvider>();
      if (provider.overview == null && !provider.isLoading) {
        provider.loadData();
      }
    });

    return Consumer<PortfolioProvider>(
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

        // Use dummy data if showing skeleton, otherwise real data
        final overview =
            showSkeleton ? PortfolioOverview.dummy : provider.overview;
        final holdings =
            showSkeleton ? PortfolioHolding.dummyList : provider.holdings;

        // Safety check: if somehow we are not showing skeleton but overview is null
        // (This shouldn't happen with above logic unless we want to show empty state)
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
                        // Total Balance Card
                        PortfolioSummaryCard(overview: overview),
                        const SizedBox(height: 24),

                        // Asset Allocation
                        if (holdings != null && holdings.isNotEmpty) ...[
                          const Text(
                            'Asset Allocation',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          AllocationPieChart(holdings: holdings),
                          const SizedBox(height: 24),
                        ],

                        // Holdings List
                        const Text(
                          'Your Assets',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (holdings != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: holdings.length,
                            itemBuilder: (context, index) {
                              return AssetListTile(holding: holdings[index]);
                            },
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
