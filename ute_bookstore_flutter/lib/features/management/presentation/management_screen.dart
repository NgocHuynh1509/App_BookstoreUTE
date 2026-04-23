import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/providers.dart';
import '../../../widgets/placeholder_screen.dart';
import '../../../theme/admin_theme.dart';
import '../../customers/presentation/customers_screen.dart';
import '../../auth/presentation/admin_login_screen.dart';
import '../../../../chat/presentation/chat_list_screen.dart';
import '../../coupons/presentation/coupons_screen.dart';
import '../../categories/presentation/category_screen.dart';

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
      _MenuItem('Danh mục', Icons.category_outlined, screen: const CategoryScreen()),
      _MenuItem(
        'Tin nhắn / Hỗ trợ',
        Icons.chat_bubble_outline,
        screen: ChatListScreen(repository: chatRepo),
        showDot: _hasUnread,
      ),
      _MenuItem('Mã giảm giá', Icons.local_offer_outlined, screen: const CouponsScreen()),
      _MenuItem(
        'Đăng xuất',
        Icons.logout,
        onTap: () => _logout(context, ref),
        isDestructive: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AdminColors.background,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 1100
              ? 4
              : width >= 800
                  ? 3
                  : width >= 600
                      ? 2
                      : 1;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 1 ? 3.4 : 1.4,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _MenuCard(
                item: item,
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
                    _checkUnreadStatus();
                  }
                },
              )
                  .animate()
                  .fadeIn(duration: 220.ms, delay: (index * 25).ms)
                  .slideY(begin: 0.06, end: 0, duration: 220.ms, curve: Curves.easeOutCubic);
            },
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.onTap});

  final _MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = item.isDestructive ? AdminColors.danger : AdminColors.primary;
    final accentBackground = accentColor.withOpacity(0.12);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Truy cập nhanh',
                    style: const TextStyle(color: AdminColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (item.showDot)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right, color: AdminColors.textSecondary),
          ],
        ),
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
  final bool isDestructive;

  _MenuItem(
    this.title,
    this.icon, {
    this.screen,
    this.onTap,
    this.showDot = false,
    this.isDestructive = false,
  });
}