import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api_client.dart';
import '../data/dashboard_models.dart';

class PredictionTimeoutException implements Exception {
  PredictionTimeoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PredictionService {
  PredictionService(this._client);

  final ApiClient _client;

  static const _predictionPath = '/admin/dashboard/revenue-prediction';
  static const _jobPath = '/admin/dashboard/revenue-prediction/jobs';
  static const _retryDelay = Duration(seconds: 2);
  static const _pollDelay = Duration(seconds: 3);
  static const _maxRetries = 2;
  static const _maxPolls = 20;

  Future<DashboardRevenuePredictionResponse> fetchPrediction() async {
    try {
      final response = await _retryOnTimeout(() => _client.dio.get(_predictionPath));
      return DashboardRevenuePredictionResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (_isTimeout(error)) {
        debugPrint('Prediction timeout, switching to polling flow: ${error.message}');
        return _fetchWithPolling();
      }
      debugPrint('Prediction request failed: ${error.message}');
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Prediction request error: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<Response<dynamic>> _retryOnTimeout(Future<Response<dynamic>> Function() request) async {
    var attempt = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (error) {
        if (_isTimeout(error) && attempt < _maxRetries) {
          attempt += 1;
          debugPrint('Prediction timeout, retry $attempt/$_maxRetries');
          await Future.delayed(_retryDelay);
          continue;
        }
        rethrow;
      }
    }
  }

  Future<DashboardRevenuePredictionResponse> _fetchWithPolling() async {
    final jobId = await _createPredictionJob();
    for (var attempt = 0; attempt < _maxPolls; attempt += 1) {
      await Future.delayed(_pollDelay);
      final status = await _getJobStatus(jobId);
      if (status.isDone) {
        return status.prediction!;
      }
      if (status.isFailed) {
        throw Exception(status.message ?? 'Prediction job failed.');
      }
    }
    throw PredictionTimeoutException(
      'Máy chủ đang xử lý dữ liệu lâu hơn bình thường. Vui lòng thử lại.',
    );
  }

  Future<String> _createPredictionJob() async {
    try {
      final response = await _client.dio.post(_jobPath);
      final data = response.data as Map<String, dynamic>;
      final jobId = data['jobId']?.toString();
      if (jobId == null || jobId.isEmpty) {
        throw Exception('Prediction job id missing.');
      }
      return jobId;
    } on DioException catch (error) {
      debugPrint('Create prediction job failed: ${error.message}');
      if (_isTimeout(error)) {
        throw PredictionTimeoutException(
          'Máy chủ đang xử lý dữ liệu lâu hơn bình thường. Vui lòng thử lại.',
        );
      }
      rethrow;
    }
  }

  Future<_PredictionJobStatus> _getJobStatus(String jobId) async {
    try {
      final response = await _client.dio.get('$_jobPath/$jobId');
      final data = response.data as Map<String, dynamic>;
      return _PredictionJobStatus.fromJson(data);
    } on DioException catch (error) {
      debugPrint('Prediction polling failed: ${error.message}');
      if (_isTimeout(error)) {
        return const _PredictionJobStatus.pending();
      }
      rethrow;
    }
  }

  bool _isTimeout(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.error is TimeoutException;
  }
}

class _PredictionJobStatus {
  const _PredictionJobStatus({this.status, this.prediction, this.message});

  const _PredictionJobStatus.pending() : status = 'PENDING', prediction = null, message = null;

  final String? status;
  final DashboardRevenuePredictionResponse? prediction;
  final String? message;

  bool get isDone => status == 'DONE' && prediction != null;
  bool get isFailed => status == 'FAILED';

  factory _PredictionJobStatus.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString();
    final predictionData = json['prediction'];
    return _PredictionJobStatus(
      status: status,
      prediction: predictionData is Map<String, dynamic>
          ? DashboardRevenuePredictionResponse.fromJson(predictionData)
          : null,
      message: json['message']?.toString(),
    );
  }
}

