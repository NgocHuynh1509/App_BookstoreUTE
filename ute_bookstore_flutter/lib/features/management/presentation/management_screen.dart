import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../widgets/placeholder_screen.dart';
import '../../customers/presentation/customers_screen.dart';
import '../../auth/presentation/admin_login_screen.dart';
// Giả định import cho ChatListScreen nếu bạn đã có file này
import '../../../../chat/presentation/chat_list_screen.dart';

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

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(sessionStorageProvider).clear();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);

    final items = [
      _MenuItem(
        'Quản lý người dùng',
        Icons.people_outline,
        screen: const CustomersScreen(),
      ),
      _MenuItem(
        'Tin nhắn / hỗ trợ',
        Icons.chat_bubble_outline,
//         builder: (_) => ChatListScreen(repository: chatRepo), // Sử dụng builder nếu cần truyền repo
//         screen: const PlaceholderScreen(title: 'Tin nhắn / hỗ trợ'), // Thay thế bằng ChatListScreen thực tế
        screen: ChatListScreen(repository: chatRepo),
        showDot: _hasUnread,
      ),
      _MenuItem('Danh mục', Icons.category_outlined, screen: const PlaceholderScreen(title: 'Danh mục')),
      _MenuItem('Mã giảm giá', Icons.local_offer_outlined, screen: const PlaceholderScreen(title: 'Mã giảm giá')),
      _MenuItem('Nhân viên', Icons.badge_outlined, screen: const PlaceholderScreen(title: 'Nhân viên')),
      _MenuItem('Đánh giá', Icons.star_outline, screen: const PlaceholderScreen(title: 'Đánh giá')),
      _MenuItem('Thông báo', Icons.notifications_none_rounded, screen: const PlaceholderScreen(title: 'Thông báo')),
      _MenuItem('Báo cáo', Icons.summarize_outlined, screen: const PlaceholderScreen(title: 'Báo cáo')),
      _MenuItem('Thống kê', Icons.insights_outlined, screen: const PlaceholderScreen(title: 'Thống kê')),
      _MenuItem('Cài đặt', Icons.settings_outlined, screen: const PlaceholderScreen(title: 'Cài đặt')),
      _MenuItem('Hồ sơ', Icons.account_circle_outlined, screen: const PlaceholderScreen(title: 'Hồ sơ')),
      _MenuItem(
        'Đăng xuất',
        Icons.logout,
        onTap: () => _logout(context, ref),
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
              if (item.onTap != null) {
                item.onTap!();
                return;
              }
              if (item.screen != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.screen!),
                );
                // Refresh unread status when coming back
                _checkUnreadStatus();
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
  final VoidCallback? onTap;
  final bool showDot;

  _MenuItem(
    this.title,
    this.icon, {
    this.screen,
    this.onTap,
    this.showDot = false,
  });
}