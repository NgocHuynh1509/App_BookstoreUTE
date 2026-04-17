import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../data/order_detail_model.dart';
import 'orders_screen.dart';

final orderDetailProvider =
FutureProvider.family<OrderDetailModel, String>((ref, orderId) async {
  final api = ref.read(orderApiProvider);
  return api.fetchOrderDetail(orderId);
});

String formatCurrency(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(value).replaceAll(',', '.')}đ';
}

String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr).toLocal();
    return DateFormat('HH:mm, dd/MM/yyyy').format(date);
  } catch (_) {
    return dateStr;
  }
}

Color orderStatusColor(String status) {
  switch (status.trim().toUpperCase()) {
    case 'PENDING':
      return Colors.orange;
    case 'CONFIRMED':
      return Colors.blue;
    case 'SHIPPING':
      return Colors.deepPurple;
    case 'COMPLETED':
      return Colors.green;
    case 'RETURNED':
      return Colors.teal;
    case 'CANCELLED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String orderStatusLabel(String status) {
  switch (status.trim().toUpperCase()) {
    case 'PENDING':
      return 'Chờ xác nhận';
    case 'CONFIRMED':
      return 'Đã xác nhận';
    case 'SHIPPING':
      return 'Đang giao';
    case 'COMPLETED':
      return 'Hoàn thành';
    case 'RETURNED':
      return 'Hoàn trả';
    case 'CANCELLED':
      return 'Đã hủy';
    default:
      return status;
  }
}

Future<void> updateOrderStatus(
    WidgetRef ref,
    BuildContext context,
    String orderId,
    String newStatus,
    ) async {
  try {
    await ref.read(orderApiProvider).updateStatus(orderId, newStatus);

    ref.invalidate(orderDetailProvider(orderId));
    ref.invalidate(ordersProvider(null));
    ref.invalidate(ordersProvider('Pending'));
    ref.invalidate(ordersProvider('Confirmed'));
    ref.invalidate(ordersProvider('Shipping'));
    ref.invalidate(ordersProvider('Completed'));
    ref.invalidate(ordersProvider('Returned'));
    ref.invalidate(ordersProvider('Cancelled'));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thành công')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    }
  }
}

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Lỗi tải chi tiết đơn hàng\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (order) {
          final subtotal = order.items.fold<double>(
            0,
                (sum, item) => sum + item.unitPrice * item.quantity,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                title: 'Trạng thái đơn hàng',
                icon: Icons.local_shipping_outlined,
                child: Row(
                  children: [
                    Expanded(
                      child: _DetailRow(
                        label: 'Mã đơn',
                        value: order.orderId,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: orderStatusColor(order.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        orderStatusLabel(order.status),
                        style: TextStyle(
                          color: orderStatusColor(order.status),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Thông tin giao hàng',
                icon: Icons.location_on_outlined,
                child: Column(
                  children: [
                    _DetailRow(label: 'Người nhận', value: order.fullName),
                    _DetailRow(label: 'Số điện thoại', value: order.phone),
                    _DetailRow(label: 'Địa chỉ', value: order.address),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Sản phẩm đã đặt (${order.items.length})',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: order.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index == order.items.length - 1 ? 0 : 14,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.image.isNotEmpty
                                ? Image.network(
                              item.image.startsWith('http')
                                  ? item.image
                                  : 'http://10.0.2.2:8080/uploads/${item.image}',
                              width: 72,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 72,
                                height: 96,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              ),
                            )
                                : Container(
                              width: 72,
                              height: 96,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.menu_book_outlined),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'x${item.quantity}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${formatCurrency(item.unitPrice)} / cuốn',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  formatCurrency(item.unitPrice * item.quantity),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Tóm tắt thanh toán',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Thanh toán qua',
                      value: order.paymentMethod,
                    ),
                    _DetailRow(
                      label: 'Ngày đặt hàng',
                      value: formatDate(order.orderDate),
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      label: 'Tạm tính',
                      value: formatCurrency(subtotal),
                    ),
                    _DetailRow(
                      label: 'Phí vận chuyển',
                      value: order.shippingFee > 0
                          ? formatCurrency(order.shippingFee)
                          : 'Miễn phí',
                      valueColor:
                      order.shippingFee > 0 ? null : Colors.green,
                    ),
                    if (order.voucherDiscount > 0)
                      _DetailRow(
                        label: 'Mã giảm giá',
                        value: '-${formatCurrency(order.voucherDiscount)}',
                        valueColor: Colors.red,
                      ),
                    if (order.pointsDiscount > 0)
                      _DetailRow(
                        label: 'Dùng điểm thưởng',
                        value: '-${formatCurrency(order.pointsDiscount)}',
                        valueColor: Colors.red,
                      ),
                    const Divider(height: 24),
                    _DetailRow(
                      label: 'Tổng thanh toán',
                      value: formatCurrency(order.totalAmount),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _OrderActionSection(order: order),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _OrderActionSection extends ConsumerWidget {
  const _OrderActionSection({
    required this.order,
  });

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = order.status.trim().toUpperCase();
    final paymentMethod = order.paymentMethod.trim().toUpperCase();
    final isVNPay = paymentMethod.contains('VNPAY');

    final actions = <Widget>[];

    void addConfirmButton({
      required String title,
      required String message,
      required String newStatus,
      required Color color,
      required String buttonText,
      required IconData icon,
    }) {
      actions.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Không'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await updateOrderStatus(
                          ref,
                          context,
                          order.orderId,
                          newStatus,
                        );
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(icon),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      );
    }

    switch (status) {
      case 'PENDING':
        if (!isVNPay) {
          addConfirmButton(
            title: 'Xác nhận đơn hàng',
            message: 'Chuyển đơn này sang trạng thái Đã xác nhận?',
            newStatus: 'Confirmed',
            color: Colors.blue,
            buttonText: 'Xác nhận đơn',
            icon: Icons.check_circle_outline,
          );
          actions.add(const SizedBox(height: 10));
        }

        addConfirmButton(
          title: 'Hủy đơn hàng',
          message: 'Bạn chắc chắn muốn hủy đơn này?',
          newStatus: 'Cancelled',
          color: Colors.red,
          buttonText: 'Hủy đơn',
          icon: Icons.cancel_outlined,
        );
        break;

      case 'CONFIRMED':
        addConfirmButton(
          title: 'Bắt đầu giao hàng',
          message: 'Chuyển đơn này sang trạng thái Đang giao?',
          newStatus: 'Shipping',
          color: Colors.deepPurple,
          buttonText: 'Bắt đầu giao',
          icon: Icons.local_shipping_outlined,
        );
        break;

      case 'SHIPPING':
        addConfirmButton(
          title: 'Hoàn thành đơn hàng',
          message: 'Xác nhận đơn này đã giao thành công?',
          newStatus: 'Completed',
          color: Colors.green,
          buttonText: 'Đã giao thành công',
          icon: Icons.verified_outlined,
        );
        actions.add(const SizedBox(height: 10));
        addConfirmButton(
          title: 'Xử lý hoàn trả',
          message: 'Chuyển đơn này sang trạng thái Hoàn trả?',
          newStatus: 'Returned',
          color: Colors.teal,
          buttonText: 'Đánh dấu hoàn trả',
          icon: Icons.assignment_return_outlined,
        );
        break;

      case 'COMPLETED':
      case 'RETURNED':
      case 'CANCELLED':
      default:
        return const SizedBox.shrink();
    }

    return _InfoCard(
      title: 'Xử lý đơn hàng',
      icon: Icons.settings_outlined,
      child: Column(
        children: actions,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '---' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? (isTotal ? Colors.red : Colors.black87),
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                fontSize: isTotal ? 20 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}