import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'widgets/message_bubble.dart';
import '../data/chat_repository.dart';
import 'package:image_picker/image_picker.dart';


class ChatDetailScreen extends StatefulWidget {
  final String customerUsername;
  final ChatRepository repository;

  const ChatDetailScreen({
    super.key,
    required this.customerUsername,
    required this.repository
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    // 1. Tải lịch sử tin nhắn
    _loadHistory();
    // 2. Lắng nghe socket để nhận tin nhắn mới ngay tại màn hình này
    _initSocketListener();
  }

  void _loadHistory() async {
    try {
      final history = await widget.repository.fetchMessages(widget.customerUsername);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
        });
      }
    } catch (e) {
      print("❌ Lỗi load history: $e");
    }
  }

  void _initSocketListener() {
      // Đừng gọi startSocketConnection ở đây nữa vì nó sẽ kết nối lại.
      // Chỉ cập nhật callback cho kết nối ĐANG CÓ.
      widget.repository.updateMessageCallback((payload) {
      print("🔔 ĐÃ NHẬN TÍN HIỆU REALTIME: $payload"); // <--- Thêm dòng này để debug
        if (mounted) {
          final newMessage = ChatMessage.fromMap(payload);

          // Kiểm tra xem tin nhắn có thuộc về hội thoại này không
          bool isRelevant = (newMessage.userName == widget.customerUsername) ||
                            (newMessage.receiverName == widget.customerUsername);

          if (isRelevant) {
            setState(() {
              // Xóa tin nhắn tạm (Optimistic) nếu nội dung trùng khớp
              _messages.removeWhere((m) => m.id!.startsWith('temp_') && m.content == newMessage.content);

              // Chèn tin nhắn thật từ Socket vào
              _messages.insert(0, newMessage);
            });
          }
        }
      });
    }
    void _onPickImage() async {
        try {
          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            // Upload ảnh và gửi socket luôn
            final mediaUrl = await widget.repository.uploadImage(image);
            widget.repository.sendAdminReply(widget.customerUsername, "", mediaUrl: mediaUrl);
          }
        } catch (e) {
          print("Lỗi chọn ảnh: $e");
        }
      }


  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Tạo tin nhắn để hiển thị ngay (Optimistic UI)
    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}', // Sửa nanoseconds thành microseconds
      content: text,
      messageType: MessageType.TEXT,
      senderRole: SenderRole.ADMIN, // Bắt buộc là ADMIN
      createdAt: DateTime.now(),
      userName: 'admin',
      receiverName: widget.customerUsername,
    );

    setState(() {
      _messages.insert(0, tempMsg); // Chèn vào đầu list
    });

    // 2. Gửi qua repository
    widget.repository.sendAdminReply(widget.customerUsername, text);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat với ${widget.customerUsername}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Tin nhắn mới nhất nằm dưới cùng
              itemCount: _messages.length,
              itemBuilder: (context, index) => MessageBubble(message: _messages[index]),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
        IconButton(
                    onPressed: _onPickImage,
                    icon: const Icon(Icons.image, color: Colors.blue)
                  ),

          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Nhập phản hồi...",
                border: InputBorder.none
              ),
              onSubmitted: (_) => _onSend(),
            ),
          ),
          IconButton(
            onPressed: _onSend,
            icon: const Icon(Icons.send, color: Colors.blue)
          ),
        ],
      ),
    );
  }
} // <--- Đảm bảo dấu đóng ngoặc của class State nằm ở cuối cùng