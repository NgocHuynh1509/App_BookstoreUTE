import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import 'dashboard_models.dart';

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Future<DashboardSummary> fetchSummary() async {
     await _requireToken();
    try {
      final response = await _client.dio.get('/api/admin/dashboard/overview');
      return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardRevenueResponse> fetchRevenue(String range) async {
    await _requireToken();
    try {
      final response = await _client.dio.get(
        '/api/admin/dashboard/revenue-chart',
        queryParameters: {'range': range},
      );
      return DashboardRevenueResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardBooksResponse> fetchBooks(String range) async {
    await _requireToken();
    try {
      final response = await _client.dio.get(
        '/admin/dashboard/books',
        queryParameters: {'range': range},
      );
      return DashboardBooksResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardOrdersResponse> fetchOrders(String range) async {
    await _requireToken();
    try {
      final response = await _client.dio.get(
        '/admin/dashboard/orders',
        queryParameters: {'range': range},
      );
      return DashboardOrdersResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardChartsResponse> fetchCharts(String range) async {
    await _requireToken();
    try {
      final response = await _client.dio.get(
        '/admin/dashboard/charts',
        queryParameters: {'range': range},
      );
      return DashboardChartsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardRevenuePredictionResponse> fetchRevenuePrediction() async {
    await _requireToken();
    try {
      final response = await _client.dio.get('/api/admin/dashboard/prediction');
      return DashboardRevenuePredictionResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardTopBooksResponse> fetchTopBooks(String range, {int limit = 5}) async {
    await _requireToken();
    try {
      final response = await _client.dio.get(
        '/api/admin/dashboard/top-books',
        queryParameters: {'range': range, 'limit': limit},
      );
      return DashboardTopBooksResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<DashboardRecentActivitiesResponse> fetchRecentActivities({int limit = 8}) async {
    await _requireToken();
    try {
      final response = await _client.dio.get(
        '/api/admin/dashboard/recent-activities',
        queryParameters: {'limit': limit},
      );
      return DashboardRecentActivitiesResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    }
  }

  Future<void> _requireToken() async {
    final token = await _client.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }
  }

  String _friendlyDioMessage(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    if (status == 400) {
      return 'Yêu cầu không hợp lệ. Vui lòng kiểm tra lại thông tin gửi lên.';
    }
    if (status == 401 || status == 403) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    return error.message ?? 'Không thể tải dữ liệu. Vui lòng thử lại.';
  }
}
