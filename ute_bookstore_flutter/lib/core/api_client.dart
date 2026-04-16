import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_config.dart';
import 'session_storage.dart';

class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  static Future<ApiClient> create(SessionStorage storage) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
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
            debugPrint('BODY: ${error.response?.data}');
          }
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            await storage.clear();
          }
          handler.next(error);
        },
      ),
    );

    return ApiClient._(dio);
  }
}

