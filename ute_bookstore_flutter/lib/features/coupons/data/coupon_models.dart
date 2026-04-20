class Coupon {
  Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.discountAmount,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.expiryDate,
    required this.usageLimit,
    required this.usedCount,
    required this.customerId,
    required this.customerName,
    required this.status,
  });

  final String id;
  final String code;
  final int? discountPercent;
  final int? discountAmount;
  final int? minOrderValue;
  final int? maxDiscount;
  final DateTime? expiryDate;
  final int? usageLimit;
  final int usedCount;
  final String? customerId;
  final String? customerName;
  final String? status;

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      discountPercent: (json['discountPercent'] as num?)?.toInt(),
      discountAmount: (json['discountAmount'] as num?)?.toInt(),
      minOrderValue: (json['minOrderValue'] as num?)?.toInt(),
      maxDiscount: (json['maxDiscount'] as num?)?.toInt(),
      expiryDate: _parseDate(json['expiryDate']),
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString(),
      status: json['status']?.toString(),
    );
  }

  bool get isPercent => (discountPercent ?? 0) > 0;

  bool get isAmount => (discountAmount ?? 0) > 0;

  String get scopeLabel => (customerId == null || customerId!.isEmpty)
      ? 'Toàn hệ thống'
      : 'Cá nhân';

  String get resolvedStatus {
    final now = DateTime.now();
    final expiry = expiryDate;
    if (expiry != null && expiry.isBefore(now)) {
      return 'EXPIRED';
    }
    final limit = usageLimit;
    if (limit != null && usedCount >= limit) {
      return 'USED_UP';
    }
    return status?.isNotEmpty == true ? status! : 'ACTIVE';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class CouponRequest {
  CouponRequest({
    required this.code,
    this.discountPercent,
    this.discountAmount,
    this.minOrderValue,
    this.maxDiscount,
    required this.expiryDate,
    this.usageLimit,
    this.customerId,
  });

  final String code;
  final int? discountPercent;
  final int? discountAmount;
  final int? minOrderValue;
  final int? maxDiscount;
  final DateTime expiryDate;
  final int? usageLimit;
  final String? customerId;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'minOrderValue': minOrderValue,
      'maxDiscount': maxDiscount,
      'expiryDate': expiryDate.toIso8601String(),
      'usageLimit': usageLimit,
      'customerId': customerId?.isEmpty == true ? null : customerId,
    };
  }
}

class CouponStats {
  CouponStats({
    required this.activeCount,
    required this.expiringSoonCount,
    required this.totalUsedCount,
    required this.topUsedCode,
    required this.topUsedCount,
  });

  final int activeCount;
  final int expiringSoonCount;
  final int totalUsedCount;
  final String? topUsedCode;
  final int topUsedCount;

  factory CouponStats.fromJson(Map<String, dynamic> json) {
    return CouponStats(
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
      expiringSoonCount: (json['expiringSoonCount'] as num?)?.toInt() ?? 0,
      totalUsedCount: (json['totalUsedCount'] as num?)?.toInt() ?? 0,
      topUsedCode: json['topUsedCode']?.toString(),
      topUsedCount: (json['topUsedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

