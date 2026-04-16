import '../../../core/api_client.dart';
import 'dashboard_models.dart';

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Future<DashboardSummary> fetchSummary() async {
    final response = await _client.dio.get('/admin/dashboard/summary');
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DashboardRevenueResponse> fetchRevenue(String range) async {
    final response = await _client.dio.get(
      '/admin/dashboard/revenue',
      queryParameters: {'range': range},
    );
    return DashboardRevenueResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DashboardBooksResponse> fetchBooks(String range) async {
    final response = await _client.dio.get(
      '/admin/dashboard/books',
      queryParameters: {'range': range},
    );
    return DashboardBooksResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DashboardOrdersResponse> fetchOrders(String range) async {
    final response = await _client.dio.get(
      '/admin/dashboard/orders',
      queryParameters: {'range': range},
    );
    return DashboardOrdersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DashboardChartsResponse> fetchCharts(String range) async {
    final response = await _client.dio.get(
      '/admin/dashboard/charts',
      queryParameters: {'range': range},
    );
    return DashboardChartsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

