import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'order_detail_screen.dart';

import '../../../app/providers.dart';
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
  _OrderTabItem(label: 'Hoàn trả', status: 'Returned'),
  _OrderTabItem(label: 'Đã hủy', status: 'Cancelled'),
];

final ordersProvider =
FutureProvider.family<List<OrderItem>, String?>((ref, status) async {
  final api = ref.read(orderApiProvider);
  final data = await api.fetchOrders(page: 0, size: 20, status: status);
  final content = (data['content'] as List<dynamic>? ?? [])
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList();
  content.sort((a, b) =>
      DateTime.parse(b.orderDate).compareTo(DateTime.parse(a.orderDate)));
  return content;
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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: _orderTabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text(
            'Quản lý đơn hàng',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              alignment: Alignment.centerLeft,
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorWeight: 3,
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
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Quản lý đơn',
                      subtitle: 'Theo dõi và cập nhật trạng thái đơn hàng',
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                ],
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _refreshCurrentTab,
          icon: const Icon(Icons.refresh),
          label: const Text('Làm mới'),
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
              );
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

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.statusFilter,
  });

  final OrderItem order;
  final String? statusFilter;

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Shipping':
        return Colors.deepPurple;
      case 'Completed':
        return Colors.green;
      case 'Returned':
        return Colors.teal;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'Pending':
        return 'Chờ xác nhận';
      case 'Confirmed':
        return 'Đã xác nhận';
      case 'Shipping':
        return 'Đang giao';
      case 'Completed':
        return 'Hoàn thành';
      case 'Returned':
        return 'Hoàn trả';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  List<Widget> _buildActionButtons(BuildContext context, WidgetRef ref) {
    final buttons = <Widget>[];

    Future<void> updateTo(String newStatus) async {
      try {
        await ref.read(orderApiProvider).updateStatus(order.orderId, newStatus);

        ref.invalidate(ordersProvider(statusFilter));
        ref.invalidate(ordersProvider(null));
        ref.invalidate(ordersProvider(newStatus));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: $e')),
        );
      }
    }

    switch (order.status.toUpperCase()) {
      case 'Pending':
        final paymentMethod = order.paymentMethod.trim().toUpperCase();
        final isVNPay = paymentMethod.contains('VNPAY');

        buttons.add(
          OutlinedButton(
            onPressed: () => updateTo('Cancelled'),
            child: const Text('Hủy đơn'),
          ),
        );

        if (!isVNPay) {
          buttons.add(
            ElevatedButton(
              onPressed: () => updateTo('Confirmed'),
              child: const Text('Xác nhận'),
            ),
          );
        }
        break;

      case 'Confirmed':
        buttons.add(
          ElevatedButton(
            onPressed: () => updateTo('Shipping'),
            child: const Text('Bắt đầu giao'),
          ),
        );
        break;

      case 'Shipping':

      case 'Completed':

      case 'Cancelled':

      case 'Returned':

      default:
        buttons.add(
          const SizedBox.shrink(),
        );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(order.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.orderId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildActionButtons(context, ref),
                  ),
                ],
              ),
            ],
          ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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