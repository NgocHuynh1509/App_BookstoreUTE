import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_config.dart';
import 'session_storage.dart';

class ApiClient {
  ApiClient._(this._dio, this._storage);

  final Dio _dio;
  final SessionStorage _storage;

  Dio get dio => _dio;

  Future<String?> getToken() => _storage.getToken();

  static Future<ApiClient> create(SessionStorage storage) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (!kReleaseMode) {
            debugPrint('HTTP ERROR ${error.response?.statusCode} ${error.requestOptions.uri}');
            debugPrint('REQUEST ${error.requestOptions.method} ${error.requestOptions.uri}');
            debugPrint('REQUEST HEADERS: ${error.requestOptions.headers}');
            debugPrint('REQUEST QUERY: ${error.requestOptions.queryParameters}');
            debugPrint('REQUEST BODY: ${error.requestOptions.data}');
            debugPrint('RESPONSE BODY: ${error.response?.data}');
          }
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            await storage.clear();
          }
          handler.next(error);
        },
      ),
    );

    return ApiClient._(dio, storage);
  }
}
