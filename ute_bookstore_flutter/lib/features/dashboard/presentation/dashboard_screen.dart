import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/badge_icon.dart';
import '../data/dashboard_models.dart';

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

final dashboardBooksProvider = FutureProvider.family<DashboardBooksResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchBooks(range.apiValue);
});

final dashboardOrdersProvider = FutureProvider.family<DashboardOrdersResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchOrders(range.apiValue);
});

final dashboardChartsProvider = FutureProvider.family<DashboardChartsResponse, DashboardRange>((ref, range) async {
  final api = ref.read(dashboardApiProvider);
  return api.fetchCharts(range.apiValue);
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
    final booksAsync = ref.watch(dashboardBooksProvider(range));
    final ordersAsync = ref.watch(dashboardOrdersProvider(range));
    final chartsAsync = ref.watch(dashboardChartsProvider(range));

    final unreadCount = summaryAsync.maybeWhen(data: (data) => data.unreadMessages, orElse: () => 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BadgeIcon(
              icon: Icons.notifications_none_rounded,
              count: unreadCount,
              onPressed: () {},
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
              ref.invalidate(dashboardBooksProvider(range));
              ref.invalidate(dashboardOrdersProvider(range));
              ref.invalidate(dashboardChartsProvider(range));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                AnimatedEntry(
                  child: summaryAsync.when(
                    data: (summary) => QuickStatsGrid(summary: summary),
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
                  delay: const Duration(milliseconds: 240),
                  child: const SectionHeader(title: 'Nổi bật', subtitle: 'Thông tin nhanh'),
                ),
                const SizedBox(height: 8),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 280),
                  child: summaryAsync.when(
                    data: (summary) => InsightRow(summary: summary, revenueAsync: revenueAsync),
                    loading: () => const _SkeletonRow(height: 82),
                    error: (error, _) => _ErrorCard(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 320),
                  child: const SectionHeader(title: 'Biểu đồ khác', subtitle: 'Đơn hàng và tồn kho'),
                ),
                const SizedBox(height: 8),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 360),
                  child: SizedBox(
                    height: 190,
                    child: chartsAsync.when(
                      data: (charts) => ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 220,
                            child: OrderStatusPieChart(items: charts.orderStatus),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 220,
                            child: BooksSoldBarChart(points: charts.booksSoldSeries),
                          ),
                        ],
                      ),
                      loading: () => ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          SizedBox(width: 220, child: _SkeletonBox()),
                          SizedBox(width: 12),
                          SizedBox(width: 220, child: _SkeletonBox()),
                        ],
                      ),
                      error: (error, _) => _ErrorCard(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(dashboardChartsProvider(range)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 400),
                  child: booksAsync.when(
                    data: (books) => BooksOverviewRow(books: books),
                    loading: () => const _SkeletonRow(height: 90),
                    error: (error, _) => _ErrorCard(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardBooksProvider(range)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntry(
                  delay: const Duration(milliseconds: 440),
                  child: ordersAsync.when(
                    data: (orders) => OrdersSummaryCard(orders: orders),
                    loading: () => const _SkeletonRow(height: 90),
                    error: (error, _) => _ErrorCard(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(dashboardOrdersProvider(range)),
                    ),
                  ),
                ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(width: 8),
        Text(subtitle, style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      CompactStatCard(
        title: 'Sách',
        value: summary.totalBooks.toDouble(),
        icon: Icons.menu_book,
        gradient: const LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]),
        iconColor: const Color(0xFF4C6FFF),
      ),
      CompactStatCard(
        title: 'Đơn hàng',
        value: summary.totalOrders.toDouble(),
        icon: Icons.receipt_long,
        gradient: const LinearGradient(colors: [Color(0xFFE8FFF9), Color(0xFFDFF7F1)]),
        iconColor: const Color(0xFF00A884),
      ),
      CompactStatCard(
        title: 'Doanh thu',
        value: summary.revenueDay,
        icon: Icons.payments,
        gradient: const LinearGradient(colors: [Color(0xFFFFF4E6), Color(0xFFFFE7CC)]),
        iconColor: const Color(0xFFFF9800),
        isMoney: true,
      ),
      CompactStatCard(
        title: 'Người dùng',
        value: summary.totalUsers.toDouble(),
        icon: Icons.people,
        gradient: const LinearGradient(colors: [Color(0xFFFBE7FF), Color(0xFFF3D6FF)]),
        iconColor: const Color(0xFF9C27B0),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class CompactStatCard extends StatelessWidget {
  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    this.isMoney = false,
  });

  final String title;
  final double value;
  final IconData icon;
  final LinearGradient gradient;
  final Color iconColor;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey.shade700)),
          AnimatedCountText(
            value: value,
            isMoney: isMoney,
            style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
          Container(
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
        ],
      ),
    );
  }
}

