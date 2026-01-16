import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../models/market_data_model.dart';

enum SortOption { price, change, symbol }

enum SortOrder { ascending, descending }

/// Provider for managing market data state
/// Handles loading, error, and data states for the market data list
/// Supports real-time updates via WebSocket
class MarketDataProvider with ChangeNotifier {
  /// Services injected via constructor (enables testing)
  final ApiService _apiService;
  final WebSocketService _wsService;
  StreamSubscription? _wsSubscription;

  /// RefreshController for SmartRefresher
  final RefreshController refreshController = RefreshController();

  /// Debounce timer for batching notifyListeners calls
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 100);

  /// Constructor with required dependency injection
  MarketDataProvider({
    required ApiService apiService,
    required WebSocketService wsService,
  })  : _apiService = apiService,
        _wsService = wsService;

  List<MarketData> _marketData = [];
  Map<String, int> _marketDataIndexMap = {};
  bool _isLoading = false;
  String? _error;
  bool _isRealTimeEnabled = false;

  // Search and Sort State
  String _searchQuery = '';
  SortOption _sortOption = SortOption.price;
  SortOrder _sortOrder = SortOrder.descending;

  // Getters
  List<MarketData> get marketData => _filterAndSortData();
  SortOption get sortOption => _sortOption;
  SortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _marketData.isNotEmpty;
  bool get hasError => _error != null;
  bool get isRealTimeEnabled => _isRealTimeEnabled;

  /// Debounced notify - batches rapid updates into single UI rebuild
  void _debouncedNotify() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      notifyListeners();
    });
  }

  /// Immediate notify - for critical state changes (loading, errors)
  void _immediateNotify() {
    _debounceTimer?.cancel();
    notifyListeners();
  }

  /// Load market data from API
  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    _immediateNotify();

    // delay for 500ms to simulate loading
    await Future.delayed(const Duration(milliseconds: 500));

    final result = await _apiService.getMarketData();

    result.fold(
      (failure) => _error = failure.message,
      (data) {
        _marketData = data;
        _initializeIndexMap();
      },
    );

    _isLoading = false;
    _immediateNotify();
  }

  /// Enable real-time updates via WebSocket
  void enableRealTimeUpdates() {
    if (_isRealTimeEnabled) return;

    _wsService.connect();
    _wsSubscription = _wsService.stream.listen(_handleWebSocketMessage);
    _isRealTimeEnabled = true;
    _immediateNotify();
  }

  /// Disable real-time updates
  void disableRealTimeUpdates() {
    _wsSubscription?.cancel();
    _wsService.disconnect();
    _isRealTimeEnabled = false;
    _immediateNotify();
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (message['type'] != 'market_update' || message['data'] == null) return;

    final updateData = message['data'] as Map<String, dynamic>;
    final symbol = updateData['symbol'] as String?;
    if (symbol == null) return;

    final index = _marketDataIndexMap[symbol];
    if (index == null) return; // symbol not found

    // Use the specialized factory for partial JSON updates
    final updatedData =
        MarketData.updateFromJson(_marketData[index], updateData);

    // Immutable list update (Best Practice)
    final newList = List<MarketData>.from(_marketData);
    newList[index] = updatedData;
    _marketData = newList;

    // Use debounced notify for rapid WebSocket updates
    _debouncedNotify();
  }

  /// Initialize symbol-to-index map for O(1) lookup during updates
  void _initializeIndexMap() {
    _marketDataIndexMap = {
      for (int i = 0; i < _marketData.length; i++) _marketData[i].symbol: i
    };
  }

  /// Clear error state
  void clearError() {
    _error = null;
    _immediateNotify();
  }

  /// Get a specific market data by symbol
  /// Process data with current search and sort settings
  List<MarketData> _filterAndSortData() {
    List<MarketData> filteredList = List.from(_marketData);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((item) =>
              item.symbol.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort
    filteredList.sort((a, b) {
      int comparison;
      switch (_sortOption) {
        case SortOption.price:
          comparison = a.price.compareTo(b.price);
          break;
        case SortOption.change:
          comparison = a.changePercent24h.compareTo(b.changePercent24h);
          break;
        case SortOption.symbol:
          comparison = a.symbol.compareTo(b.symbol);
          break;
      }
      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filteredList;
  }

  /// Update search query
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// Update sort option
  void setSortOption(SortOption option) {
    if (_sortOption == option) {
      // Toggle order if same option selected
      _sortOrder = _sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending;
    } else {
      _sortOption = option;
      _sortOrder = SortOrder.descending; // Default to descending for new option
    }
    notifyListeners();
  }

  MarketData? getBySymbol(String symbol) {
    final index = _marketDataIndexMap[symbol];
    if (index != null && index < _marketData.length) {
      return _marketData[index];
    }
    return null;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _wsSubscription?.cancel();
    _wsService.disconnect();
    refreshController.dispose();
    super.dispose();
  }
}
