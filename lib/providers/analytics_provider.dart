import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../services/api_service.dart';
import '../models/analytics_model.dart';
import '../core/failure.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _apiService;

  AnalyticsProvider(this._apiService);

  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;

  AnalyticsOverview? _overview;
  TrendData? _trendData;

  bool _isLoadingOverview = false;
  bool _isLoadingTrends = false;

  String? _error;
  String _selectedTimeframe = '24h';

  AnalyticsOverview? get overview => _overview;
  TrendData? get trendData => _trendData;

  bool get isLoading => _isLoadingOverview || _isLoadingTrends;

  String? get error => _error;
  String get selectedTimeframe => _selectedTimeframe;

  // =======================
  // Initial Load
  // =======================
  Future<void> loadData() async {
    _setLoading(overview: true, trends: true);
    _error = null;

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));

    final results = await Future.wait([
      _apiService.getAnalyticsOverview(),
      _apiService.getMarketTrends(timeframe: _selectedTimeframe),
    ]);

    results[0].fold(
      _handleFailure,
      (data) => _overview = data as AnalyticsOverview,
    );

    results[1].fold(
      _handleFailure,
      (data) => _trendData = data as TrendData,
    );

    _setLoading(overview: false, trends: false);
    _refreshController.refreshCompleted();
  }

  // =======================
  // Timeframe Change
  // =======================
  Future<void> setTimeframe(String timeframe) async {
    if (_selectedTimeframe == timeframe) return;

    _selectedTimeframe = timeframe;
    _isLoadingTrends = true;
    _error = null;
    notifyListeners();

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));
    final result = await _apiService.getMarketTrends(timeframe: timeframe);

    result.fold(
      _handleFailure,
      (data) => _trendData = data,
    );

    _isLoadingTrends = false;
    notifyListeners();
  }

  // =======================
  // Helpers
  // =======================
  void _setLoading({bool? overview, bool? trends}) {
    if (overview != null) _isLoadingOverview = overview;
    if (trends != null) _isLoadingTrends = trends;
    notifyListeners();
  }

  void _handleFailure(Failure failure) {
    _error = failure is NetworkFailure
        ? 'Connection error. Please check your internet.'
        : failure.message;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
