import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/customer_model.dart';
import 'customer_detail_screen.dart';

final customerKeywordProvider = StateProvider<String>((ref) => '');
final customerFilterProvider = StateProvider<String>((ref) => 'all');

final customersProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final api = ref.read(customerApiProvider);
  final keyword = ref.watch(customerKeywordProvider);
  final filter = ref.watch(customerFilterProvider);

  bool? enabled;
  if (filter == 'active') enabled = true;
  if (filter == 'inactive') enabled = false;

  return api.fetchCustomers(
    keyword: keyword,
    enabled: enabled,
  );
});

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refresh() async {
    ref.invalidate(customersProvider);
    await ref.read(customersProvider.future);
  }

  Future<void> _toggleStatus(CustomerModel customer) async {
    try {
      await ref.read(customerApiProvider).updateCustomerStatus(
        customerId: customer.customerId,
        enabled: !customer.enabled,
      );

      ref.invalidate(customersProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            customer.enabled ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản',
          ),
        ),
      );
    } catch (e) {
      debugPrint('UPDATE CUSTOMER STATUS ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thất bại')),
      );
    }
  }

  Widget _buildFilterChip(String value, String label) {
    final selected = ref.watch(customerFilterProvider) == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          ref.read(customerFilterProvider.notifier).state = value;
          ref.invalidate(customersProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF3F6FB),
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Quản lý khách hàng',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) {
                    ref.read(customerKeywordProvider.notifier).state =
                        _searchController.text.trim();
                    ref.invalidate(customersProvider);
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm tên, username, email, SĐT...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        ref.read(customerKeywordProvider.notifier).state =
                            _searchController.text.trim();
                        ref.invalidate(customersProvider);
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('all', 'Tất cả'),
                      _buildFilterChip('active', 'Hoạt động'),
                      _buildFilterChip('inactive', 'Đã khóa'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: customersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Không tải được danh sách khách hàng.\n$error',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                data: (customers) {
                  final totalCustomers = customers.length;
                  final activeCustomers =
                      customers.where((e) => e.enabled).length;
                  final totalPoints =
                  customers.fold<int>(0, (sum, e) => sum + e.rewardPoints);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Khách hàng',
                              value: '$totalCustomers',
                              icon: Icons.people_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Hoạt động',
                              value: '$activeCustomers',
                              icon: Icons.verified_user_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Điểm thưởng',
                              value: '$totalPoints',
                              icon: Icons.stars_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (customers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text('Không có khách hàng nào'),
                          ),
                        )
                      else
                        ...customers.map(
                              (customer) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CustomerCard(
                              customer: customer,
                              onView: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerDetailScreen(
                                      customerId: customer.customerId,
                                    ),
                                  ),
                                ).then((_) => ref.invalidate(customersProvider));
                              },
                              onToggleStatus: () => _toggleStatus(customer),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onView;
  final VoidCallback onToggleStatus;

  const _CustomerCard({
    required this.customer,
    required this.onView,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEAF0FF),
                child: Text(
                  customer.fullName.isNotEmpty
                      ? customer.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF4C6FFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.userName ?? 'Không có username',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      customer.email ?? 'Không có email',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: customer.enabled
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  customer.enabled ? 'Hoạt động' : 'Đã khóa',
                  style: TextStyle(
                    color: customer.enabled ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  icon: Icons.phone_outlined,
                  text: customer.phone,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniInfo(
                  icon: Icons.shopping_bag_outlined,
                  text: '${customer.totalOrders} đơn',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  icon: Icons.stars_outlined,
                  text: '${customer.rewardPoints} điểm',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniInfo(
                  icon: Icons.calendar_today_outlined,
                  text: customer.registrationDate ?? 'Chưa rõ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  child: const Text('Chi tiết'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onToggleStatus,
                  child: Text(customer.enabled ? 'Khóa' : 'Mở khóa'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4C6FFF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4C6FFF)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}