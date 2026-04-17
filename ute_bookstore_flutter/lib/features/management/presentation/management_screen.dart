import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Dùng Riverpod thay vì Provider
import 'package:ute_bookstore_flutter/app/providers.dart'; // Để lấy chatRepositoryProvider
import 'package:ute_bookstore_flutter/chat/presentation/chat_list_screen.dart';

// Đổi từ StatelessWidget sang ConsumerWidget
class ManagementScreen extends ConsumerWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cách lấy Repository chuẩn Riverpod
    final chatRepo = ref.watch(chatRepositoryProvider);

    final items = [
      _MenuItem('Quản lý người dùng', Icons.people_outline),
      _MenuItem('Khuyến mãi', Icons.local_offer_outlined),
      _MenuItem('Doanh thu', Icons.insights_outlined),
      _MenuItem('Dòng tiền', Icons.account_balance_wallet_outlined),
      _MenuItem('Tin nhắn / hỗ trợ', Icons.chat_bubble_outline),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Quản trị')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Icon(item.icon, color: const Color(0xFF4C6FFF)),
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (item.title == 'Tin nhắn / hỗ trợ') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Truyền repository lấy từ Riverpod vào
                    builder: (context) => ChatListScreen(repository: chatRepo),
                  ),
                );
              } else {
                print("Chạm vào ${item.title}");
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
  _MenuItem(this.title, this.icon);
}