class OrderItem {
  final String orderId;
  final String status;
  final String paymentMethod;
  final String address;
  final String customerId;
  final String customerEmail;
  final String fullName;
  final String phone;// ✅ thêm dòng này
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
    required this.fullName,
    required this.phone,// ✅
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
      fullName: json['fullName']?.toString() ?? '', // ✅ thêm
      phone: json['phone']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
      orderDate: json['orderDate']?.toString() ?? '',
    );
  }
}