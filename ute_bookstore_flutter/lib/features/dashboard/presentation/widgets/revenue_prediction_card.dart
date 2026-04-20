import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/dashboard_models.dart';
import '../../../../theme/admin_theme.dart';

class RevenuePredictionCard extends StatelessWidget {
  const RevenuePredictionCard({super.key, required this.prediction});

  final DashboardRevenuePredictionResponse prediction;

  @override
  Widget build(BuildContext context) {
    final changeColor = prediction.changePercent >= 0 ? const Color(0xFF00C2A8) : const Color(0xFFE85C6C);
    final trendLabel = prediction.changePercent >= 0 ? 'Tăng trưởng' : 'Giảm nhẹ';
    final stabilityLabel = prediction.confidence >= 75 ? 'Ổn định cao' : 'Dao động vừa';
    final riskLabel = prediction.confidence >= 85
        ? 'Thấp'
        : prediction.confidence >= 70
            ? 'Vừa'
            : 'Cao';
    final insights = [
      'Xu hướng $trendLabel ${prediction.changePercent.toStringAsFixed(1)}% so với kỳ trước',
      'Độ tin cậy ${prediction.confidence.toStringAsFixed(0)}% (R2 ${prediction.r2.toStringAsFixed(2)})',
      'Chuỗi lịch sử $stabilityLabel trong các kỳ gần đây',
    ];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dự đoán doanh thu',
                      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prediction.predictedLabel.isEmpty ? 'Tháng tới' : prediction.predictedLabel,
                      style: GoogleFonts.beVietnamPro(fontSize: 11, color: AdminColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: 'AI',
                color: const Color(0xFF4C6FFF),
              ),
              const SizedBox(width: 6),
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
                  value: _formatCurrency(prediction.predictedAmount),
                  subtitle: 'Dự kiến',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  title: 'Độ tin cậy',
                  value: '${prediction.confidence.toStringAsFixed(0)}%',
                  subtitle: 'R2 ${prediction.r2.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AiStatTile(
                  label: 'Xu hướng',
                  value: trendLabel,
                  color: changeColor,
                  icon: prediction.changePercent >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiStatTile(
                  label: 'Rủi ro',
                  value: riskLabel,
                  color: riskLabel == 'Thấp'
                      ? const Color(0xFF00C2A8)
                      : riskLabel == 'Vừa'
                          ? const Color(0xFFFFB020)
                          : const Color(0xFFE85C6C),
                  icon: Icons.shield_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiStatTile(
                  label: 'Đề xuất',
                  value: 'Nhập thêm',
                  color: const Color(0xFF4C6FFF),
                  icon: Icons.lightbulb_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(label: trendLabel, color: changeColor),
              _StatusChip(label: stabilityLabel, color: const Color(0xFF00C2A8)),
              _StatusChip(label: 'Cập nhật hôm nay', color: const Color(0xFF4C6FFF)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prediction.suggestion,
            style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 6),
          Column(
            children: insights
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _InsightRow(text: item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E9F5)),
            ),
            child: SizedBox(
              height: 160,
              child: RevenuePredictionChart(
                points: prediction.series,
                forecastIndex: prediction.forecastIndex,
              ),
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
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _chartTitles(points),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (items) => items
                .map(
                  (item) => LineTooltipItem(
                    _formatCurrency(item.y),
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _toSpots(points),
            isCurved: true,
            color: const Color(0xFF7C3AED),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.x.round() == forecastIndex,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF7C3AED),
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.25),
                  const Color(0xFF7C3AED).withOpacity(0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF00C2A8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

class _AiStatTile extends StatelessWidget {
  const _AiStatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.beVietnamPro(fontSize: 9, color: AdminColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ],
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

List<FlSpot> _toSpots(List<DashboardSeriesPoint> points) {
  if (points.isEmpty) {
    return [const FlSpot(0, 0)];
  }
  return points.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), entry.value.value);
  }).toList();
}

String _formatCurrency(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(value).replaceAll(',', '.')} đ';
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
  ],
);
