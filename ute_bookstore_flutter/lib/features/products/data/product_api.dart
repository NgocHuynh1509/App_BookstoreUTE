import '../../../core/api_client.dart';
import 'product_models.dart';

class ProductApi {
  ProductApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    required int size,
    String? search,
    String? categoryId,
  }) async {
    final response = await _client.dio.get(
      '/admin/products',
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Product> create(ProductRequest request) async {
    final response = await _client.dio.post(
      '/admin/products',
      data: request.toJson(),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> update(String bookId, ProductRequest request) async {
    final response = await _client.dio.put(
      '/admin/products/$bookId',
      data: request.toJson(),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String bookId) async {
    await _client.dio.delete('/admin/products/$bookId');
  }

  Future<void> syncSearchAndMl() async {
    await _client.dio.post('/admin/products/sync-search');
  }
}

