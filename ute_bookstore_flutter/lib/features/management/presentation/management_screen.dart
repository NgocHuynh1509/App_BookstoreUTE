import 'package:flutter/material.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('Quản lý người dùng', Icons.people_outline),
      _MenuItem('Khuyến mãi', Icons.local_offer_outlined),
      _MenuItem('Doanh thu', Icons.insights_outlined),
      _MenuItem('Dòng tiền', Icons.account_balance_wallet_outlined),
      _MenuItem('Tin nhắn / hỗ trợ', Icons.chat_bubble_outline),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị')),
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
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
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

