import 'package:flutter/material.dart';
import 'widgets/chat_item_widget.dart';
import 'chat_detail_screen.dart';
import '../models/chat_thread.dart';
import '../data/chat_repository.dart';
// Nhớ thêm import SessionStorage nếu chưa có
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
    // 1. KẾT NỐI SOCKET NGAY KHI VÀO MÀN HÌNH
    _initSocketConnection();
    // 2. TẢI DANH SÁCH LẦN ĐẦU TỪ API REST
    _loadThreads();
  }

  void _initSocketConnection() async {
      // 1. Khởi tạo storage
      final storage = SessionStorage();

      // 2. Lấy token thật từ SharedPreferences
      String? token = await storage.getToken();

      if (token != null && token.isNotEmpty) {
        print("🔑 [UI] Đã lấy được Token thật: ${token.substring(0, 10)}...");

        // 3. Truyền token thật vào để kết nối
        widget.repository.startSocketConnection(token, (newMessage) {
          _loadThreads(); // Load lại danh sách khi có tin nhắn mới
        });
      } else {
        print("❌ [UI] LỖI: Không tìm thấy Token trong storage. Vui lòng đăng nhập lại!");
        // Có thể điều hướng về trang Login ở đây
      }
  }

  /// Hàm tải danh sách các cuộc hội thoại
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
    // 3. NGẮT KẾT NỐI KHI THOÁT MÀN HÌNH
    // (Nếu bạn muốn Admin luôn nhận tin nhắn dù ở màn hình khác, hãy cân nhắc đóng ở App level)
    widget.repository.dispose();
    super.dispose();
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
            onPressed: _loadThreads, // Nút làm mới thủ công
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}