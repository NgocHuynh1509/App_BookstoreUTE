import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/dashboard_models.dart';

class RevenuePredictionCard extends StatelessWidget {
  const RevenuePredictionCard({super.key, required this.prediction});

  final DashboardRevenuePredictionResponse prediction;

  @override
  Widget build(BuildContext context) {
    final changeColor = prediction.changePercent >= 0 ? const Color(0xFF00C2A8) : const Color(0xFFE85C6C);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF4C6FFF).withOpacity(0.12),
                child: const Icon(Icons.auto_graph_rounded, color: Color(0xFF4C6FFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dự đoán doanh thu',
                  style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${prediction.changePercent.toStringAsFixed(1)}%',
                  style: TextStyle(color: changeColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  title: 'Tháng tới',
                  value: prediction.predictedAmount.toStringAsFixed(0),
                  subtitle: 'VND',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  title: 'Tín cậy',
                  value: '${prediction.confidence.toStringAsFixed(0)}%',
                  subtitle: 'R2 ${prediction.r2.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prediction.suggestion,
            style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: RevenuePredictionChart(
              points: prediction.series,
              forecastIndex: prediction.forecastIndex,
            ),
          ),
        ],
      ),
    );
  }
}

class RevenuePredictionChart extends StatelessWidget {
  const RevenuePredictionChart({super.key, required this.points, required this.forecastIndex});

  final List<DashboardSeriesPoint> points;
  final int forecastIndex;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyChartState();
    }
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _chartTitles(points),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(0),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        barGroups: _toBarGroups(points, forecastIndex),
      ),
    );
  }
}

class RevenuePredictionSkeleton extends StatelessWidget {
  const RevenuePredictionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 240,
        decoration: _cardDecoration.copyWith(color: Colors.grey.shade200),
      ),
    );
  }
}

class RevenuePredictionError extends StatelessWidget {
  const RevenuePredictionError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lỗi: $message', style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value, required this.subtitle});

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        'Chưa có dữ liệu',
        style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }
}

FlTitlesData _chartTitles(List<DashboardSeriesPoint> points) {
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: points.length <= 6 ? 1 : (points.length / 6).ceilToDouble(),
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= points.length) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(points[index].label, style: const TextStyle(fontSize: 10)),
          );
        },
      ),
    ),
  );
}

List<BarChartGroupData> _toBarGroups(List<DashboardSeriesPoint> points, int forecastIndex) {
  if (points.isEmpty) {
    return [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: const Color(0xFF4C6FFF))])];
  }
  return points.asMap().entries.map((entry) {
    final isForecast = entry.key == forecastIndex;
    final color = isForecast ? const Color(0xFF00C2A8) : const Color(0xFF4C6FFF);
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value.value,
          color: color,
          width: 10,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }).toList();
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
  ],
);
