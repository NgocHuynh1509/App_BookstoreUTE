import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../data/customer_model.dart';

final customerDetailProvider =
FutureProvider.family<CustomerModel, String>((ref, customerId) async {
  final api = ref.read(customerApiProvider);
  return api.fetchCustomerDetail(customerId);
});

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  String _display(String? value, {String fallback = 'Không có'}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Không có';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatBirthday(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Không có';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _infoTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(customerDetailProvider(customerId));
    await ref.read(customerDetailProvider(customerId).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF3F6FB),
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Chi tiết khách hàng',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: customerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Không tải được chi tiết khách hàng\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (c) {
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.18),
                        child: Text(
                          c.fullName.isNotEmpty
                              ? c.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _display(c.fullName, fallback: 'Chưa có tên'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _display(c.email),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: c.enabled
                                    ? Colors.green.withOpacity(0.16)
                                    : Colors.red.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                c.enabled ? 'Hoạt động' : 'Đã khóa',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statBox(
                      label: 'Điểm thưởng',
                      value: '${c.rewardPoints}',
                      icon: Icons.stars_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 12),
                    _statBox(
                      label: 'Số đơn',
                      value: '${c.totalOrders}',
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoTile(
                  icon: Icons.badge_outlined,
                  color: const Color(0xFF2563EB),
                  label: 'Mã KH',
                  value: _display(c.customerId),
                ),
                _infoTile(
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  label: 'Username',
                  value: _display(c.userName),
                ),
                _infoTile(
                  icon: Icons.account_circle_outlined,
                  color: const Color(0xFF0EA5E9),
                  label: 'Họ tên',
                  value: _display(c.fullName),
                ),
                _infoTile(
                  icon: Icons.cake_outlined,
                  color: const Color(0xFFEC4899),
                  label: 'Ngày sinh',
                  value: _formatBirthday(c.dateOfBirth),
                ),
                _infoTile(
                  icon: Icons.phone_outlined,
                  color: const Color(0xFF16A34A),
                  label: 'SĐT',
                  value: _display(c.phone),
                ),
                _infoTile(
                  icon: Icons.email_outlined,
                  color: const Color(0xFFF97316),
                  label: 'Email',
                  value: _display(c.email),
                ),
                _infoTile(
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFFDC2626),
                  label: 'Địa chỉ',
                  value: _display(c.address),
                ),
                _infoTile(
                  icon: Icons.calendar_month_outlined,
                  color: const Color(0xFF0891B2),
                  label: 'Ngày đăng ký',
                  value: _formatDate(c.registrationDate),
                ),
                _infoTile(
                  icon: Icons.verified_user_outlined,
                  color: c.enabled
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  label: 'Trạng thái',
                  value: c.enabled ? 'Hoạt động' : 'Đã khóa',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}