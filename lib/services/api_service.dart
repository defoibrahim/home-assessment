import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/market_data_model.dart';
import '../models/analytics_model.dart';
import '../models/portfolio_model.dart';
import '../core/failure.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  /// Fetch market data from API and return mapped models or a failure
  Future<Either<Failure, List<MarketData>>> getMarketData() async {
    try {
      final response = await _dio.get(AppConstants.marketDataEndpoint);

      // Dio throws for non-2xx status codes, so we can directly parse the data
      final data = (response.data['data'] as List)
          .map((e) => MarketData.fromJson(e))
          .toList();
      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetch analytics overview
  Future<Either<Failure, AnalyticsOverview>> getAnalyticsOverview() async {
    try {
      final response =
          await _dio.get('${AppConstants.analyticsEndpoint}/overview');
      final data = AnalyticsOverview.fromJson(response.data['data']);
      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetch market trends
  Future<Either<Failure, TrendData>> getMarketTrends(
      {String timeframe = '24h'}) async {
    try {
      final response = await _dio.get(
        '${AppConstants.analyticsEndpoint}/trends',
        queryParameters: {'timeframe': timeframe},
      );
      final data = TrendData.fromJson(response.data['data']);
      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetch portfolio overview
  Future<Either<Failure, PortfolioOverview>> getPortfolioOverview() async {
    try {
      final response = await _dio.get(AppConstants.portfolioEndpoint);
      final data = PortfolioOverview.fromJson(response.data['data']);
      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetch portfolio holdings
  Future<Either<Failure, List<PortfolioHolding>>> getPortfolioHoldings() async {
    try {
      final response =
          await _dio.get('${AppConstants.portfolioEndpoint}/holdings');
      final data = (response.data['data'] as List)
          .map((e) => PortfolioHolding.fromJson(e))
          .toList();
      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetch portfolio performance
  Future<Either<Failure, PortfolioPerformance>> getPortfolioPerformance(
      {String timeframe = '24h'}) async {
    try {
      final response = await _dio.get(
        '${AppConstants.portfolioEndpoint}/performance',
        queryParameters: {'timeframe': timeframe},
      );
      final data = PortfolioPerformance.fromJson(response.data['data']);
      return Right(data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
            'Connection timeout. Please check your internet.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection.');
      case DioExceptionType.badResponse:
        return ServerFailure('Server error: ${e.response?.statusCode}');
      default:
        return UnexpectedFailure('Something went wrong: ${e.message}');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
