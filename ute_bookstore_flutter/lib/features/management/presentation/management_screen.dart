import 'package:flutter/material.dart';
import '../../customers/presentation/customers_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        'Quản lý người dùng',
        Icons.people_outline,
        screen: const CustomersScreen(),
      ),
      _MenuItem('Khuyến mãi', Icons.local_offer_outlined),
      _MenuItem('Doanh thu', Icons.insights_outlined),
      _MenuItem('Dòng tiền', Icons.account_balance_wallet_outlined),
      _MenuItem('Tin nhắn / hỗ trợ', Icons.chat_bubble_outline),
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
              if (item.screen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.screen!),
                );
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
  final Widget? screen;

  _MenuItem(this.title, this.icon, {this.screen});
}