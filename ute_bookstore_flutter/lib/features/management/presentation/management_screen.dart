import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ute_bookstore_flutter/app/providers.dart';
import 'package:ute_bookstore_flutter/chat/presentation/chat_list_screen.dart';
import '../../customers/presentation/customers_screen.dart';

class ManagementScreen extends ConsumerWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRepo = ref.watch(chatRepositoryProvider);

    final items = [
      _MenuItem(
        title: 'Quản lý người dùng',
        icon: Icons.people_outline,
        builder: (_) => const CustomersScreen(),
      ),
      _MenuItem(
        title: 'Khuyến mãi',
        icon: Icons.local_offer_outlined,
      ),
      _MenuItem(
        title: 'Doanh thu',
        icon: Icons.insights_outlined,
      ),
      _MenuItem(
        title: 'Dòng tiền',
        icon: Icons.account_balance_wallet_outlined,
      ),
      _MenuItem(
        title: 'Tin nhắn / hỗ trợ',
        icon: Icons.chat_bubble_outline,
        builder: (_) => ChatListScreen(repository: chatRepo),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Quản trị',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Icon(item.icon, color: const Color(0xFF4C6FFF)),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (item.builder != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: item.builder!,
                  ),
                );
              } else {
                debugPrint("Chưa có màn cho: ${item.title}");
              }
            },
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final WidgetBuilder? builder;

  _MenuItem({
    required this.title,
    required this.icon,
    this.builder,
  });
}