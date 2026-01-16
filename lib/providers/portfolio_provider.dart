import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../services/api_service.dart';
import '../models/portfolio_model.dart';
import '../core/failure.dart';

class PortfolioProvider extends ChangeNotifier {
  final ApiService _apiService;

  PortfolioProvider(this._apiService);

  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;

  PortfolioOverview? _overview;
  List<PortfolioHolding>? _holdings;
  PortfolioPerformance? _performance;

  bool _isLoadingOverview = false;
  bool _isLoadingHoldings = false;
  bool _isLoadingPerformance = false;

  String? _error;
  String _selectedTimeframe = '24h';

  PortfolioOverview? get overview => _overview;
  List<PortfolioHolding>? get holdings => _holdings;
  PortfolioPerformance? get performance => _performance;

  bool get isLoading =>
      _isLoadingOverview || _isLoadingHoldings || _isLoadingPerformance;
  String? get error => _error;
  String get selectedTimeframe => _selectedTimeframe;

  Future<void> loadData() async {
    _setLoading(overview: true, holdings: true, performance: true);
    _error = null;

    // Simulate network delay to show skeleton
    await Future.delayed(const Duration(milliseconds: 500));

    final results = await Future.wait([
      _apiService.getPortfolioOverview(),
      _apiService.getPortfolioHoldings(),
      _apiService.getPortfolioPerformance(timeframe: _selectedTimeframe),
    ]);

    results[0].fold(
      _handleFailure,
      (data) => _overview = data as PortfolioOverview,
    );

    results[1].fold(
      _handleFailure,
      (data) => _holdings = data as List<PortfolioHolding>,
    );

    results[2].fold(
      _handleFailure,
      (data) => _performance = data as PortfolioPerformance,
    );

    _setLoading(overview: false, holdings: false, performance: false);
    _refreshController.refreshCompleted();
  }

  Future<void> setTimeframe(String timeframe) async {
    if (_selectedTimeframe == timeframe) return;

    _selectedTimeframe = timeframe;
    _isLoadingPerformance = true;
    notifyListeners();

    final result =
        await _apiService.getPortfolioPerformance(timeframe: timeframe);

    result.fold(
      _handleFailure,
      (data) => _performance = data,
    );

    _isLoadingPerformance = false;
    notifyListeners();
  }

  void _setLoading({
    bool? overview,
    bool? holdings,
    bool? performance,
  }) {
    if (overview != null) _isLoadingOverview = overview;
    if (holdings != null) _isLoadingHoldings = holdings;
    if (performance != null) _isLoadingPerformance = performance;
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
