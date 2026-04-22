import 'product_api.dart';
import 'product_models.dart';

class ProductRepository {
  ProductRepository(this._api);

  final ProductApi _api;

  Future<ProductPage> fetchProducts({
    required int page,
    required int size,
    String? search,
    String? categoryId,
  }) async {
    final data = await _api.fetchProducts(
      page: page,
      size: size,
      search: search,
      categoryId: categoryId,
    );

    final content = (data['content'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductPage(
      items: content,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? 0,
    );
  }

  Future<Product> create(ProductRequest request) => _api.create(request);

  Future<Product> update(String bookId, ProductRequest request) =>
      _api.update(bookId, request);

  Future<void> delete(String bookId) => _api.delete(bookId);

  Future<void> syncSearchAndMl() => _api.syncSearchAndMl();

}

class ProductPage {
  final List<Product> items;
  final int totalPages;
  final int totalElements;

  ProductPage({
    required this.items,
    required this.totalPages,
    required this.totalElements,
  });
}

