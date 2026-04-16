import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/order_models.dart';

final ordersProvider = FutureProvider.family<List<OrderItem>, String?>((ref, status) async {
  final api = ref.read(orderApiProvider);
  final data = await api.fetchOrders(page: 0, size: 20, status: status);
  final content = (data['content'] as List<dynamic>? ?? [])
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList();
  return content;
});

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider(_status));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        actions: [
          DropdownButton<String?>(
            value: _status,
            hint: const Text('Trạng thái'),
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tất cả')),
              DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
              DropdownMenuItem(value: 'CONFIRMED', child: Text('Confirmed')),
              DropdownMenuItem(value: 'SHIPPING', child: Text('Shipping')),
              DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
              DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
            ],
            onChanged: (value) => setState(() => _status = value),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _OrderTile(
            order: orders[index],
            statusFilter: _status,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}

class _OrderTile extends ConsumerWidget {
  const _OrderTile({required this.order, required this.statusFilter});

  final OrderItem order;
  final String? statusFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mã đơn: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Khách: ${order.customerEmail}'),
          Text('Tổng: ${order.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Trạng thái: ${order.status}')),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(orderApiProvider)
                      .updateStatus(order.orderId, 'CONFIRMED');
                  ref.invalidate(ordersProvider(statusFilter));
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
