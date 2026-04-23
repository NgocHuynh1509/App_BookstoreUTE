import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/providers.dart';
import '../../../theme/admin_theme.dart';
import '../data/dashboard_models.dart';
import 'widgets/revenue_prediction_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/top_books_card.dart';
import 'widgets/activity_timeline.dart';
import '../../../widgets/admin/animated_chart_card.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchSummary();
});

final dashboardRangeProvider = StateProvider<DashboardRange>((ref) {
  return DashboardRange.week;
});

final dashboardRevenueProvider = FutureProvider.family<DashboardRevenueResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchRevenue(range.apiValue);
});

final dashboardOrdersProvider = FutureProvider.family<DashboardOrdersResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchOrders(range.apiValue);
});

final dashboardChartsProvider = FutureProvider.family<DashboardChartsResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchCharts(range.apiValue);
});

final dashboardPredictionProvider = FutureProvider<DashboardRevenuePredictionResponse>((ref) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchRevenuePrediction();
});

final dashboardTopBooksProvider = FutureProvider.family<DashboardTopBooksResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchTopBooks(range.apiValue);
});

final dashboardRecentActivitiesProvider = FutureProvider<DashboardRecentActivitiesResponse>((ref) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchRecentActivities();
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final range = ref.watch(dashboardRangeProvider);
    final revenueAsync = ref.watch(dashboardRevenueProvider(range));
    final ordersAsync = ref.watch(dashboardOrdersProvider(range));
    final chartsAsync = ref.watch(dashboardChartsProvider(range));
    final predictionAsync = ref.watch(dashboardPredictionProvider);
    final topBooksAsync = ref.watch(dashboardTopBooksProvider(range));
    final activitiesAsync = ref.watch(dashboardRecentActivitiesProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bảng điều khiển', style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
            Text('Tổng quan hôm nay', style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AdminColors.surfaceAlt,
              child: Icon(Icons.person, color: AdminColors.primary, size: 18),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(dashboardRevenueProvider(range));
              ref.invalidate(dashboardOrdersProvider(range));
              ref.invalidate(dashboardChartsProvider(range));
              ref.invalidate(dashboardPredictionProvider);
              ref.invalidate(dashboardTopBooksProvider(range));
              ref.invalidate(dashboardRecentActivitiesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                AnimatedEntry(
                  child: DashboardGreetingCard(),
                ),
                const SizedBox(height: 12),
                AnimatedEntry(
                  child: summaryAsync.when(
                    data: (summary) => QuickStatsGrid(
                      summary: summary,
                      revenueChange: revenueAsync.maybeWhen(
                        data: (revenue) => revenue.changePercent,
                        orElse: () => null,
                      ),
                    ),
                    loading: () => const _SkeletonGrid(),
                    error: (error, _) => _ErrorCard(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 80),
                  child: const SectionHeader(title: 'Doanh thu', subtitle: 'Giai đoạn gần nhất'),
                ),
                const SizedBox(height: 8),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 120),
                  child: FilterChips(
                    selected: range,
                    onChanged: (value) => ref.read(dashboardRangeProvider.notifier).state = value,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 160),
                  child: revenueAsync.when(
                    data: (revenue) => RevenueSummaryCard(revenue: revenue),
                    loading: () => const _SkeletonRow(height: 88),
                    error: (error, _) => _ErrorCard(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardRevenueProvider(range)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 200),
                  child: chartsAsync.when(
                    data: (charts) => RevenueLineChart(points: charts.revenueSeries),
                    loading: () => const _SkeletonChart(),
                    error: (error, _) => _ErrorCard(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardChartsProvider(range)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 220),
                  child: const SectionHeader(title: 'Dự đoán doanh thu', subtitle: 'Tháng tới'),
                ),
                const SizedBox(height: 8),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 240),
                  child: predictionAsync.when(
                    data: (prediction) => RevenuePredictionCard(prediction: prediction),
                    loading: () => const RevenuePredictionSkeleton(),
                    error: (error, _) => RevenuePredictionError(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardPredictionProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 320),
                  child: const SectionHeader(title: 'Biểu đồ', subtitle: 'Đơn hàng và tồn kho'),
                ),
                const SizedBox(height: 8),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 360),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth < 520 ? constraints.maxWidth * 0.86 : 260.0;
                      final chartHeight = constraints.maxWidth < 520 ? 248.0 : 236.0;
                      return SizedBox(
                        height: chartHeight,
                        child: chartsAsync.when(
                          data: (charts) => ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: OrderStatusPieChart(items: charts.orderStatus),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: cardWidth,
                                child: BooksSoldBarChart(points: charts.booksSoldSeries),
                              ),
                            ],
                          ),
                          loading: () => ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(width: cardWidth, child: const _SkeletonBox()),
                              const SizedBox(width: 12),
                              SizedBox(width: cardWidth, child: const _SkeletonBox()),
                            ],
                          ),
                          error: (error, _) => _ErrorCard(
                            message: error.toString(),
                            onRetry: () => ref.invalidate(dashboardChartsProvider(range)),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    final topBooks = topBooksAsync.when(
                      data: (data) {
                        if (data.items.isEmpty) {
                          return const _EmptyStateCard(message: 'Chưa có dữ liệu thống kê');
                        }
                        final items = data.items
                            .map(
                              (item) => TopBookItem(
                                title: item.title,
                                author: item.author,
                                sold: item.soldQuantity,
                                revenue: item.revenue,
                                imageUrl: item.imageUrl,
                              ),
                            )
                            .toList();
                        return TopBooksCard(items: items);
                      },
                      loading: () => const _SkeletonRow(height: 180),
                      error: (error, _) => _ErrorCard(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(dashboardTopBooksProvider(range)),
                      ),
                    );

                    final timeline = activitiesAsync.when(
                      data: (data) {
                        if (data.items.isEmpty) {
                          return const _EmptyStateCard(message: 'Chưa có dữ liệu thống kê');
                        }
                        final items = data.items.map(_mapActivityItem).toList();
                        return ActivityTimelineCard(items: items);
                      },
                      loading: () => const _SkeletonRow(height: 180),
                      error: (error, _) => _ErrorCard(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(dashboardRecentActivitiesProvider),
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: topBooks),
                          const SizedBox(width: 12),
                          Expanded(child: timeline),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        topBooks,
                        const SizedBox(height: 12),
                        timeline,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum DashboardRange { week, month, year, all }

extension DashboardRangeX on DashboardRange {
  String get label {
    switch (this) {
      case DashboardRange.week:
        return '7N';
      case DashboardRange.month:
        return '30N';
      case DashboardRange.year:
        return '1N';
      case DashboardRange.all:
        return 'Tất cả';
    }
  }

  String get apiValue => name;
}

class FilterChips extends StatelessWidget {
  const FilterChips({super.key, required this.selected, required this.onChanged});

  final DashboardRange selected;
  final ValueChanged<DashboardRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: DashboardRange.values
          .map(
            (range) => ChoiceChip(
              label: Text(range.label, style: GoogleFonts.beVietnamPro(fontSize: 12)),
              selected: selected == range,
              onSelected: (_) => onChanged(range),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          )
          .toList(),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 4,
      spacing: 8,
      children: [
        Text(title, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 16)),
        Text(
          subtitle,
          style: GoogleFonts.beVietnamPro(fontSize: 12, color: AdminColors.textSecondary),
        ),
      ],
    );
  }
}

