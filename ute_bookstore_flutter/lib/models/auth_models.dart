class LoginResponse {
  final String token;
  final String userId;
  final String userName;
  final String role;
  final String message;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.userName,
    required this.role,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
