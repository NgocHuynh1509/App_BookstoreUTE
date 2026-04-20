import 'package:flutter_test/flutter_test.dart';
import 'package:ute_bookstore_flutter/features/coupons/data/coupon_models.dart';

void main() {
  test('Coupon.fromJson parses fields', () {
    final json = {
      'id': 'C01',
      'code': 'SALE50',
      'discountPercent': 50,
      'discountAmount': null,
      'minOrderValue': 200000,
      'maxDiscount': 80000,
      'expiryDate': '2026-06-30T23:59:00',
      'usageLimit': 100,
      'usedCount': 12,
      'customerId': null,
      'customerName': null,
      'status': 'ACTIVE',
    };

    final coupon = Coupon.fromJson(json);
    expect(coupon.code, 'SALE50');
    expect(coupon.discountPercent, 50);
    expect(coupon.usedCount, 12);
    expect(coupon.expiryDate, isNotNull);
    expect(coupon.resolvedStatus, 'ACTIVE');
  });

  test('CouponRequest.toJson formats payload', () {
    final request = CouponRequest(
      code: 'NEW10',
      discountPercent: 10,
      discountAmount: null,
      minOrderValue: 100000,
      maxDiscount: 50000,
      expiryDate: DateTime(2026, 6, 30, 23, 59),
      usageLimit: 50,
      customerId: '',
    );

    final json = request.toJson();
    expect(json['code'], 'NEW10');
    expect(json['discountPercent'], 10);
    expect(json['discountAmount'], isNull);
    expect(json['customerId'], isNull);
  });
}

