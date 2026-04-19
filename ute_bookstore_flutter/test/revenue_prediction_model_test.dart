import 'package:flutter_test/flutter_test.dart';

import 'package:ute_bookstore_flutter/features/dashboard/data/dashboard_models.dart';

void main() {
  test('DashboardRevenuePredictionResponse parses json', () {
    final json = {
      'predictedAmount': 1250000,
      'currentMonthTotal': 1000000,
      'changePercent': 25.0,
      'confidence': 82.5,
      'mae': 1.2,
      'mse': 2.3,
      'rmse': 1.5,
      'r2': 0.82,
      'suggestion': 'Doanh thu tang',
      'predictedLabel': '2026-05',
      'forecastIndex': 6,
      'series': [
        {'label': '2026-01', 'value': 800000},
        {'label': '2026-02', 'value': 900000},
        {'label': '2026-03', 'value': 950000},
        {'label': '2026-04', 'value': 1000000},
        {'label': '2026-05', 'value': 1250000},
      ],
    };

    final model = DashboardRevenuePredictionResponse.fromJson(json);

    expect(model.predictedAmount, 1250000);
    expect(model.changePercent, 25.0);
    expect(model.confidence, 82.5);
    expect(model.series.length, 5);
    expect(model.series.last.label, '2026-05');
  });
}

