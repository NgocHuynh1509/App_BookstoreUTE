import '../../../core/api_client.dart';
import 'order_models.dart';
import 'order_detail_model.dart';

class OrderApi {
  OrderApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchOrders({
    required int page,
    required int size,
    String? status,
  }) async {
    final response = await _client.dio.get(
      '/admin/orders',
      queryParameters: {
        'page': page,
        'size': size,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<OrderItem> updateStatus(String orderId, String status) async {
    final response = await _client.dio.put(
      '/admin/orders/$orderId/status',
      data: {'status': status},
    );
    return OrderItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderDetailModel> fetchOrderDetail(String orderId) async {
    final response = await _client.dio.get('/admin/orders/$orderId');
    return OrderDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> handleReturnRequest(String orderId, String status, String reply) async {
    await _client.dio.post('/admin/orders/$orderId/handle-return', data: {
      'status': status,
      'reply': reply,
    });
  }
}

