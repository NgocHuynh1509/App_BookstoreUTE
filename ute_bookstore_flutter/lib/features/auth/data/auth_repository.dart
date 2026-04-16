import '../../../core/session_storage.dart';
import '../../../models/auth_models.dart';
import 'auth_api.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final AuthApi _api;
  final SessionStorage _storage;

  Future<LoginResponse> login(String email, String password) async {
    final response = await _api.login(email: email, password: password);
    await _storage.saveSession(
      token: response.token,
      userId: response.userId,
      role: response.role,
      userName: response.userName,
    );
    return response;
  }

  Future<LoginResponse> me() async {
    return _api.me();
  }

  Future<void> logout() async {
    await _storage.clear();
  }
}

