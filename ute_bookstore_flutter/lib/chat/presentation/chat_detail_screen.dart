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
  // 👇 ĐẶT Ở ĐÂY
    String formatDate(DateTime date) {
      return "${date.day}/${date.month}/${date.year} "
          "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }

  bool _shouldShowDate(int index) {
    if (index == _messages.length - 1) return true;

    final current = _messages[index].createdAt;
    final next = _messages[index + 1].createdAt;

    return current.difference(next).inMinutes.abs() > 30;
  }

  void _initSocketListener() {

        widget.repository.updateCallbacks(
          onMessage: (payload) {
            final newMessage = ChatMessage.fromMap(payload);

            bool isRelevant =
                (newMessage.userName == widget.customerUsername) ||
                (newMessage.receiverName == widget.customerUsername);

            if (!isRelevant) return;

            setState(() {
              _messages.removeWhere((m) =>
                  m.id!.startsWith('temp_') &&
                  m.content == newMessage.content);

              _messages.insert(0, newMessage);
            });
          },

          onReaction: (payload) {
            final updated = ChatMessage.fromMap(payload);

            setState(() {
              final index = _messages.indexWhere((m) => m.id == updated.id);
              if (index != -1) {
                _messages[index] = updated;
              }
            });
          },
        );
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

  void _sendReaction(ChatMessage message, String reaction) {
    if (message.id == null) return;

    widget.repository.socket.sendReaction(
      messageId: message.id!,
      reaction: reaction,
      partnerName: widget.customerUsername,
    );
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
              itemBuilder: (context, index) {
                final msg = _messages[index];

                return Column(
                  children: [
                    // ✅ HIỂN THỊ NGÀY (Messenger style)
                    if (_shouldShowDate(index))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          formatDate(msg.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                    IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: msg.senderRole == SenderRole.ADMIN
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                        // 👤 USER AVATAR
                        if (msg.senderRole != SenderRole.ADMIN)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(
                                  "/uploads/avt.jpg",
                                ),
                              ),
                            ),
                          ),
                        MessageBubble(
                          message: msg,
                          isMe: msg.senderRole == SenderRole.ADMIN,
                          onReact: (reaction) {
                            _sendReaction(msg, reaction);
                          },
                        ),

                        // 👤 ADMIN spacing
                        if (msg.senderRole == SenderRole.ADMIN)
                          const SizedBox(width: 8),
                      ],
                      ),
                    ),
                  ],

                );
              }
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