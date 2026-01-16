import 'package:equatable/equatable.dart';

class AnalyticsOverview extends Equatable {
  final double totalMarketCap;
  final double totalVolume24h;
  final int activeMarkets;
  final MarketMover topGainer;
  final MarketMover topLoser;
  final MarketDominance dominance;
  final DateTime lastUpdated;

  const AnalyticsOverview({
    required this.totalMarketCap,
    required this.totalVolume24h,
    required this.activeMarkets,
    required this.topGainer,
    required this.topLoser,
    required this.dominance,
    required this.lastUpdated,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      totalMarketCap: (json['totalMarketCap'] as num).toDouble(),
      totalVolume24h: (json['totalVolume24h'] as num).toDouble(),
      activeMarkets: json['activeMarkets'] as int,
      topGainer: MarketMover.fromJson(json['topGainer']),
      topLoser: MarketMover.fromJson(json['topLoser']),
      dominance: MarketDominance.fromJson(json['marketDominance']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  List<Object?> get props => [
        totalMarketCap,
        totalVolume24h,
        activeMarkets,
        topGainer,
        topLoser,
        dominance,
        lastUpdated
      ];

  static AnalyticsOverview get dummy => AnalyticsOverview(
        totalMarketCap: 2000000000000,
        totalVolume24h: 100000000,
        activeMarkets: 5000,
        topGainer: const MarketMover(symbol: 'BTC', change: 5.5, price: 50000),
        topLoser: const MarketMover(symbol: 'ETH', change: -3.2, price: 3000),
        dominance: const MarketDominance(btc: 45, eth: 20, others: 35),
        lastUpdated: DateTime.now(),
      );
}

class MarketMover extends Equatable {
  final String symbol;
  final double change;
  final double price;

  const MarketMover({
    required this.symbol,
    required this.change,
    required this.price,
  });

  factory MarketMover.fromJson(Map<String, dynamic> json) {
    return MarketMover(
      symbol: json['symbol'] as String,
      change: (json['change'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [symbol, change, price];
}

class MarketDominance extends Equatable {
  final double btc;
  final double eth;
  final double others;

  const MarketDominance({
    required this.btc,
    required this.eth,
    required this.others,
  });

  factory MarketDominance.fromJson(Map<String, dynamic> json) {
    return MarketDominance(
      btc: (json['btc'] as num).toDouble(),
      eth: (json['eth'] as num).toDouble(),
      others: (json['others'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [btc, eth, others];
}

class TrendData extends Equatable {
  final String timeframe;
  final List<MarketTrend> data;
  final TrendSummary summary;

  const TrendData({
    required this.timeframe,
    required this.data,
    required this.summary,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      timeframe: json['timeframe'] as String,
      data: (json['data'] as List).map((e) => MarketTrend.fromJson(e)).toList(),
      summary: TrendSummary.fromJson(json['summary']),
    );
  }

  @override
  List<Object?> get props => [timeframe, data, summary];

  static TrendData get dummy => TrendData(
        timeframe: '24h',
        data: List.generate(
          20,
          (index) => MarketTrend(
            timestamp: DateTime.now().subtract(Duration(hours: index)),
            marketCap: 2000000000000,
            volume: 100000000,
            priceIndex: 100.0,
          ),
        ),
        summary: const TrendSummary(change: 2.5, volatility: 3.0),
      );
}

class MarketTrend extends Equatable {
  final DateTime timestamp;
  final double marketCap;
  final double volume;
  final double priceIndex;

  const MarketTrend({
    required this.timestamp,
    required this.marketCap,
    required this.volume,
    required this.priceIndex,
  });

  factory MarketTrend.fromJson(Map<String, dynamic> json) {
    return MarketTrend(
      timestamp: DateTime.parse(json['timestamp']),
      marketCap: (json['marketCap'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      priceIndex: (json['priceIndex'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [timestamp, marketCap, volume, priceIndex];
}

class TrendSummary extends Equatable {
  final double change;
  final double volatility;

  const TrendSummary({
    required this.change,
    required this.volatility,
  });

  factory TrendSummary.fromJson(Map<String, dynamic> json) {
    return TrendSummary(
      change: (json['change'] as num).toDouble(),
      volatility: (json['volatility'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [change, volatility];
}
