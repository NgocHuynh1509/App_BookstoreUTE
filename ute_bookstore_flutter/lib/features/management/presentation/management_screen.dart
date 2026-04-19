import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ute_bookstore_flutter/app/providers.dart';
import 'package:ute_bookstore_flutter/chat/presentation/chat_list_screen.dart';
import '../../customers/presentation/customers_screen.dart';

class ManagementScreen extends ConsumerStatefulWidget {
  const ManagementScreen({super.key});

  @override
  ConsumerState<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends ConsumerState<ManagementScreen> {
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();
    _checkUnreadStatus();
  }

  Future<void> _checkUnreadStatus() async {
    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final status = await chatRepo.hasUnread();
      if (mounted) {
        setState(() {
          _hasUnread = status;
        });
      }
    } catch (e) {
      debugPrint("Lỗi kiểm tra trạng thái tin nhắn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
        showDot: _hasUnread, // ✅ Chấm đỏ
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Quản trị',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _checkUnreadStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
            trailing: SizedBox(
              width: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item.showDot)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            onTap: () async {
              if (item.builder != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: item.builder!,
                  ),
                );
                // Khi quay lại từ màn hình khác, kiểm tra lại unread status
                _checkUnreadStatus();
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
  final bool showDot;

  _MenuItem({
    required this.title,
    required this.icon,
    this.builder,
    this.showDot = false,
  });
}