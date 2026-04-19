import 'package:flutter/material.dart';
import 'widgets/chat_item_widget.dart';
import 'chat_detail_screen.dart';
import '../models/chat_thread.dart';
import '../data/chat_repository.dart';
import '../../core/session_storage.dart';

class ChatListScreen extends StatefulWidget {
  final ChatRepository repository;
  const ChatListScreen({super.key, required this.repository});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatThread> _threads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSocketConnection();
    _loadThreads();
  }

  void _initSocketConnection() async {
      final storage = SessionStorage();
      String? token = await storage.getToken();

      if (token != null && token.isNotEmpty) {
        print("🔑 [UI] Đã lấy được Token thật: ${token.substring(0, 10)}...");
        widget.repository.startSocketConnection(
          token,
          (newMessage) {
            _loadThreads();
          },
          (reaction) {
            // không cần làm gì ở list
          },
        );
      } else {
        print("❌ [UI] LỖI: Không tìm thấy Token trong storage. Vui lòng đăng nhập lại!");
      }
  }

  Future<void> _loadThreads() async {
    try {
      final threads = await widget.repository.fetchChatThreads();
      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi tải danh sách: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    widget.repository.dispose();
    super.dispose();
  }

  void _showToggleUnreadMenu(ChatThread thread) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  thread.isManualUnread ? Icons.mark_chat_read : Icons.mark_chat_unread,
                  color: Colors.blue,
                ),
                title: Text(
                  thread.isManualUnread ? "Đánh dấu là đã đọc" : "Đánh dấu là chưa đọc",
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await widget.repository.toggleUnread(
                      thread.customerUsername,
                      !thread.isManualUnread,
                    );
                    _loadThreads();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e")),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khách hàng"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadThreads,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _threads.isEmpty
              ? const Center(child: Text("Chưa có khách hàng nào nhắn tin"))
              : RefreshIndicator(
                  onRefresh: _loadThreads,
                  child: ListView.builder(
                    itemCount: _threads.length,
                    itemBuilder: (context, index) {
                      return ChatItemWidget(
                        thread: _threads[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              customerUsername: _threads[index].customerUsername,
                              repository: widget.repository,
                            ),
                          ),
                        ).then((_) => _loadThreads()), 
                        onLongPress: () => _showToggleUnreadMenu(_threads[index]),
                      );
                    },
                  ),
                ),
    );
  }
}