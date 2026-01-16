import 'package:equatable/equatable.dart';

class PortfolioOverview extends Equatable {
  final double totalValue;
  final double totalPnl;
  final double totalPnlPercent;
  final int totalHoldings;
  final DateTime lastUpdated;

  const PortfolioOverview({
    required this.totalValue,
    required this.totalPnl,
    required this.totalPnlPercent,
    required this.totalHoldings,
    required this.lastUpdated,
  });

  factory PortfolioOverview.fromJson(Map<String, dynamic> json) {
    return PortfolioOverview(
      totalValue: _parseToDouble(json['totalValue']),
      totalPnl: _parseToDouble(json['totalPnl']),
      totalPnlPercent: _parseToDouble(json['totalPnlPercent']),
      totalHoldings: json['totalHoldings'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  List<Object?> get props => [
        totalValue,
        totalPnl,
        totalPnlPercent,
        totalHoldings,
        lastUpdated,
      ];

  static PortfolioOverview get dummy => PortfolioOverview(
        totalValue: 50000.0,
        totalPnl: 2500.0,
        totalPnlPercent: 5.0,
        totalHoldings: 4,
        lastUpdated: DateTime.now(),
      );
}

class PortfolioHolding extends Equatable {
  final String id;
  final String symbol;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double value;
  final double pnl;
  final double pnlPercent;
  final double allocation;
  final DateTime lastUpdated;

  const PortfolioHolding({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.value,
    required this.pnl,
    required this.pnlPercent,
    required this.allocation,
    required this.lastUpdated,
  });

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      quantity: _parseToDouble(json['quantity']),
      averagePrice: _parseToDouble(json['averagePrice']),
      currentPrice: _parseToDouble(json['currentPrice']),
      value: _parseToDouble(json['value']),
      pnl: _parseToDouble(json['pnl']),
      pnlPercent: _parseToDouble(json['pnlPercent']),
      allocation: _parseToDouble(json['allocation']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  List<Object?> get props => [id, symbol, quantity, value, pnl];

  static List<PortfolioHolding> get dummyList => List.generate(
        5,
        (index) => PortfolioHolding(
          id: '$index',
          symbol: 'BTC/USD',
          quantity: 0.5,
          averagePrice: 40000,
          currentPrice: 45000,
          value: 22500,
          pnl: 2500,
          pnlPercent: 5.5,
          allocation: 20.0,
          lastUpdated: DateTime.now(),
        ),
      );
}

class PortfolioPerformance extends Equatable {
  final String timeframe;
  final List<PerformancePoint> data;
  final PerformanceSummary summary;

  const PortfolioPerformance({
    required this.timeframe,
    required this.data,
    required this.summary,
  });

  factory PortfolioPerformance.fromJson(Map<String, dynamic> json) {
    return PortfolioPerformance(
      timeframe: json['timeframe'] as String,
      data: (json['data'] as List)
          .map((e) => PerformancePoint.fromJson(e))
          .toList(),
      summary: PerformanceSummary.fromJson(json['summary']),
    );
  }

  @override
  List<Object?> get props => [timeframe, data, summary];
}

class PerformancePoint extends Equatable {
  final DateTime timestamp;
  final double value;
  final double pnl;
  final double pnlPercent;

  const PerformancePoint({
    required this.timestamp,
    required this.value,
    required this.pnl,
    required this.pnlPercent,
  });

  factory PerformancePoint.fromJson(Map<String, dynamic> json) {
    return PerformancePoint(
      timestamp: DateTime.parse(json['timestamp']),
      value: _parseToDouble(json['value']),
      pnl: _parseToDouble(json['pnl']),
      pnlPercent: _parseToDouble(json['pnlPercent']),
    );
  }

  @override
  List<Object?> get props => [timestamp, value, pnl, pnlPercent];
}

class PerformanceSummary extends Equatable {
  final double startValue;
  final double endValue;
  final double totalReturn;

  const PerformanceSummary({
    required this.startValue,
    required this.endValue,
    required this.totalReturn,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      startValue: _parseToDouble(json['startValue']),
      endValue: _parseToDouble(json['endValue']),
      totalReturn: _parseToDouble(json['totalReturn']),
    );
  }

  @override
  List<Object?> get props => [startValue, endValue, totalReturn];
}

// Helper to handle String or Number input for doubles
double _parseToDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
