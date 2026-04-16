import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';
import '../models/auth_models.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';

  /// Gọi API đăng nhập admin
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);

        // Lưu token & userId vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, loginResponse.token);
        await prefs.setString(_userIdKey, loginResponse.userId);

        return loginResponse;
      } else {
        throw Exception(
          _extractErrorMessage(
            response.body,
            fallback: 'Đăng nhập thất bại (mã ${response.statusCode})',
          ),
        );
      }
    } catch (e) {
      throw Exception('Không kết nối được tới server: $e');
    }
  }

  /// Gọi API quên mật khẩu
  static Future<String> forgotPassword({required String email}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['message']?.toString() ?? 'Vui lòng kiểm tra email';
      } else {
        throw Exception(
          _extractErrorMessage(
            response.body,
            fallback: 'Yêu cầu thất bại (mã ${response.statusCode})',
          ),
        );
      }
    } catch (e) {
      throw Exception('Không kết nối được tới server: $e');
    }
  }

  /// Lấy token đã lưu
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Lấy userId đã lưu
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Xoá token + userId (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  static String _extractErrorMessage(String body, {required String fallback}) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }

      // Spring validation error thường trả errors/details thay vì message.
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.join(', ');
      }

      final error = data['error']?.toString();
      if (error != null && error.trim().isNotEmpty) {
        return '$error: $fallback';
      }

      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}

