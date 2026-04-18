import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/dashboard_models.dart';
import 'prediction_service.dart';

final predictionServiceProvider = Provider<PredictionService>((ref) {
  return PredictionService(ref.read(apiClientProvider));
});

final predictionProvider = AutoDisposeAsyncNotifierProvider<PredictionNotifier, DashboardRevenuePredictionResponse>(
  PredictionNotifier.new,
);

class PredictionNotifier extends AutoDisposeAsyncNotifier<DashboardRevenuePredictionResponse> {
  late final PredictionService _service;

  @override
  Future<DashboardRevenuePredictionResponse> build() async {
    _service = ref.read(predictionServiceProvider);
    return _load();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<DashboardRevenuePredictionResponse> _load() async {
    try {
      return await _service.fetchPrediction();
    } catch (error, stackTrace) {
      debugPrint('Prediction load error: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}

