import 'coupon_api.dart';
import 'coupon_models.dart';

class CouponRepository {
  CouponRepository(this._api);

  final CouponApi _api;

  Future<List<Coupon>> fetchCoupons({
    String? search,
    String? status,
    String? scope,
  }) {
    return _api.fetchCoupons(search: search, status: status, scope: scope);
  }

  Future<Coupon> create(CouponRequest request) => _api.create(request);

  Future<Coupon> update(String id, CouponRequest request) => _api.update(id, request);

  Future<void> delete(String id) => _api.delete(id);

  Future<CouponStats> fetchStats() => _api.fetchStats();
}

