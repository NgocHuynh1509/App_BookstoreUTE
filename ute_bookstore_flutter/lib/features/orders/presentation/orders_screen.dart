import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'order_detail_screen.dart';

import '../../../app/providers.dart';
import '../../../theme/admin_theme.dart';
import '../../../widgets/admin/admin_button.dart';
import '../../../chat/data/chat_repository.dart';
import '../data/order_models.dart';

String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  } catch (e) {
    return dateStr;
  }
}

String formatCurrency(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(value).replaceAll(',', '.')}đ';
}

const List<_OrderTabItem> _orderTabs = [
  _OrderTabItem(label: 'Tất cả', status: null),
  _OrderTabItem(label: 'Chờ xác nhận', status: 'Pending'),
  _OrderTabItem(label: 'Đã xác nhận', status: 'Confirmed'),
  _OrderTabItem(label: 'Đang giao', status: 'Shipping'),
  _OrderTabItem(label: 'Hoàn thành', status: 'Completed'),
  _OrderTabItem(label: 'Yêu cầu hoàn', status: 'RequestingReturn'), // Tab mới
  _OrderTabItem(label: 'Hoàn trả', status: 'Returned'),
  _OrderTabItem(label: 'Đã hủy', status: 'Cancelled'),
];

final ordersProvider =
FutureProvider.family<List<OrderItem>, String?>((ref, status) async {
  final api = ref.read(orderApiProvider);
//   // Nếu là tab "Đợi hoàn trả"
//     if (status == 'RequestingReturn') {
//       // Lấy các đơn Completed để lọc
//       final data = await api.fetchOrders(page: 0, size: 100, status: 'Completed');
//       final content = (data['content'] as List<dynamic>? ?? [])
//           .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
//           // CHỖ QUAN TRỌNG: Chỉ lấy những đơn có yêu cầu trả hàng
//           .where((order) => order.hasReturnRequest == true)
//           .toList();
//
//       content.sort((a, b) =>
//           DateTime.parse(b.orderDate).compareTo(DateTime.parse(a.orderDate)));
//       return content;
//     }
//   final data = await api.fetchOrders(page: 0, size: 20, status: status);
//   final content = (data['content'] as List<dynamic>? ?? [])
//       .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
//       .toList();
//   content.sort((a, b) =>
//       DateTime.parse(b.orderDate).compareTo(DateTime.parse(a.orderDate)));
//   return content;
try {
    if (status == 'RequestingReturn') {
      // Gọi API với status đặc biệt mà mình đã viết ở Backend (ReturnRequest)
      // Thay vì lấy 'Completed' rồi lọc ở App, hãy để Server lọc cho nhanh
      final data = await api.fetchOrders(page: 0, size: 100, status: 'ReturnRequest');

      final List<dynamic> contentJson = data['content'] ?? [];
      return contentJson.map((e) {
        try {
          return OrderItem.fromJson(e as Map<String, dynamic>);
        } catch (e) {
          // Tránh lỗi nếu một item trong list bị lỗi định dạng
          print('Lỗi parse OrderItem: $e');
          return null;
        }
      }).whereType<OrderItem>().toList(); // Loại bỏ các item null
    }

    // Các trường hợp tab khác
    final data = await api.fetchOrders(page: 0, size: 20, status: status);
    final List<dynamic> contentJson = data['content'] ?? [];
    return contentJson
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Lỗi tải danh sách: $e');
  }
});

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _orderTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshCurrentTab() async {
    final status = _orderTabs[_tabController.index].status;
    ref.invalidate(ordersProvider(status));
    await ref.read(ordersProvider(status).future);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _orderTabs.length,
      child: Scaffold(
        backgroundColor: AdminColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AdminColors.surface,
          foregroundColor: AdminColors.textPrimary,
          title: const Text(
            'Quản lý đơn hàng',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              alignment: Alignment.centerLeft,
              color: AdminColors.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorWeight: 3,
                indicatorColor: AdminColors.primary,
                labelColor: AdminColors.primary,
                unselectedLabelColor: AdminColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: _orderTabs
                    .map((tab) => Tab(text: tab.label))
                    .toList(),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AdminColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;
                  final summary = _SummaryCard(
                    title: 'Quản lý đơn',
                    subtitle: 'Theo dõi và cập nhật trạng thái đơn hàng',
                    icon: Icons.receipt_long_rounded,
                  )
                      .animate()
                      .fadeIn(duration: 280.ms)
                      .slideY(begin: 0.08, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);

                  final refreshButton = AdminButton(
                    label: 'Làm mới',
                    icon: Icons.refresh_rounded,
                    expand: !isNarrow,
                    onPressed: _refreshCurrentTab,
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        summary,
                        const SizedBox(height: 12),
                        refreshButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 12),
                      SizedBox(width: 160, child: refreshButton),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _orderTabs.map((tab) {
                  return _OrdersTabView(status: tab.status);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTabView extends ConsumerWidget {
  const _OrdersTabView({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider(status));
    final chatRepository = ref.read(chatRepositoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider(status));
        await ref.read(ordersProvider(status).future);
      },
      child: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                _EmptyOrdersView(),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _OrderCard(
                order: orders[index],
                statusFilter: status,
                chatRepository: chatRepository,
              )
                  .animate()
                  .fadeIn(duration: 240.ms, delay: (index * 25).ms)
                  .slideY(begin: 0.06, end: 0, duration: 240.ms, curve: Curves.easeOutCubic);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Không tải được danh sách đơn hàng.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AdminColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AdminColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AdminColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.statusFilter,
    required this.chatRepository,
  });

  final OrderItem order;
  final String? statusFilter;
  final ChatRepository chatRepository;

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFA726);
      case 'Confirmed':
        return const Color(0xFF42A5F5);
      case 'Shipping':
        return const Color(0xFF7E57C2);
      case 'Completed':
        return const Color(0xFF66BB6A);
      case 'Cancelled':
        return const Color(0xFFEF5350);
      case 'Returned':
        return const Color(0xFF9E9E9E);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xác nhận';
      case 'Confirmed':
        return 'Đã xác nhận';
      case 'Shipping':
        return 'Đang giao';
      case 'Completed':
        return 'Hoàn thành';
      case 'Cancelled':
        return 'Đã hủy';
      case 'Returned':
        return 'Hoàn trả';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              orderId: order.orderId,
              chatRepository: chatRepository,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn #${order.orderId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDate(order.orderDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

                if (order.hasReturnRequest == true)
              Container(
                margin: const EdgeInsets.only(bottom: 12), // Tăng margin một chút cho thoáng
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'ĐƠN HÀNG ĐANG YÊU CẦU HOÀN TRẢ',
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Khách hàng',
              value: order.fullName,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'SĐT',
              value: order.phone,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Địa chỉ',
              value: order.address,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.payments_outlined,
              label: 'Thanh toán',
              value: order.paymentMethod,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tổng thanh toán',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    formatCurrency(order.totalAmount),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '---' : value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}


class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        const Text(
          'Không có đơn hàng nào',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hiện chưa có dữ liệu trong trạng thái này.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _OrderTabItem {
  final String label;
  final String? status;

  const _OrderTabItem({
    required this.label,
    required this.status,
  });
}