class OrdersSummaryCard extends StatelessWidget {
  const OrdersSummaryCard({super.key, required this.orders});

  final DashboardOrdersResponse orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00C2A8).withOpacity(0.12),
            child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF00C2A8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đơn hàng trong khoảng'),
                AnimatedCountText(
                  value: orders.totalOrders.toDouble(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6FFF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${orders.completionRate.toStringAsFixed(1)}%',
              style: const TextStyle(color: Color(0xFF4C6FFF), fontWeight: FontWeight.w600),
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
    return _SectionCard(
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
    return _SectionCard(
      title: 'Sách đã bán',
      child: SizedBox(
        height: 150,
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
    return _SectionCard(
      title: title,
      child: SizedBox(
        height: 150,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 24,
            sections: List.generate(items.length, (index) {
              final item = items[index];
              final percent = total == 0 ? 0 : (item.count / total * 100);
              return PieChartSectionData(
                value: item.count.toDouble(),
                title: '${percent.toStringAsFixed(0)}%',
                color: colors[index % colors.length],
                radius: 52,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
    return Row(
      children: [
        Expanded(
          child: InsightCard(
            title: 'Doanh thu hôm nay',
            value: summary.revenueDay.toStringAsFixed(0),
            subtitle: '${revenueChange.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: revenueChange >= 0 ? const Color(0xFF00C2A8) : const Color(0xFFE85C6C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InsightCard(
            title: 'Tồn kho thấp',
            value: summary.lowStockBooks.toString(),
            subtitle: 'Cần nhập thêm',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFFFB020),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InsightCard(
            title: 'Đang chờ xử lý',
            value: summary.pendingOrders.toString(),
            subtitle: 'Đơn hàng',
            icon: Icons.pending_actions,
            color: const Color(0xFF4C6FFF),
          ),
        ),
      ],
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

class BooksOverviewRow extends StatelessWidget {
  const BooksOverviewRow({super.key, required this.books});

  final DashboardBooksResponse books;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(
            title: 'Đã bán',
            value: books.soldBooks.toDouble(),
            icon: Icons.local_fire_department,
            color: const Color(0xFFE85C6C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MiniStatCard(
            title: 'Tồn kho',
            value: books.stockBooks.toDouble(),
            icon: Icons.inventory_2,
            color: const Color(0xFF00C2A8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MiniStatCard(
            title: 'Cảnh báo',
            value: books.lowStockBooks.toDouble(),
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFFFB020),
          ),
        ),
      ],
    );
  }
}

class MiniStatCard extends StatelessWidget {
  const MiniStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final double value;
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
          AnimatedCountText(
            value: value,
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
          ),
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, _controller.forward);
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const _SkeletonBox(),
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
        final text = isMoney ? val.toStringAsFixed(0) : val.toStringAsFixed(0);
        return Text(text, style: style);
      },
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
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
  ],
);

const List<Color> _chartPalette = [
  Color(0xFF4C6FFF),
  Color(0xFF00C2A8),
  Color(0xFFFFB020),
  Color(0xFFE85C6C),
  Color(0xFF8B5CF6),
];

