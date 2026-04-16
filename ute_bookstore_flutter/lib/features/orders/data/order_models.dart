class OrderItem {
  final String orderId;
  final String status;
  final String paymentMethod;
  final String address;
  final String customerId;
  final String customerEmail;
  final double totalAmount;
  final double shippingFee;
  final String orderDate;

  OrderItem({
    required this.orderId,
    required this.status,
    required this.paymentMethod,
    required this.address,
    required this.customerId,
    required this.customerEmail,
    required this.totalAmount,
    required this.shippingFee,
    required this.orderDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
      orderDate: json['orderDate']?.toString() ?? '',
    );
  }
}