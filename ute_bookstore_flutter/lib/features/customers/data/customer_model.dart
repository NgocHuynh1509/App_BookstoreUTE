class CustomerModel {
  final String customerId;
  final String? userName;
  final String fullName;
  final String? dateOfBirth;
  final String phone;
  final String? email;
  final String address;
  final String? registrationDate;
  final int rewardPoints;
  final bool enabled;
  final int totalOrders;

  CustomerModel({
    required this.customerId,
    required this.userName,
    required this.fullName,
    required this.dateOfBirth,
    required this.phone,
    required this.email,
    required this.address,
    required this.registrationDate,
    required this.rewardPoints,
    required this.enabled,
    required this.totalOrders,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['customerId']?.toString() ?? '',
      userName: json['userName']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString(),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString() ?? '',
      registrationDate: json['registrationDate']?.toString(),
      rewardPoints: (json['rewardPoints'] as num?)?.toInt() ?? 0,
      enabled: json['enabled'] == true,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
    );
  }
}