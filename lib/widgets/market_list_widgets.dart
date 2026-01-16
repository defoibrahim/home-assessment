import 'package:flutter/material.dart';
import '../models/market_data_model.dart';
import '../utils/extensions.dart';
import 'symbol_avatar.dart';
import '../providers/market_data_provider.dart';

/// Delegate for sticky header
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

/// Search and Filter Bar
class MarketFilterBar extends StatefulWidget {
  final MarketDataProvider provider;

  const MarketFilterBar({super.key, required this.provider});

  @override
  State<MarketFilterBar> createState() => _MarketFilterBarState();
}

class _MarketFilterBarState extends State<MarketFilterBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current search query from provider
    _controller = TextEditingController(text: widget.provider.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.provider.setSearchQuery('');
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done, // Close keyboard on Done
            decoration: InputDecoration(
              hintText: 'Search markets...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2D2D2D), // Consistent with cards
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2D2D2D),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              widget.provider.setSearchQuery(value);
              // Rebuild to show/hide clear icon
              setState(() {});
            },
          ),
        ),

        // Sort Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              MarketSortChip(
                label: 'Price',
                isSelected: widget.provider.sortOption == SortOption.price,
                sortOrder: widget.provider.sortOrder,
                onTap: () => widget.provider.setSortOption(SortOption.price),
              ),
              const SizedBox(width: 8),
              MarketSortChip(
                label: 'Change',
                isSelected: widget.provider.sortOption == SortOption.change,
                sortOrder: widget.provider.sortOrder,
                onTap: () => widget.provider.setSortOption(SortOption.change),
              ),
              const SizedBox(width: 8),
              MarketSortChip(
                label: 'Symbol',
                isSelected: widget.provider.sortOption == SortOption.symbol,
                sortOrder: widget.provider.sortOrder,
                onTap: () => widget.provider.setSortOption(SortOption.symbol),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single Sort Chip
class MarketSortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final SortOrder sortOrder;
  final VoidCallback onTap;

  const MarketSortChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.sortOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      onPressed: onTap,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              sortOrder == SortOrder.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 14,
              color: Colors.white,
            ),
          ],
        ],
      ),
      backgroundColor: isSelected ? theme.primaryColor : theme.cardColor,
      side: BorderSide(
        color: isSelected
            ? Colors.grey.withValues(alpha: 0.4)
            : theme.dividerColor.withValues(alpha: 0.1),
        width: isSelected ? 1.5 : 1.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Error state view
class MarketErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const MarketErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state view
class MarketEmptyView extends StatelessWidget {
  final bool isFiltering;
  final VoidCallback? onClear;

  const MarketEmptyView({super.key, this.isFiltering = false, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltering ? 'No matches found' : 'No market data available',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (isFiltering && onClear != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onClear,
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
}

class MarketDataListItem extends StatelessWidget {
  final MarketData data;
  final VoidCallback? onTap;

  const MarketDataListItem({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = data.isPositiveChange;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Symbol Avatar
              SymbolAvatar(symbol: data.baseSymbol),
              const SizedBox(width: 16),

              // Symbol and Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.price.formatAsCurrency(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Change Badge
              _ChangeBadge(
                changePercent: data.changePercent24h,
                isPositive: isPositive,
                color: changeColor,
                icon: changeIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge showing percentage change with color
class _ChangeBadge extends StatelessWidget {
  final double changePercent;
  final bool isPositive;
  final Color color;
  final IconData icon;

  const _ChangeBadge({
    required this.changePercent,
    required this.isPositive,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.25)
            : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            changePercent.formatAsPercentage(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
