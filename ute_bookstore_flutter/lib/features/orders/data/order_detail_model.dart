class OrderDetailItem {
  final String bookId;
  final String title;
  final String image;
  final int quantity;
  final double unitPrice;

  OrderDetailItem({
    required this.bookId,
    required this.title,
    required this.image,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrderDetailModel {
  final String orderId;
  final String status;
  final String orderDate;
  final String fullName;
  final String phone;
  final String address;
  final String paymentMethod;
  final double totalAmount;
  final double shippingFee;
  final double voucherDiscount;
  final double pointsDiscount;
  final String customerUsername;
  final List<OrderDetailItem> items;

  OrderDetailModel({
    required this.orderId,
    required this.status,
    required this.orderDate,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.shippingFee,
    required this.voucherDiscount,
    required this.pointsDiscount,
    required this.customerUsername,
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      orderDate: json['orderDate']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
      voucherDiscount: (json['voucherDiscount'] as num?)?.toDouble() ?? 0,
      pointsDiscount: (json['pointsDiscount'] as num?)?.toDouble() ?? 0,
      customerUsername: json['customerUsername']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderDetailItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}