class DashboardGreetingCard extends StatelessWidget {
  const DashboardGreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AdminColors.surfaceAlt,
            child: Icon(Icons.waving_hand_rounded, color: AdminColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào, Admin 👋', style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Đây là tổng quan hoạt động cửa hàng hôm nay.',
                  style: GoogleFonts.beVietnamPro(fontSize: 12, color: AdminColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AdminColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AdminColors.primary),
                const SizedBox(width: 6),
                Text(today, style: GoogleFonts.beVietnamPro(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({super.key, required this.summary, this.revenueChange});

  final DashboardSummary summary;
  final double? revenueChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : width >= 360
                        ? 2
                        : 1;
        final items = [
          StatCard(
            title: 'Doanh thu',
            value: summary.revenueDay,
            icon: Icons.payments,
            isMoney: true,
            accentColor: AdminColors.primary,
            trendPercent: revenueChange,
            trendLabel: 'so với hôm qua',
          ),
          StatCard(
            title: ' Tổng đơn hàng',
            value: summary.totalOrders.toDouble(),
            icon: Icons.receipt_long,
            accentColor: AdminColors.secondary,
          ),
          StatCard(
            title: 'Tổng khách hàng',
            value: summary.totalUsers.toDouble(),
            icon: Icons.people,
            accentColor: AdminColors.success,
          ),
          StatCard(
            title: 'Tổng sản phẩm',
            value: summary.totalBooks.toDouble(),
            icon: Icons.menu_book,
            accentColor: AdminColors.warning,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }
}

class RevenueSummaryCard extends StatelessWidget {
  const RevenueSummaryCard({super.key, required this.revenue});

  final DashboardRevenueResponse revenue;

  @override
  Widget build(BuildContext context) {
    final changeColor = revenue.changePercent >= 0 ? const Color(0xFF00C2A8) : const Color(0xFFE85C6C);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF4C6FFF).withOpacity(0.12),
            child: const Icon(Icons.trending_up, color: Color(0xFF4C6FFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng doanh thu'),
                AnimatedCountText(
                  value: revenue.total,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  isMoney: true,
                ),
              ],
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${revenue.changePercent.toStringAsFixed(1)}%',
                  style: TextStyle(color: changeColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key, required this.points});

  final List<DashboardSeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyStateCard(message: 'Chưa có dữ liệu doanh thu');
    }
    return AnimatedChartCard(
      title: 'Xu hướng doanh thu',
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: _chartTitles(points),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (items) => items
                    .map((item) => LineTooltipItem(
                          item.y.toStringAsFixed(0),
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _toSpots(points),
                isCurved: true,
                color: const Color(0xFF4C6FFF),
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: const Color(0xFF4C6FFF).withOpacity(0.12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BooksSoldBarChart extends StatelessWidget {
  const BooksSoldBarChart({super.key, required this.points});

  final List<DashboardSeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyStateCard(message: 'Chưa có dữ liệu bán hàng');
    }
    return AnimatedChartCard(
      title: 'Sách đã bán',
      child: SizedBox(
        height: 120,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: _chartTitles(points),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  rod.toY.toStringAsFixed(0),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            barGroups: _toBarGroups(points, const Color(0xFF00C2A8)),
          ),
        ),
      ),
    );
  }
}

class OrderStatusPieChart extends StatelessWidget {
  const OrderStatusPieChart({super.key, required this.items});

  final List<DashboardStatusCount> items;

  @override
  Widget build(BuildContext context) {
    return _PieChartCard(title: 'Trạng thái đơn hàng', items: items, colors: _chartPalette);
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.title,
    required this.items,
    required this.colors,
  });

  final String title;
  final List<DashboardStatusCount> items;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyStateCard(message: 'Không có dữ liệu');
    }
    final total = items.fold<int>(0, (sum, item) => sum + item.count);
    return AnimatedChartCard(
      title: title,
      child: SizedBox(
        height: 120,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 16,
            sections: List.generate(items.length, (index) {
              final item = items[index];
              final percent = total == 0 ? 0 : (item.count / total * 100);
              return PieChartSectionData(
                value: item.count.toDouble(),
                title: '${percent.toStringAsFixed(0)}%',
                color: colors[index % colors.length],
                radius: 40,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class InsightRow extends StatelessWidget {
  const InsightRow({super.key, required this.summary, required this.revenueAsync});

  final DashboardSummary summary;
  final AsyncValue<DashboardRevenueResponse> revenueAsync;

  @override
  Widget build(BuildContext context) {
    final revenueChange = revenueAsync.maybeWhen(data: (data) => data.changePercent, orElse: () => 0.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final cards = [
          InsightCard(
            title: 'Doanh thu hôm nay',
            value: summary.revenueDay.toStringAsFixed(0),
            subtitle: '${revenueChange.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: revenueChange >= 0 ? const Color(0xFF00C2A8) : const Color(0xFFE85C6C),
          ),
          InsightCard(
            title: 'Tồn kho thấp',
            value: summary.lowStockBooks.toString(),
            subtitle: 'Cần nhập thêm',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFFFB020),
          ),
          InsightCard(
            title: 'Đang chờ xử lý',
            value: summary.pendingOrders.toString(),
            subtitle: 'Đơn hàng',
            icon: Icons.pending_actions,
            color: const Color(0xFF4C6FFF),
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 12),
              ]
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
          Text(subtitle, style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.5,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => const _SkeletonBox(),
        );
      },
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: const _SkeletonBox());
  }
}

class _SkeletonChart extends StatelessWidget {
  const _SkeletonChart();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonRow(height: 220);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: _cardDecoration.copyWith(color: Colors.grey.shade200),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText({
    super.key,
    required this.value,
    required this.style,
    this.isMoney = false,
  });

  final double value;
  final TextStyle? style;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      builder: (context, val, _) {
        final text = isMoney ? _formatCurrency(val) : val.toStringAsFixed(0);
        return Text(text, style: style);
      },
    );
  }
}

String _formatCurrency(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(value).replaceAll(',', '.')} đ';
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

List<BarChartGroupData> _toBarGroups(List<DashboardSeriesPoint> points, Color color) {
  if (points.isEmpty) {
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: color)])
    ];
  }
  return points.asMap().entries.map((entry) {
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(toY: entry.value.value, color: color, width: 10),
      ],
    );
  }).toList();
}

const _cardDecoration = BoxDecoration(
  color: AdminColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
  ],
);

const List<Color> _chartPalette = [
  AdminColors.primary,
  AdminColors.secondary,
  AdminColors.warning,
  AdminColors.danger,
  Color(0xFF6366F1),
];

ActivityItem _mapActivityItem(DashboardRecentActivity activity) {
  final type = activity.type.toUpperCase();
  if (type == 'ORDER_CANCELLED') {
    return ActivityItem(
      title: activity.title,
      subtitle: activity.subtitle,
      time: activity.time.isEmpty ? '—' : activity.time,
      icon: Icons.cancel_rounded,
      color: AdminColors.danger,
    );
  }
  return ActivityItem(
    title: activity.title,
    subtitle: activity.subtitle,
    time: activity.time.isEmpty ? '—' : activity.time,
    icon: Icons.receipt_long_rounded,
    color: AdminColors.primary,
  );
}
