import '../../../core/api_client.dart';
import 'coupon_models.dart';

class CouponApi {
  CouponApi(this._client);

  final ApiClient _client;

  Future<List<Coupon>> fetchCoupons({
    String? search,
    String? status,
    String? scope,
  }) async {
    final response = await _client.dio.get(
      '/admin/coupons/all',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (scope != null && scope.isNotEmpty) 'scope': scope,
      },
    );
    final data = response.data as List<dynamic>;
    return data.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Coupon> fetchCoupon(String id) async {
    final response = await _client.dio.get('/admin/coupons/$id');
    return Coupon.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Coupon> create(CouponRequest request) async {
    final response = await _client.dio.post(
      '/admin/coupons/create',
      data: request.toJson(),
    );
    return Coupon.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Coupon> update(String id, CouponRequest request) async {
    final response = await _client.dio.put(
      '/admin/coupons/update/$id',
      data: request.toJson(),
    );
    return Coupon.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/admin/coupons/delete/$id');
  }

  Future<CouponStats> fetchStats() async {
    final response = await _client.dio.get('/admin/coupons/stats');
    return CouponStats.fromJson(response.data as Map<String, dynamic>);
  }
}

