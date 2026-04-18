import '../../../core/api_client.dart';
import 'dashboard_models.dart';

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Future<DashboardSummary> fetchSummary() async {
    final response = await _client.dio.get('/admin/dashboard/summary');
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }
}

