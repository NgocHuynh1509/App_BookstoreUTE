import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../../models/auth_models.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LoginResponse> me() async {
    final response = await _client.dio.get('/auth/me');
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

