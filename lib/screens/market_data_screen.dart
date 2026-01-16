import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/market_data_provider.dart';
import '../models/market_data_model.dart';
import '../widgets/widgets.dart';
import './market_detail_screen.dart';

class MarketDataScreen extends StatelessWidget {
  const MarketDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketDataProvider>();
      if (!provider.hasData && !provider.isLoading) {
        provider.loadMarketData();
      }
    });

    return Consumer<MarketDataProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading;
        final showSkeleton = isLoading;
        final dataToShow =
            showSkeleton ? MarketData.dummyList : provider.marketData;

        return Column(
          children: [
            AppLinearProgress(isLoading: isLoading),
            Expanded(
              child: SmartRefresher(
                controller: provider.refreshController,
                physics: showSkeleton
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                enablePullDown: true,
                header: const WaterDropMaterialHeader(
                  backgroundColor: Color(0xFF6C5CE7),
                  color: Colors.black,
                ),
                onRefresh: () async {
                  await provider.loadMarketData();
                  provider.refreshController.refreshCompleted();
                },
                child: CustomScrollView(
                  physics: null,
                  slivers: [
                    // Persistent Search and Filter Header
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _headerDelegate(
                        child: MarketFilterBar(provider: provider),
                      ),
                    ),

                    // Error state (only when no data)
                    if (provider.hasError && !provider.hasData)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MarketErrorView(
                          error: provider.error ?? 'Something went wrong',
                          onRetry: provider.loadMarketData,
                        ),
                      )
                    // Empty state
                    else if (!isLoading && !provider.hasData)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MarketEmptyView(
                          isFiltering: provider.searchQuery.isNotEmpty,
                          onClear: () => provider.setSearchQuery(''),
                        ),
                      )
                    // Data state with skeleton
                    else
                      SliverSkeletonizer(
                        enabled: showSkeleton,
                        child: SliverPrototypeExtentList(
                          prototypeItem: MarketDataListItem(
                            data: MarketData.dummy,
                            onTap: null,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final data = dataToShow[index];
                              return MarketDataListItem(
                                data: data,
                                onTap: () => _onItemTap(context, data),
                              );
                            },
                            childCount: dataToShow.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onItemTap(BuildContext context, MarketData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketDetailScreen(symbol: data.symbol),
      ),
    );
  }

  /// Create a SliverPersistentHeaderDelegate
  SliverPersistentHeaderDelegate _headerDelegate({required Widget child}) {
    return StickyHeaderDelegate(
      minHeight: 120,
      maxHeight: 120,
      child: child,
    );
  }
}
