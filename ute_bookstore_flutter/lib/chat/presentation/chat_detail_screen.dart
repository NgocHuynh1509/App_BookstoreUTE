import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'widgets/message_bubble.dart';
import '../data/chat_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api_config.dart';

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
  ChatMessage? _replyMessage; // ✅ THÊM

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initSocketListener();
    widget.repository.markAsSeen(widget.customerUsername);
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
        bool isRelevant = (newMessage.userName == widget.customerUsername) ||
            (newMessage.receiverName == widget.customerUsername);
        if (!isRelevant) return;
        setState(() {
          _messages.removeWhere((m) =>
              m.id != null && m.id!.startsWith('temp_') && m.content == newMessage.content);
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
        final mediaUrl = await widget.repository.uploadImage(image);
        widget.repository.sendAdminReply(
          widget.customerUsername, "", 
          mediaUrl: mediaUrl,
          replyToId: _replyMessage?.id
        );
        setState(() => _replyMessage = null); // Reset reply sau khi gửi
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      messageType: MessageType.TEXT,
      senderRole: SenderRole.ADMIN,
      createdAt: DateTime.now(),
      userName: 'admin',
      receiverName: widget.customerUsername,
      replyToId: _replyMessage?.id,
      replyToContent: _replyMessage?.content,
      replyToMessageType: _replyMessage?.messageType,
      replyToMediaUrl: _replyMessage?.mediaUrl,
      replyToSender: _replyMessage?.userName,
    );

    setState(() {
      _messages.insert(0, tempMsg);
    });

    widget.repository.sendAdminReply(
      widget.customerUsername, 
      text, 
      replyToId: _replyMessage?.id
    );

    _controller.clear();
    setState(() => _replyMessage = null); // Reset reply sau khi gửi
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
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  children: [
                    if (_shouldShowDate(index))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          formatDate(msg.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: msg.senderRole == SenderRole.ADMIN
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (msg.senderRole != SenderRole.ADMIN)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 4),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundImage: const NetworkImage("/upload/avt.jpg"),
                                ),
                              ),
                            ),
                          MessageBubble(
                            message: msg,
                            isMe: msg.senderRole == SenderRole.ADMIN,
                            onReact: (reaction) => _sendReaction(msg, reaction),
                            onReply: (message) => setState(() => _replyMessage = message), // ✅ THÊM
                          ),
                          if (msg.senderRole == SenderRole.ADMIN) const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          if (_replyMessage != null) _buildReplyPreview(), // ✅ THÊM
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final isImage = _replyMessage!.messageType == MessageType.IMAGE;
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.reply, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đang trả lời ${_replyMessage!.userName ?? 'Người dùng'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                ),
                Text(
                  isImage ? "[Hình ảnh]" : _replyMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (isImage && _replyMessage!.mediaUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.network(
                '${ApiConfig.baseUrl}${_replyMessage!.mediaUrl}',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _replyMessage = null),
          ),
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
}