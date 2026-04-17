import '../../../core/api_client.dart';
import 'customer_model.dart';

class CustomerApi {
  CustomerApi(this._client);

  final ApiClient _client;

  Future<List<CustomerModel>> fetchCustomers({
    String? keyword,
    bool? enabled,
  }) async {
    final response = await _client.dio.get(
      '/admin/customers',
      queryParameters: {
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
        if (enabled != null) 'enabled': enabled,
      },
    );

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map<String, dynamic> && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<CustomerModel> fetchCustomerDetail(String customerId) async {
    final response = await _client.dio.get('/admin/customers/$customerId');
    return CustomerModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> updateCustomerStatus({
    required String customerId,
    required bool enabled,
  }) async {
    await _client.dio.put(
      '/admin/customers/$customerId/status',
      data: {'enabled': enabled},
    );
  }
}